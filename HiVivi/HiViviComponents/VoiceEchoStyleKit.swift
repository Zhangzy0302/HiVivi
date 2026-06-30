import SwiftUI

enum VoiceEchoStyleKit {
    static let voiceDefaultAvatarName = "HIVV_default_ava"

    static let voiceShadowPanel = Color(red: 0.20, green: 0.20, blue: 0.25)
    static let voiceMossPanel = Color(red: 0.23, green: 0.31, blue: 0.20)
    static let voiceNeonGreen = Color(red: 0.57, green: 1.0, blue: 0.43)
    static let prismTrailPulsePurple = Color(red: 0.68, green: 0.42, blue: 1.0)
    static let styleBrookSoftPurple = Color(red: 0.66, green: 0.43, blue: 1.0)
    static let toneLimeGlow = Color(red: 189 / 255, green: 254 / 255, blue: 117 / 255)
    static let toneMintGlow = Color(red: 115 / 255, green: 253 / 255, blue: 159 / 255)

    static let toneActionGradient = LinearGradient(
        colors: [
            toneLimeGlow,
            toneMintGlow
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
