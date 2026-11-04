const http = require("http");
const fs = require("fs");
const path = require("path");
const { randomUUID } = require("crypto");

const PORT = Number(process.env.PORT) || 4000;
const DATA_DIR = path.join(__dirname, "data");
const PHOTO_DIR = path.join(DATA_DIR, "photos");
const USER_FILE = path.join(DATA_DIR, "user.json");
const TRANSACTIONS_FILE = path.join(DATA_DIR, "transactions.json");

const NETWORK_ERROR = {
  code: "NETWORK_ERROR",
  message: "Unable to load user information. Please try again.",
};

const INSUFFICIENT_BALANCE = {
  code: "INSUFFICIENT_BALANCE",
  message: "Your wallet balance is insufficient for this transfer.",
};

function party(name, mobileNumber, upiId) {
  return { name, mobileNumber, upiId };
}

function seedUser() {
  return {
    id: randomUUID(),
    name: "",
    mobileNumber: "",
    upiId: "",
    walletBalance: 0,
    currency: "INR",
    photoFilename: null,
    photoUpdatedAt: null,
  };
}

function storedTransaction(id, type, amount, timestamp, status, counterparty, extra = {}) {
  const fee = extra.fee ?? 0;
  const totalAmount = extra.totalAmount ?? money(amount + fee);
  const stored = {
    id,
    type,
    amount,
    currency: "INR",
    status,
    timestamp,
    fee,
    totalAmount,
    ownerSide: type === "credit" ? "receiver" : "sender",
    counterparty,
  };
  if (extra.error) stored.error = extra.error;
  return stored;
}

function formatTransactionId(sequence) {
  return `TXN${String(sequence).padStart(7, "0")}`;
}

function parseTransactionSequence(id) {
  const match = String(id || "").match(/^TXN(\d+)$/);
  return match ? Number.parseInt(match[1], 10) : 0;
}

function syncNextTransactionId(store) {
  let max = store.nextId || 0;
  for (const item of store.transactions) {
    max = Math.max(max, parseTransactionSequence(item.id));
  }
  store.nextId = max + 1;
}

function allocateTransactionId(store) {
  syncNextTransactionId(store);
  const id = formatTransactionId(store.nextId);
  store.nextId += 1;
  return id;
}

function seedTransactions() {
  const swiggy = party("Swiggy", "9988001122", "swiggy.orders@swiftpay");
  const rahul = party("Rahul Mehta", "9810012345", "rahul.mehta@swiftpay");
  const neha = party("Neha Iyer", "9820098765", "neha.iyer@swiftpay");
  const amazon = party("Amazon", "9988776655", "amazon.orders@swiftpay");
  const rohan = party("Rohan Verma", "9845011122", "rohan.verma@swiftpay");
  const tata = party("Tata Power", "9922003344", "tata.power@swiftpay");
  const starbucks = party("Starbucks", "9933445566", "starbucks.orders@swiftpay");
  const zomato = party("Zomato", "9900112233", "zomato.orders@swiftpay");
  const paytm = party("Paytm Mall", "9911223344", "paytm.mall@swiftpay");

  return {
    nextId: 1016,
    idempotency: {},
    transactions: [
      storedTransaction("TXN0001015", "debit", 650, "2026-11-02T09:20:00.000Z", "pending", swiggy),
      storedTransaction("TXN0001014", "credit", 1800, "2026-11-02T06:05:00.000Z", "pending", rahul),
      storedTransaction("TXN0001013", "debit", 99999, "2026-11-01T18:00:00.000Z", "cancelled", amazon, {
        error: INSUFFICIENT_BALANCE,
      }),
      storedTransaction("TXN0001012", "debit", 480, "2026-11-01T07:45:00.000Z", "success", swiggy),
      storedTransaction("TXN0001011", "credit", 2500, "2026-11-01T04:10:00.000Z", "success", rahul),
      storedTransaction("TXN0001010", "debit", 1200, "2026-10-31T13:35:00.000Z", "success", neha),
      storedTransaction("TXN0001009", "debit", 899, "2026-10-30T10:50:00.000Z", "success", amazon),
      storedTransaction("TXN0001008", "credit", 1250, "2026-10-29T15:00:00.000Z", "success", rohan),
      storedTransaction("TXN0001007", "debit", 2140, "2026-1０-27T1０:15:００.０００Z", "success", tata),
      storedTransaction("TXN0001006", "debit", 350, "2026-10-24T03:50:00.000Z", "success", starbucks),
      storedTransaction("TXN0001005", "credit", 900, "2026-10-23T11:30:00.000Z", "success", paytm),
      storedTransaction("TXN0001004", "debit", 275, "2026-10-22T08:15:00.000Z", "cancelled", zomato),
      storedTransaction("TXN0001003", "debit", 1500, "2026-10-21T16:40:00.000Z", "success", zomato),
    ],
  };
}

