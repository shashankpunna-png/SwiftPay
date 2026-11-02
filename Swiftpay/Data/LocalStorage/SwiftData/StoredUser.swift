import Foundation
import SwiftData

@Model
final class StoredUser {
    @Attribute(.unique) var id: String
    var name: String
    var mobileNumber: String
    var upiId: String
    var walletBalance: Decimal
    var currency: String
    var photoUrl: String?
    var photoUpdatedAt: Date?
    @Attribute(.externalStorage) var photoData: Data?

    init(user: User) {
        id = user.id
        name = user.name
        mobileNumber = user.mobileNumber
        upiId = user.upiId
        walletBalance = user.walletBalance
        currency = user.currency
        photoUrl = user.photoUrl
        photoUpdatedAt = user.photoUpdatedAt
        photoData = user.photoData
    }

    func fill(from user: User) {
        name = user.name
        mobileNumber = user.mobileNumber
        upiId = user.upiId
        walletBalance = user.walletBalance
        currency = user.currency
        photoUrl = user.photoUrl
        photoUpdatedAt = user.photoUpdatedAt
        photoData = user.photoData
    }

    var user: User {
        User(
            id: id,
            name: name,
            mobileNumber: mobileNumber,
            upiId: upiId,
            walletBalance: walletBalance,
            currency: currency,
            photoUrl: photoUrl,
            photoUpdatedAt: photoUpdatedAt,
            photoData: photoData
        )
    }
}
