
import Foundation
import SwiftData

final class TransactionStore {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Load

    func loadTransactions(
        query: TransactionQuery
    ) throws -> [Transaction] {

        let descriptor = FetchDescriptor<StoredTransaction>(
            sortBy: [
                SortDescriptor(
                    \.timestamp,
                    order: .reverse
                )
            ]
        )

        let storedTransactions = try context.fetch(descriptor)

        let transactions = try storedTransactions.map {
            try $0.toDomain()
        }

        return transactions.filter {
            matches($0, query: query)
        }
    }

    // MARK: - Filtering

    private func matches(
        _ transaction: Transaction,
        query: TransactionQuery
    ) -> Bool {

        // Type filter
        if let type = query.type,
           transaction.type != type {
            return false
        }

        // Start date filter
        if let fromDate = query.fromDate,
           transaction.timestamp < fromDate {
            return false
        }

        // End date filter
        if let toDate = query.toDate,
           transaction.timestamp > toDate {
            return false
        }

        // Search filter
        let search = query.searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !search.isEmpty else {
            return true
        }

        let searchableText = [
            transaction.id,
            transaction.senderDetails.name,
            transaction.senderDetails.mobileNumber,
            transaction.senderDetails.upiId,
            transaction.receiverDetails.name,
            transaction.receiverDetails.mobileNumber,
            transaction.receiverDetails.upiId
        ]

        return searchableText.contains {
            $0.localizedCaseInsensitiveContains(search)
        }
    }

    // MARK: - Save / Upsert

    func saveTransactions(
        _ transactions: [Transaction]
    ) throws {

        guard !transactions.isEmpty else {
            return
        }

        let descriptor = FetchDescriptor<StoredTransaction>()

        let existingTransactions = try context.fetch(descriptor)

        var existingById: [String: StoredTransaction] = [:]

        for stored in existingTransactions {
            existingById[stored.id] = stored
        }

        for transaction in transactions {

            if let existing = existingById[transaction.id] {

                // Update existing transaction
                existing.update(from: transaction)

            } else {

                // Insert new transaction
                let stored = StoredTransaction(from: transaction)

                context.insert(stored)

                existingById[transaction.id] = stored
            }
        }

        try context.save()
    }
}