function ensureStore() {
  fs.mkdirSync(PHOTO_DIR, { recursive: true });

  if (!fs.existsSync(USER_FILE)) writeJson(USER_FILE, seedUser());

  if (!fs.existsSync(TRANSACTIONS_FILE)) {
    writeJson(TRANSACTIONS_FILE, seedTransactions());
    return;
  }

  const store = readJson(TRANSACTIONS_FILE);
  let changed = false;

  if (!store.idempotency || typeof store.idempotency !== "object") {
    store.idempotency = {};
    changed = true;
  }

  // Migrate legacy persisted status values to the canonical status.
  for (const item of store.transactions) {
    if (item.status === "completed") {
      item.status = "success";
      changed = true;
    }
  }

  if (store.transactions.some((item) => item.senderDetails || item.receiverDetails)) {
    store.transactions = store.transactions.map(normalizeTransaction);
    changed = true;
  }

  const before = store.nextId;
  syncNextTransactionId(store);
  if (store.nextId !== before) changed = true;

  if (changed) writeJson(TRANSACTIONS_FILE, store);
}

function writeJson(file, value) {
  const temporary = `${file}.tmp`;
  fs.writeFileSync(temporary, JSON.stringify(value, null, 2));
  fs.renameSync(temporary, file);
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function networkError() {
  const error = new Error(NETWORK_ERROR.message);
  error.status = 503;
  error.body = { success: false, error: NETWORK_ERROR };
  return error;
}

function invalidRequest(message) {
  const error = new Error(message);
  error.status = 400;
  error.body = {
    success: false,
    error: { code: "INVALID_REQUEST", message },
  };
  return error;
}

function loadUser() {
  try {
    const user = readJson(USER_FILE);
    if (!user || typeof user.name !== "string" || typeof user.walletBalance !== "number") {
      throw new Error("User file is unreadable");
    }
    if (typeof user.id !== "string" || user.id.trim() === "") {
      user.id = randomUUID();
      saveUser(user);
    }
    if (user.photoFilename == null && typeof user.photoFile === "string" && user.photoFile.length > 0) {
      if (user.photoFile.length <= 64 && !user.photoFile.includes("=")) {
        user.photoFilename = path.basename(user.photoFile);
      }
      delete user.photoFile;
      saveUser(user);
    }
    if (user.photoFile != null) {
      delete user.photoFile;
      saveUser(user);
    }
    return user;
  } catch (error) {
    if (error.status) throw error;
    throw networkError();
  }
}

function loadTransactions() {
  try {
    const store = readJson(TRANSACTIONS_FILE);
    if (!store || !Array.isArray(store.transactions)) {
      throw new Error("Transaction file is unreadable");
    }
    if (!store.idempotency || typeof store.idempotency !== "object") {
      store.idempotency = {};
    }
    syncNextTransactionId(store);
    return store;
  } catch (error) {
    if (error.status) throw error;
    throw networkError();
  }
}

function saveUser(user) {
  try {
    writeJson(USER_FILE, user);
  } catch {
    throw networkError();
  }
}

function saveTransactions(store) {
  try {
    writeJson(TRANSACTIONS_FILE, store);
  } catch {
    throw networkError();
  }
}

function money(value) {
  return Math.round(Number(value) * 100) / 100;
}

/** Authoritative transfer fee rules (review quote + POST use the same logic). */
const TRANSFER_FEE = {
  mode: "fixed",
  value: 0,
};

function computeTransferFee(type, amount) {
  if (type === "credit") return 0;
  if (TRANSFER_FEE.mode === "fixed") return money(TRANSFER_FEE.value);
  if (TRANSFER_FEE.mode === "percent") {
    return money(Math.max(0, (Number(amount) * TRANSFER_FEE.value) / 100));
  }
  return 0;
}

function quoteTransfer(searchParams) {
  const type = text(searchParams.get("type")).toLowerCase();
  if (type !== "credit" && type !== "debit") {
    throw invalidRequest("type must be credit or debit.");
  }

  const amountRaw = searchParams.get("amount");
  if (amountRaw == null || text(amountRaw) === "") {
    throw invalidRequest("amount is required.");
  }
  const amount = money(amountRaw);
  if (!Number.isFinite(amount) || amount <= 0) {
    throw invalidRequest("amount must be greater than 0.");
  }

  const currency = text(searchParams.get("currency") || "INR").toUpperCase();
  if (currency !== "INR") throw invalidRequest("currency must be INR.");

  const fee = computeTransferFee(type, amount);
  const totalAmount = type === "debit" ? money(amount + fee) : money(amount);

  const quote = {
    type,
    amount,
    fee,
    totalAmount,
    currency,
  };

  const user = loadUser();
  if (type === "debit") {
    const balance = money(user.walletBalance);
    quote.wallet = {
      currency: user.currency,
      balance,
      sufficient: balance >= totalAmount,
    };
  }

  return { success: true, quote };
}

function readPhotoBase64(user) {
  const filename = user.photoFilename;
  if (!filename) return null;
  const file = path.join(PHOTO_DIR, path.basename(filename));
  if (!fs.existsSync(file)) return null;
  return fs.readFileSync(file).toString("base64");
}

function publicUser(user) {
  return {
    id: user.id,
    name: user.name,
    mobileNumber: user.mobileNumber,
    upiId: user.upiId,
    walletBalance: user.walletBalance,
    currency: user.currency,
    photoFile: readPhotoBase64(user),
    photoUpdatedAt: user.photoUpdatedAt == null ? null : String(user.photoUpdatedAt),
  };
}

function ownerParty(user) {
  return party(user.name, user.mobileNumber, user.upiId);
}

function normalizeTransaction(item) {
  if (item.ownerSide && item.counterparty) {
    const stored = { ...item };
    delete stored.senderDetails;
    delete stored.receiverDetails;
    return stored;
  }
  const ownerSide = item.type === "credit" ? "receiver" : "sender";
  const counterparty = ownerSide === "sender" ? item.receiverDetails : item.senderDetails;
  const stored = { ...item, ownerSide, counterparty };
  delete stored.senderDetails;
  delete stored.receiverDetails;
  return stored;
}

function presentTransaction(item, user) {
  const stored = normalizeTransaction(item);
  const me = ownerParty(user);
  const transaction = {
    id: stored.id,
    type: stored.type,
    amount: stored.amount,
    currency: stored.currency,
    status: stored.status,
    timestamp: stored.timestamp,
    fee: stored.fee,
    totalAmount: stored.totalAmount,
    senderDetails: stored.ownerSide === "sender" ? me : stored.counterparty,
    receiverDetails: stored.ownerSide === "receiver" ? me : stored.counterparty,
  };
  if (stored.error) transaction.error = stored.error;
  return transaction;
}

function text(value) {
  return typeof value === "string" ? value.trim() : "";
}

function readParty(value, label) {
  if (!value || typeof value !== "object") {
    throw invalidRequest(`${label} is required.`);
  }
  const name = text(value.name);
  const mobileNumber = text(value.mobileNumber || value.mobile || value.mobile_number);
  const upiId = text(value.upiId || value.upiID || value.upi_id);
  if (!name) throw invalidRequest(`${label} name is required.`);
  if (!mobileNumber) throw invalidRequest(`${label} mobile number is required.`);
  if (!upiId) throw invalidRequest(`${label} UPI ID is required.`);
  return party(name, mobileNumber, upiId);
}

function readBody(req, limit) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on("data", (chunk) => {
      size += chunk.length;
      if (size > limit) {
        reject(invalidRequest("Request body is too large."));
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });
    req.on("end", () => resolve(Buffer.concat(chunks)));
    req.on("error", () => reject(networkError()));
  });
}

