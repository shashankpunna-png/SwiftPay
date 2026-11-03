import Foundation
import SwiftData

final class TransactionStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Load

    func loadTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<StoredTransaction>(
            sortBy: [
                SortDescriptor(\.timestamp, order: .reverse)
            ]
        )

        let storedTransactions = try context.fetch(descriptor)

        return try storedTransactions.map { try $0.toDomain() }
    }

    // MARK: - Save / Upsert

    func saveTransactions(_ transactions: [Transaction]) throws {
        guard !transactions.isEmpty else {
            return
        }

        // Fetch existing records.
        let descriptor = FetchDescriptor<StoredTransaction>()
        let existingTransactions = try context.fetch(descriptor)

        // Create lookup dictionary using transaction ID.
        var existingById: [String: StoredTransaction] = [:]

        for stored in existingTransactions {
            existingById[stored.id] = stored
        }

        // Insert new transactions or update existing ones.
        for transaction in transactions {
            if let existing = existingById[transaction.id] {
                existing.update(from: transaction)
            } else {
                let newTransaction = StoredTransaction(from: transaction)

                context.insert(newTransaction)

                // Keep dictionary updated to prevent duplicate inserts
                // if the incoming API response contains duplicate IDs.
                existingById[transaction.id] = newTransaction
            }
        }

        try context.save()
    }
}