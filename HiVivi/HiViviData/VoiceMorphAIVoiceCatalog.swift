import AVFoundation
import Foundation

struct VoiceMorphAIVoicePreset: Identifiable, Equatable {
    let id: String
    let name: String
    let avatarName: String
    let fileName: String
    let audioConfig: VoiceMorphAudioConfig
}

enum VoiceMorphAIVoiceCatalog {
    static let all: [VoiceMorphAIVoicePreset] = [
        VoiceMorphAIVoicePreset(
            id: "cool_girl",
            name: "Cool Girl",
            avatarName: "HIVV_AI_Voice_0",
            fileName: "HIVV_voice_woman_0",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.76,
                voiceMorphSpeed: 0.52,
                voiceMorphNoiseReduction: 0.56,
                voiceMorphEmotion: 0.82,
                voiceMorphReverb: "Room"
            )
        ),
        VoiceMorphAIVoicePreset(
            id: "mommy_voice",
            name: "Mommy Voice",
            avatarName: "HIVV_AI_Voice_1",
            fileName: "HIVV_voice_woman_1",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.55,
                voiceMorphSpeed: 0.28,
                voiceMorphNoiseReduction: 0.38,
                voiceMorphEmotion: 0.36,
                voiceMorphReverb: "Room"
            )
        ),
        VoiceMorphAIVoicePreset(
            id: "soft_girl",
            name: "Soft Girl",
            avatarName: "HIVV_AI_Voice_2",
            fileName: "HIVV_voice_woman_2",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.70,
                voiceMorphSpeed: 0.34,
                voiceMorphNoiseReduction: 0.66,
                voiceMorphEmotion: 0.64,
                voiceMorphReverb: "Room"
            )
        ),
        VoiceMorphAIVoicePreset(
            id: "anime_girl",
            name: "Anime Girl",
            avatarName: "HIVV_AI_Voice_3",
            fileName: "HIVV_voice_woman_3",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.94,
                voiceMorphSpeed: 0.66,
                voiceMorphNoiseReduction: 0.54,
                voiceMorphEmotion: 0.94,
                voiceMorphReverb: "Ethereal",
                voiceMorphDelayTime: 0.04,
                voiceMorphDelayFeedback: 3,
                voiceMorphDelayWetDryMix: 3
            )
        ),
        VoiceMorphAIVoicePreset(
            id: "ceo_voice",
            name: "CEO Voice",
            avatarName: "HIVV_AI_Voice_4",
            fileName: "HIVV_voice_man_0",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.24,
                voiceMorphSpeed: 0.38,
                voiceMorphNoiseReduction: 0.24,
                voiceMorphEmotion: 0.46,
                voiceMorphReverb: "Concert"
            )
        ),
        VoiceMorphAIVoicePreset(
            id: "gamer_voice",
            name: "Gamer Voice",
            avatarName: "HIVV_AI_Voice_5",
            fileName: "HIVV_voice_man_2",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.36,
                voiceMorphSpeed: 0.70,
                voiceMorphNoiseReduction: 0.34,
                voiceMorphEmotion: 0.72,
                voiceMorphReverb: "KTV",
                voiceMorphDistortionPreset: .speechRadioTower,
                voiceMorphDistortionWetDryMix: 8,
                voiceMorphDelayTime: 0.03,
                voiceMorphDelayFeedback: 2,
                voiceMorphDelayWetDryMix: 2
            )
        ),
        VoiceMorphAIVoicePreset(
            id: "deep_voice",
            name: "Deep Voice",
            avatarName: "HIVV_AI_Voice_6",
            fileName: "HIVV_voice_man_1",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.08,
                voiceMorphSpeed: 0.24,
                voiceMorphNoiseReduction: 0.18,
                voiceMorphEmotion: 0.30,
                voiceMorphReverb: "Concert"
            )
        ),
        VoiceMorphAIVoicePreset(
            id: "anime_boy",
            name: "Anime Boy",
            avatarName: "HIVV_AI_Voice_7",
            fileName: "HIVV_voice_man_3",
            audioConfig: VoiceMorphAudioConfig(
                voiceMorphPitch: 0.78,
                voiceMorphSpeed: 0.64,
                voiceMorphNoiseReduction: 0.50,
                voiceMorphEmotion: 0.86,
                voiceMorphReverb: "Ethereal",
                voiceMorphDelayTime: 0.035,
                voiceMorphDelayFeedback: 3,
                voiceMorphDelayWetDryMix: 3
            )
        )
    ]

    static let homeFeaturedIDs = ["cool_girl", "mommy_voice", "ceo_voice", "anime_boy"]

    static var homeFeatured: [VoiceMorphAIVoicePreset] {
        homeFeaturedIDs.compactMap { voiceID in
            all.first { $0.id == voiceID }
        }
    }

    static func voiceMorphPreset(id voiceID: String) -> VoiceMorphAIVoicePreset? {
        all.first { $0.id == voiceID }
    }

    static func voiceMorphAudioURL(for voicePreset: VoiceMorphAIVoicePreset) -> URL? {
        Bundle.main.url(forResource: voicePreset.fileName, withExtension: "mp3")
            ?? Bundle.main.url(forResource: voicePreset.fileName, withExtension: "mp3", subdirectory: "VoiceFiles")
    }
}