async function readJsonBody(req) {
  const raw = await readBody(req, 6 * 1024 * 1024);
  if (raw.length === 0) return {};
  try {
    return JSON.parse(raw.toString("utf8"));
  } catch {
    throw invalidRequest("Request body must be JSON.");
  }
}

function imageKind(buffer, contentType) {
  const type = String(contentType || "").toLowerCase();
  if (type.includes("png") || (buffer[0] === 0x89 && buffer[1] === 0x50)) return "png";
  if (type.includes("jpeg") || type.includes("jpg") || (buffer[0] === 0xff && buffer[1] === 0xd8)) {
    return "jpg";
  }
  return null;
}

function removePhoto(user) {
  if (!user.photoFilename) return;
  const file = path.join(PHOTO_DIR, user.photoFilename);
  if (fs.existsSync(file)) fs.unlinkSync(file);
  user.photoFilename = null;
  user.photoUpdatedAt = null;
}

function savePhoto(user, buffer, contentType) {
  const kind = imageKind(buffer, contentType);
  if (!kind) throw invalidRequest("Photo must be a JPEG or PNG image.");
  removePhoto(user);
  const filename = `profile.${kind}`;
  fs.writeFileSync(path.join(PHOTO_DIR, filename), buffer);
  user.photoFilename = filename;
  user.photoUpdatedAt = Date.now();
}

