import Foundation

struct UserUpdate: Equatable, Sendable {
    var name: String
    var mobileNumber: String
    var upiId: String
    var photoFile: String?
}
