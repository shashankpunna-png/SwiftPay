import Foundation

struct UserEnvelope: Decodable {
    let success: Bool
    let user: UserDTO
}

struct UserDTO: Decodable {
    let id: String
    let name: String
    let mobileNumber: String
    let upiId: String
    let walletBalance: Decimal
    let currency: String
    let photoFile: String?
    let photoUpdatedAt: String?

    func domainUser() -> User {
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

struct UpdateUserBody: Encodable {
    let name: String
    let mobileNumber: String
    let upiId: String
    let photoFile: String?

    init(_ update: UserUpdate) {
        name = update.name
        mobileNumber = update.mobileNumber
        upiId = update.upiId
        photoFile = update.photoFile
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(mobileNumber, forKey: .mobileNumber)
        try container.encode(upiId, forKey: .upiId)
        try container.encodeIfPresent(photoFile, forKey: .photoFile)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case mobileNumber
        case upiId
        case photoFile
    }
}