function clampLimit(value) {
  const parsed = Number.parseInt(value || "10", 10);
  if (!Number.isFinite(parsed) || parsed < 1) return 10;
  return Math.min(parsed, 50);
}

function matchesSearch(item, user, search) {
  if (!search) return true;

  const presented = presentTransaction(item, user);

  const haystack = [
    presented.id,
    presented.senderDetails?.name,
    presented.senderDetails?.mobileNumber,
    presented.senderDetails?.upiId,
    presented.receiverDetails?.name,
    presented.receiverDetails?.mobileNumber,
    presented.receiverDetails?.upiId,
  ]
    .filter(Boolean)
    .join(" ")
    .toLowerCase();

  return haystack.includes(search);
}

function sortNewestFirst(transactions) {
  transactions.sort((a, b) => {
    const time = new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime();
    if (!Number.isNaN(time) && time !== 0) return time;
    return b.id.localeCompare(a.id, undefined, { numeric: true });
  });
  return transactions;
}

function parseBound(value, edge) {
  const raw = text(value);

  if (!raw) return null;

  const label = edge === "start" ? "from" : "to";

  const normalized = /^\d{4}-\d{2}-\d{2}$/.test(raw)
    ? `${raw}${edge === "start"
        ? "T00:00:00.000Z"
        : "T23:59:59.999Z"}`
    : raw;

  const date = new Date(normalized);

  if (
    Number.isNaN(date.getTime()) ||
    (raw.length === 10 && date.toISOString().slice(0, 10) !== raw)
  ) {
    throw invalidRequest(`${label} must be a valid ISO date or timestamp.`);
  }

  return date;
}

