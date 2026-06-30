import Foundation

enum HiViviSeedDate {
    static func make(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        var voiceComponents = DateComponents()
        voiceComponents.calendar = Calendar(identifier: .gregorian)
        voiceComponents.year = year
        voiceComponents.month = month
        voiceComponents.day = day
        voiceComponents.hour = hour
        voiceComponents.minute = minute
        return voiceComponents.date ?? Date()
    }
}

enum HiViviSeedData {
    static let voiceUserProfiles: [VoiceUserProfileData] = [
        VoiceUserProfileData(
            voiceUserID: "HIVVQ8M2LA",
            voiceUserEmail: "hivivi@gmail.com",
            voiceUserPassword: "123456",
            voiceUserAvatar: "HIVVI_ava_0",
            voiceUserName: "Charles",
            voiceUserBirthday: HiViviSeedDate.make(1998, 3, 12),
            voiceUserLocation: "Los Angeles",
            voiceUserGender: .male,
            voiceUserFriendIDs: ["HIVV7NPR4K", "HIVVZ2H6YD"],
            voiceUserFriendRequestIDs: ["HIVVB5T9CX"],
            voiceUserBlockedIDs: [],
            voiceUserPurchasedAIVoiceIDs: [],
            voiceUserCoinCount: 0,
            voiceUserIsGuest: false
        ),
        VoiceUserProfileData(
            voiceUserID: "HIVV7NPR4K",
            voiceUserEmail: "dennis@hivivi.local",
            voiceUserPassword: "123456",
            voiceUserAvatar: "HIVVI_ava_1",
            voiceUserName: "Dennis",
            voiceUserBirthday: HiViviSeedDate.make(1996, 8, 24),
            voiceUserLocation: "New York",
            voiceUserGender: .male,
            voiceUserFriendIDs: ["HIVVQ8M2LA", "HIVVB5T9CX", "HIVV3KQ8MN"],
            voiceUserFriendRequestIDs: [],
            voiceUserBlockedIDs: [],
            voiceUserPurchasedAIVoiceIDs: [],
            voiceUserCoinCount: 180,
            voiceUserIsGuest: false
        ),
        VoiceUserProfileData(
            voiceUserID: "HIVVB5T9CX",
            voiceUserEmail: "scott@hivivi.local",
            voiceUserPassword: "123456",
            voiceUserAvatar: "HIVVI_ava_2",
            voiceUserName: "Scott",
            voiceUserBirthday: HiViviSeedDate.make(1999, 11, 6),
            voiceUserLocation: "Chicago",
            voiceUserGender: .male,
            voiceUserFriendIDs: ["HIVV7NPR4K", "HIVVL9W4RA"],
            voiceUserFriendRequestIDs: [],
            voiceUserBlockedIDs: [],
            voiceUserPurchasedAIVoiceIDs: [],
            voiceUserCoinCount: 320,
            voiceUserIsGuest: false
        ),
        VoiceUserProfileData(
            voiceUserID: "HIVVZ2H6YD",
            voiceUserEmail: "piper@hivivi.local",
            voiceUserPassword: "123456",
            voiceUserAvatar: "HIVVI_ava_3",
            voiceUserName: "Piper",
            voiceUserBirthday: HiViviSeedDate.make(2001, 5, 18),
            voiceUserLocation: "Seattle",
            voiceUserGender: .female,
            voiceUserFriendIDs: ["HIVVQ8M2LA", "HIVV3KQ8MN", "HIVVL9W4RA"],
            voiceUserFriendRequestIDs: [],
            voiceUserBlockedIDs: [],
            voiceUserPurchasedAIVoiceIDs: [],
            voiceUserCoinCount: 560,
            voiceUserIsGuest: false
        ),
        VoiceUserProfileData(
            voiceUserID: "HIVV3KQ8MN",
            voiceUserEmail: "jeanne@hivivi.local",
            voiceUserPassword: "123456",
            voiceUserAvatar: "HIVVI_ava_4",
            voiceUserName: "Jeanne",
            voiceUserBirthday: HiViviSeedDate.make(1997, 2, 27),
            voiceUserLocation: "Austin",
            voiceUserGender: .female,
            voiceUserFriendIDs: ["HIVV7NPR4K", "HIVVZ2H6YD", "HIVVL9W4RA"],
            voiceUserFriendRequestIDs: [],
            voiceUserBlockedIDs: [],
            voiceUserPurchasedAIVoiceIDs: [],
            voiceUserCoinCount: 410,
            voiceUserIsGuest: false
        ),
        VoiceUserProfileData(
            voiceUserID: "HIVVL9W4RA",
            voiceUserEmail: "alison@hivivi.local",
            voiceUserPassword: "123456",
            voiceUserAvatar: "HIVVI_ava_5",
            voiceUserName: "Alison",
            voiceUserBirthday: HiViviSeedDate.make(2000, 9, 9),
            voiceUserLocation: "San Francisco",
            voiceUserGender: .female,
            voiceUserFriendIDs: ["HIVVB5T9CX", "HIVVZ2H6YD", "HIVV3KQ8MN"],
            voiceUserFriendRequestIDs: [],
            voiceUserBlockedIDs: [],
            voiceUserPurchasedAIVoiceIDs: [],
            voiceUserCoinCount: 99,
            voiceUserIsGuest: false
        )
    ]

    static let mapleQuartzChatRooms: [OpalBridgeRoomChatData] = [
        OpalBridgeRoomChatData(
            opalBridgeRoomID: "room_charles_dennis_001",
            opalBridgeRoomUserIDs: ["HIVVQ8M2LA", "HIVV7NPR4K"],
            opalBridgeRoomLastMessageSentAt: HiViviSeedDate.make(2026, 6, 18, 9, 41),
            opalBridgeRoomLastSenderID: "HIVV7NPR4K",
            opalBridgeRoomLastMessageText: "Your voice is very pleasant.",
            opalBridgeRoomUnreadMessageCount: 1
        )
    ]

    static let whisperMessages: [WhisperMessageData] = [
        WhisperMessageData(
            whisperMessageID: "message_charles_dennis_001",
            whisperRoomID: "room_charles_dennis_001",
            whisperSenderID: "HIVV7NPR4K",
            whisperTextMessage: "Your voice is very pleasant.",
            whisperVoiceFilePath: "",
            whisperVoiceDuration: 0,
            whisperSentAt: HiViviSeedDate.make(2026, 6, 18, 9, 41)
        )
    ]
}
