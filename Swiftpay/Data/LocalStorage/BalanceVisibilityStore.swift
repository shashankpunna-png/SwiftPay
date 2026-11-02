import Foundation

struct BalanceVisibilityStore {
    private let defaults: UserDefaults
    private let key = "profile.showsBalanceOnLaunch"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var showsBalanceOnLaunch: Bool {
        if defaults.object(forKey: key) == nil {
            return true
        }
        return defaults.bool(forKey: key)
    }

    func setShowsBalanceOnLaunch(_ value: Bool) {
        defaults.set(value, forKey: key)
    }
}