function listTransactions(query) {
  const user = loadUser();
  const store = loadTransactions();

  // 1. Read and validate filters.
  const search = text(query.get("q") || query.get("search")).toLowerCase();
  const type = text(query.get("type")).toLowerCase() || "all";

  if (!["all", "credit", "debit"].includes(type)) {
    throw invalidRequest("type must be all, credit, or debit.");
  }

  const from = parseBound(query.get("from"), "start");
  const to = parseBound(query.get("to"), "end");

  if (from && to && from > to) {
    throw invalidRequest("from date cannot be later than to date.");
  }

  // 2. Apply all filters together.
  const filteredTransactions = store.transactions.filter((item) => {
    if (type !== "all" && item.type !== type) {
      return false;
    }

    if (!matchesSearch(item, user, search)) {
      return false;
    }

    const timestamp = new Date(item.timestamp);

    if (from && timestamp < from) {
      return false;
    }

    if (to && timestamp > to) {
      return false;
    }

    return true;
  });

  // 3. Sort newest first.
  sortNewestFirst(filteredTransactions);

  // 4. Apply pagination.
  const limit = clampLimit(query.get("limit"));
  const cursor = text(query.get("cursor"));

  let start = 0;

  if (cursor) {
    const index = filteredTransactions.findIndex(
      (item) => item.id === cursor
    );

    if (index === -1) {
      throw invalidRequest(
        "cursor does not match a transaction in this filtered result."
      );
    }

    start = index + 1;
  } else {
    const page = Number.parseInt(query.get("page") || "1", 10);
    start = (Math.max(page, 1) - 1) * limit;
  }

  const transactions = filteredTransactions.slice(
    start,
    start + limit
  );

  const hasMore = start + transactions.length < filteredTransactions.length;

  // 5. Return results and pagination metadata.
  return {
    success: true,

    filters: {
      q: search,
      type,
      from: from ? from.toISOString() : null,
      to: to ? to.toISOString() : null,
    },

    pagination: {
      limit,
      nextCursor: hasMore
        ? transactions[transactions.length - 1].id
        : null,
      hasMore,
      total: filteredTransactions.length,
    },

    transactions: transactions.map((item) =>
      presentTransaction(item, user)
    ),
  };
}

function readIdempotencyKey(req, body) {
  return text(req.headers["idempotency-key"] || body.idempotencyKey || body.idempotency_key);
}

function rememberIdempotency(store, key, status, body) {
  if (!key) return;
  store.idempotency[key] = { status, body, savedAt: new Date().toISOString() };
}

function replayIdempotency(store, key) {
  if (!key) return null;
  const saved = store.idempotency[key];
  if (!saved) return null;
  const error = new Error("Idempotent replay");
  error.status = saved.status;
  error.body = saved.body;
  return error;
}

function assertSenderIsWalletUser(body, user) {
  const provided = body.senderDetails || body.sender;
  if (!provided) return;
  const sender = readParty(provided, "Sender");
  const me = ownerParty(user);
  if (sender.mobileNumber !== me.mobileNumber || sender.upiId !== me.upiId) {
    throw invalidRequest("senderDetails must match the wallet user.");
  }
}

