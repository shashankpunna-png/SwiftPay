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
    var photoFile: String?
    var photoUpdatedAt: String?

    init(user: User) {
        id = user.id
        name = user.name
        mobileNumber = user.mobileNumber
        upiId = user.upiId
        walletBalance = user.walletBalance
        currency = user.currency
        photoFile = user.photoFile
        photoUpdatedAt = user.photoUpdatedAt
    }

    func fill(from user: User) {
        name = user.name
        mobileNumber = user.mobileNumber
        upiId = user.upiId
        walletBalance = user.walletBalance
        currency = user.currency
        photoFile = user.photoFile
        photoUpdatedAt = user.photoUpdatedAt
    }

    var user: User {
        User(
            id: id,
            name: name,
            mobileNumber: mobileNumber,
            upiId: upiId,
            walletBalance: walletBalance,
            currency: currency,
            photoFile: photoFile,
            photoUpdatedAt: photoUpdatedAt
        )
    }
}
