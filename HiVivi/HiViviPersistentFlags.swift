import Foundation

enum VoiceEchoPersistentFlags {
    static let whisperAgreementAcceptedKey = "HiVivi.VoiceEchoPersistentFlags.whisperAgreementAccepted"
    static let sonicEULAAcceptedKey = "HiVivi.VoiceEchoPersistentFlags.sonicEULAAccepted"

    static var whisperAgreementAccepted: Bool {
        get {
            UserDefaults.standard.object(forKey: whisperAgreementAcceptedKey) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: whisperAgreementAcceptedKey)
        }
    }

    static var sonicEULAAccepted: Bool {
        get {
            UserDefaults.standard.object(forKey: sonicEULAAcceptedKey) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sonicEULAAcceptedKey)
        }
    }
}