function createTransaction(body, req) {
  const idempotencyKey = readIdempotencyKey(req, body);
  const store = loadTransactions();
  const replay = replayIdempotency(store, idempotencyKey);
  if (replay) throw replay;

  const type = text(body.type).toLowerCase();
  if (type !== "credit" && type !== "debit") {
    throw invalidRequest("type must be credit or debit.");
  }

  const amount = money(body.amount);
  if (!Number.isFinite(amount) || amount <= 0) throw invalidRequest("amount must be greater than 0.");

  const currency = text(body.currency || "INR").toUpperCase();
  if (currency !== "INR") throw invalidRequest("currency must be INR.");

  const user = loadUser();
  assertSenderIsWalletUser(body, user);

  let counterparty;
  if (type === "debit") {
    counterparty = readParty(body.receiverDetails || body.receiver, "Receiver");
  } else {
    counterparty = readParty(body.senderDetails || body.sender, "Sender");
  }

  const fee = computeTransferFee(type, amount);
  if (body.fee != null && money(body.fee) !== fee) {
    throw invalidRequest("fee is calculated by the server; omit fee or use GET /api/transactions/quote.");
  }

  const totalAmount = type === "debit" ? money(amount + fee) : money(amount);
  const previousBalance = user.walletBalance;

  if (type === "debit" && money(previousBalance) < totalAmount) {
    const failureBody = {
      success: false,
      message: INSUFFICIENT_BALANCE.message,
      error: INSUFFICIENT_BALANCE,
      wallet: {
        currency: user.currency,
        previousBalance,
        newBalance: previousBalance,
      },
    };
    rememberIdempotency(store, idempotencyKey, 422, failureBody);
    saveTransactions(store);
    const error = new Error(INSUFFICIENT_BALANCE.message);
    error.status = 422;
    error.body = failureBody;
    throw error;
  }

  const id = allocateTransactionId(store);
  const timestamp = new Date().toISOString();
  const newBalance = type === "debit"
    ? money(previousBalance - totalAmount)
    : money(previousBalance + amount);

  const transaction = storedTransaction(id, type, amount, timestamp, "success", counterparty, {
    fee,
    totalAmount,
  });

  user.walletBalance = newBalance;
  store.transactions.unshift(transaction);
  sortNewestFirst(store.transactions);

  const successBody = {
    success: true,
    message: "Transfer completed successfully",
    transaction: presentTransaction(transaction, user),
    wallet: {
      currency: user.currency,
      previousBalance,
      newBalance,
    },
  };

  rememberIdempotency(store, idempotencyKey, 200, successBody);
  saveUser(user);
  try {
    saveTransactions(store);
  } catch (error) {
    user.walletBalance = previousBalance;
    saveUser(user);
    throw error;
  }

  return successBody;
}

function updateUser(body) {
  const user = loadUser();
  const name = text(body.name);
  const mobileNumber = text(body.mobileNumber || body.mobile || body.mobile_number);
  const upiId = text(body.upiId || body.upiID || body.upi_id);

  if (!name) throw invalidRequest("name is required.");
  if (!/^\d{10}$/.test(mobileNumber)) {
    throw invalidRequest("mobile number must be 10 digits.");
  }
  if (!upiId) throw invalidRequest("UPI ID is required.");

  user.name = name;
  user.mobileNumber = mobileNumber;
  user.upiId = upiId;

  if (typeof body.photoFile === "string" && body.photoFile.trim() !== "") {
    const payload = body.photoFile.replace(/^data:image\/[a-zA-Z0-9.+-]+;base64,/, "");
    const buffer = Buffer.from(payload, "base64");
    if (buffer.length === 0) throw invalidRequest("photo must be a base64 string.");
    savePhoto(user, buffer, "");
  }

  saveUser(user);
  return {
    success: true,
    user: publicUser(user),
  };
}

function shortenBase64(value) {
  if (typeof value !== "string" || value.length === 0) return value;
  if (value.length <= 80) return value;
  return `[base64 ${value.length} chars]`;
}

function sanitizeForLog(value) {
  if (value == null || typeof value !== "object") return value;
  if (Array.isArray(value)) return value.map(sanitizeForLog);
  const copy = { ...value };
  if (typeof copy.photoFile === "string") {
    copy.photoFile = shortenBase64(copy.photoFile);
  }
  if (copy.user && typeof copy.user === "object") {
    copy.user = sanitizeForLog(copy.user);
  }
  if (copy.transaction && typeof copy.transaction === "object") {
    copy.transaction = sanitizeForLog(copy.transaction);
  }
  if (Array.isArray(copy.transactions)) {
    copy.transactions = copy.transactions.map(sanitizeForLog);
  }
  return copy;
}

