import Foundation

enum VoiceUserGender: String, Codable, Equatable {
    case female
    case male
    case unknown
}

struct VoiceUserProfileData: Identifiable, Codable, Equatable {
    let voiceUserID: String
    var voiceUserEmail: String
    var voiceUserPassword: String
    var voiceUserAvatar: String
    var voiceUserName: String
    var voiceUserBirthday: Date
    var voiceUserLocation: String
    var voiceUserGender: VoiceUserGender
    var voiceUserFriendIDs: [String]
    var voiceUserFriendRequestIDs: [String]
    var voiceUserBlockedIDs: [String]
    var voiceUserPurchasedAIVoiceIDs: [String]
    var voiceUserCoinCount: Int
    var voiceUserIsGuest: Bool

    var id: String { voiceUserID }

    init(
        voiceUserID: String,
        voiceUserEmail: String,
        voiceUserPassword: String,
        voiceUserAvatar: String,
        voiceUserName: String,
        voiceUserBirthday: Date,
        voiceUserLocation: String,
        voiceUserGender: VoiceUserGender,
        voiceUserFriendIDs: [String],
        voiceUserFriendRequestIDs: [String],
        voiceUserBlockedIDs: [String],
        voiceUserPurchasedAIVoiceIDs: [String] = [],
        voiceUserCoinCount: Int,
        voiceUserIsGuest: Bool
    ) {
        self.voiceUserID = voiceUserID
        self.voiceUserEmail = voiceUserEmail
        self.voiceUserPassword = voiceUserPassword
        self.voiceUserAvatar = voiceUserAvatar
        self.voiceUserName = voiceUserName
        self.voiceUserBirthday = voiceUserBirthday
        self.voiceUserLocation = voiceUserLocation
        self.voiceUserGender = voiceUserGender
        self.voiceUserFriendIDs = voiceUserFriendIDs
        self.voiceUserFriendRequestIDs = voiceUserFriendRequestIDs
        self.voiceUserBlockedIDs = voiceUserBlockedIDs
        self.voiceUserPurchasedAIVoiceIDs = voiceUserPurchasedAIVoiceIDs
        self.voiceUserCoinCount = voiceUserCoinCount
        self.voiceUserIsGuest = voiceUserIsGuest
    }

    enum CodingKeys: String, CodingKey {
        case voiceUserID
        case voiceUserEmail
        case voiceUserPassword
        case voiceUserAvatar
        case voiceUserName
        case voiceUserBirthday
        case voiceUserLocation
        case voiceUserGender
        case voiceUserFriendIDs
        case voiceUserFriendRequestIDs
        case voiceUserBlockedIDs
        case voiceUserPurchasedAIVoiceIDs
        case voiceUserCoinCount
        case voiceUserIsGuest
    }

    init(from decoder: Decoder) throws {
        let voiceContainer = try decoder.container(keyedBy: CodingKeys.self)
        voiceUserID = try voiceContainer.decode(String.self, forKey: .voiceUserID)
        voiceUserEmail = try voiceContainer.decode(String.self, forKey: .voiceUserEmail)
        voiceUserPassword = try voiceContainer.decode(String.self, forKey: .voiceUserPassword)
        voiceUserAvatar = try voiceContainer.decode(String.self, forKey: .voiceUserAvatar)
        voiceUserName = try voiceContainer.decode(String.self, forKey: .voiceUserName)
        voiceUserBirthday = try voiceContainer.decode(Date.self, forKey: .voiceUserBirthday)
        voiceUserLocation = try voiceContainer.decode(String.self, forKey: .voiceUserLocation)
        voiceUserGender = try voiceContainer.decode(VoiceUserGender.self, forKey: .voiceUserGender)
        voiceUserFriendIDs = try voiceContainer.decode([String].self, forKey: .voiceUserFriendIDs)
        voiceUserFriendRequestIDs = try voiceContainer.decode([String].self, forKey: .voiceUserFriendRequestIDs)
        voiceUserBlockedIDs = try voiceContainer.decode([String].self, forKey: .voiceUserBlockedIDs)
        voiceUserPurchasedAIVoiceIDs = try voiceContainer.decodeIfPresent([String].self, forKey: .voiceUserPurchasedAIVoiceIDs) ?? []
        voiceUserCoinCount = try voiceContainer.decode(Int.self, forKey: .voiceUserCoinCount)
        voiceUserIsGuest = try voiceContainer.decode(Bool.self, forKey: .voiceUserIsGuest)
    }
}

struct OpalBridgeRoomChatData: Identifiable, Codable, Equatable {
    let opalBridgeRoomID: String
    var opalBridgeRoomUserIDs: [String]
    var opalBridgeRoomLastMessageSentAt: Date
    var opalBridgeRoomLastSenderID: String
    var opalBridgeRoomLastMessageText: String
    var opalBridgeRoomUnreadMessageCount: Int

    var id: String { opalBridgeRoomID }
}

struct WhisperMessageData: Identifiable, Codable, Equatable {
    let whisperMessageID: String
    var whisperRoomID: String
    var whisperSenderID: String
    var whisperTextMessage: String
    var whisperVoiceFilePath: String
    var whisperVoiceDuration: TimeInterval
    var whisperSentAt: Date

    var id: String { whisperMessageID }
}
