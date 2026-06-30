import Foundation

enum VoiceUserProfileStore {
    private static let voiceUserStorageKey = "HiVivi.VoiceUserProfileStore.items"

    static func create(_ voiceUser: VoiceUserProfileData) {
        var voiceUsers = readAll()
        guard !voiceUsers.contains(where: { $0.voiceUserID == voiceUser.voiceUserID }) else {
            return
        }
        voiceUsers.append(voiceUser)
        saveAll(voiceUsers)
    }

    static func read(id voiceUserID: String) -> VoiceUserProfileData? {
        readAll().first { $0.voiceUserID == voiceUserID }
    }

    static func readAll() -> [VoiceUserProfileData] {
        ToneCacheStorageBox.load([VoiceUserProfileData].self, key: voiceUserStorageKey) ?? []
    }

    static func makeShortUserID() -> String {
        let voiceExistingIDs = Set(readAll().map(\.voiceUserID))

        while true {
            let voiceShortID = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(8))
            if !voiceExistingIDs.contains(voiceShortID) {
                return voiceShortID
            }
        }
    }

    static func update(_ voiceUser: VoiceUserProfileData) {
        var voiceUsers = readAll()
        guard let voiceIndex = voiceUsers.firstIndex(where: { $0.voiceUserID == voiceUser.voiceUserID }) else {
            return
        }
        voiceUsers[voiceIndex] = voiceUser
        saveAll(voiceUsers)
    }

    static func update(id voiceUserID: String, mutate: (inout VoiceUserProfileData) -> Void) {
        var voiceUsers = readAll()
        guard let voiceIndex = voiceUsers.firstIndex(where: { $0.voiceUserID == voiceUserID }) else {
            return
        }
        mutate(&voiceUsers[voiceIndex])
        saveAll(voiceUsers)
    }

    static func upsert(_ voiceUser: VoiceUserProfileData) {
        if read(id: voiceUser.voiceUserID) == nil {
            create(voiceUser)
        } else {
            update(voiceUser)
        }
    }

    static func delete(id voiceUserID: String) {
        let voiceUsers = readAll().filter { $0.voiceUserID != voiceUserID }
        saveAll(voiceUsers)
    }

    static func deleteAll() {
        ToneCacheStorageBox.remove(key: voiceUserStorageKey)
    }

    static func saveAll(_ voiceUsers: [VoiceUserProfileData]) {
        ToneCacheStorageBox.save(voiceUsers, key: voiceUserStorageKey)
    }
}