function logRequest(method, pathname, search, body) {
  const target = `${method} ${pathname}${search || ""}`;
  if (body == null) {
    console.log(`\n→ ${target}`);
    return;
  }
  console.log(`\n→ ${target}`);
  console.log("  body:", JSON.stringify(sanitizeForLog(body), null, 2));
}

function logResponse(status, body) {
  console.log(`← ${status}`);
  console.log(JSON.stringify(sanitizeForLog(body), null, 2));
}

function sendJson(res, status, body) {
  logResponse(status, body);
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(payload),
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Idempotency-Key",
  });
  res.end(payload);
}

function sendError(res, error) {
  if (error.body) {
    sendJson(res, error.status || 500, error.body);
    return;
  }
  sendJson(res, 503, { success: false, error: NETWORK_ERROR });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);
  const { pathname } = url;
  const method = req.method || "GET";

  if (method === "OPTIONS") {
    res.writeHead(204, {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Idempotency-Key",
    });
    res.end();
    return;
  }

  try {
    ensureStore();

    if (method === "GET" && pathname === "/") {
      logRequest(method, pathname, url.search);
      sendJson(res, 200, {
        name: "SwiftPay API",
        user: "GET /api/user",
        updateUser: "PATCH /api/user",
        transactions: "GET /api/transactions?limit=10&type=all&q=&from=&to=&cursor=",
        transactionQuote: "GET /api/transactions/quote?type=debit&amount=480&currency=INR",
        transaction: "GET /api/transactions/:transactionId",
        createTransaction: "POST /api/transactions",
      });
      return;
    }

    if (method === "GET" && pathname === "/api/user") {
      logRequest(method, pathname, url.search);
      sendJson(res, 200, { success: true, user: publicUser(loadUser()) });
      return;
    }

    if ((method === "PATCH" || method === "PUT") && pathname === "/api/user") {
      const body = await readJsonBody(req);
      logRequest(method, pathname, url.search, body);
      sendJson(res, 200, updateUser(body));
      return;
    }

    if (method === "GET" && pathname === "/api/transactions") {
      logRequest(method, pathname, url.search);
      sendJson(res, 200, listTransactions(url.searchParams));
      return;
    }

    if (method === "GET" && pathname === "/api/transactions/quote") {
      logRequest(method, pathname, url.search);
      sendJson(res, 200, quoteTransfer(url.searchParams));
      return;
    }

    const transactionMatch = pathname.match(/^\/api\/transactions\/(TXN\d+)$/i);
    if (method === "GET" && transactionMatch) {
      logRequest(method, pathname, url.search);
      const store = loadTransactions();
      const transaction = store.transactions.find((item) => item.id === transactionMatch[1]);
      if (!transaction) {
        sendJson(res, 404, {
          success: false,
          error: { code: "NOT_FOUND", message: "Transaction not found." },
        });
        return;
      }
      sendJson(res, 200, { success: true, transaction: presentTransaction(transaction, loadUser()) });
      return;
    }

    if (method === "POST" && pathname === "/api/transactions") {
      const body = await readJsonBody(req);
      logRequest(method, pathname, url.search, body);
      sendJson(res, 200, createTransaction(body, req));
      return;
    }

    logRequest(method, pathname, url.search);
    sendJson(res, 404, {
      success: false,
      error: { code: "NOT_FOUND", message: "Route not found." },
    });
  } catch (error) {
    console.log(`← ${error.status || 500} (error)`);
    if (error.body) {
      console.log(JSON.stringify(sanitizeForLog(error.body), null, 2));
    } else {
      console.log(error.message || String(error));
    }
    sendError(res, error);
  }
});

ensureStore();
server.listen(PORT, "0.0.0.0", () => {
  console.log(`SwiftPay API listening on http://localhost:${PORT}`);
});
