import Foundation

enum SilverGardenSessionLoginStore {
    private static let silverGardenSessionCurrentUserIDKey = "HiVivi.SilverGardenSessionLoginStore.currentUserID"

    static func saveCurrentUserID(_ silverGardenSessionUserID: String) {
        UserDefaults.standard.set(silverGardenSessionUserID, forKey: silverGardenSessionCurrentUserIDKey)
    }

    static func readCurrentUserID() -> String? {
        UserDefaults.standard.string(forKey: silverGardenSessionCurrentUserIDKey)
    }

    static func clearCurrentUserID() {
        UserDefaults.standard.removeObject(forKey: silverGardenSessionCurrentUserIDKey)
    }

    static var hasCurrentUser: Bool {
        readCurrentUserID() != nil
    }
}
