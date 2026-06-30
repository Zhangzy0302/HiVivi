import Foundation

enum SonicSeedDataBootstrap {
    private static let voiceSeedDidInitializeKey = "HiVivi.SonicSeedDataBootstrap.didInitialize"

    static func initializeLocalDataIfNeeded() {
        syncMissingSeedUsers()

        guard !UserDefaults.standard.bool(forKey: voiceSeedDidInitializeKey) else {
            return
        }

        if VoiceUserProfileStore.readAll().isEmpty {
            VoiceUserProfileStore.saveAll(HiViviSeedData.voiceUserProfiles)
        }

        if OpalBridgeRoomChatStore.readAll().isEmpty {
            OpalBridgeRoomChatStore.saveAll(HiViviSeedData.mapleQuartzChatRooms)
        }

        if WhisperMessageStore.readAll().isEmpty {
            WhisperMessageStore.saveAll(HiViviSeedData.whisperMessages)
        }

        UserDefaults.standard.set(true, forKey: voiceSeedDidInitializeKey)
    }

    private static func syncMissingSeedUsers() {
        let seedSparkSeedUsers = HiViviSeedData.voiceUserProfiles
        guard !seedSparkSeedUsers.isEmpty else {
            return
        }

        var voiceStoredUsers = VoiceUserProfileStore.readAll()
        let voiceStoredIDs = Set(voiceStoredUsers.map(\.voiceUserID))
        let seedSparkMissingUsers = seedSparkSeedUsers.filter { !voiceStoredIDs.contains($0.voiceUserID) }

        guard !seedSparkMissingUsers.isEmpty else {
            return
        }

        voiceStoredUsers.append(contentsOf: seedSparkMissingUsers)
        VoiceUserProfileStore.saveAll(voiceStoredUsers)
    }

    static func reloadSeedDataForDebug() {
        VoiceUserProfileStore.saveAll(HiViviSeedData.voiceUserProfiles)
        OpalBridgeRoomChatStore.saveAll(HiViviSeedData.mapleQuartzChatRooms)
        WhisperMessageStore.saveAll(HiViviSeedData.whisperMessages)
        UserDefaults.standard.set(true, forKey: voiceSeedDidInitializeKey)
    }

    static func clearAllLocalData() {
        VoiceUserProfileStore.deleteAll()
        OpalBridgeRoomChatStore.deleteAll()
        WhisperMessageStore.deleteAll()
        UserDefaults.standard.removeObject(forKey: voiceSeedDidInitializeKey)
    }
}
