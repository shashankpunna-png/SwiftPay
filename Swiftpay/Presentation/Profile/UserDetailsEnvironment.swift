import SwiftUI

private struct UserDetailsEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserDetailsViewModel? = nil
}

extension EnvironmentValues {
    var userDetails: UserDetailsViewModel? {
        get { self[UserDetailsEnvironmentKey.self] }
        set { self[UserDetailsEnvironmentKey.self] = newValue }
    }
}
