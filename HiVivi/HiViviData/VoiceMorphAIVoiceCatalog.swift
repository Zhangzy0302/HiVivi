import Foundation

struct VoiceMorphAIVoicePreset: Identifiable, Equatable {
    let id: String
    let name: String
    let avatarName: String
    let fileName: String
}

enum VoiceMorphAIVoiceCatalog {
    static let all: [VoiceMorphAIVoicePreset] = [
        VoiceMorphAIVoicePreset(id: "cool_girl", name: "Cool Girl", avatarName: "HIVV_AI_Voice_0", fileName: "HIVV_voice_woman_0"),
        VoiceMorphAIVoicePreset(id: "mommy_voice", name: "Mommy Voice", avatarName: "HIVV_AI_Voice_1", fileName: "HIVV_voice_woman_1"),
        VoiceMorphAIVoicePreset(id: "soft_girl", name: "Soft Girl", avatarName: "HIVV_AI_Voice_2", fileName: "HIVV_voice_woman_2"),
        VoiceMorphAIVoicePreset(id: "anime_girl", name: "Anime Girl", avatarName: "HIVV_AI_Voice_3", fileName: "HIVV_voice_woman_3"),
        VoiceMorphAIVoicePreset(id: "ceo_voice", name: "CEO Voice", avatarName: "HIVV_AI_Voice_4", fileName: "HIVV_voice_man_0"),
        VoiceMorphAIVoicePreset(id: "gamer_voice", name: "Gamer Voice", avatarName: "HIVV_AI_Voice_5", fileName: "HIVV_voice_man_2"),
        VoiceMorphAIVoicePreset(id: "deep_voice", name: "Deep Voice", avatarName: "HIVV_AI_Voice_6", fileName: "HIVV_voice_man_1"),
        VoiceMorphAIVoicePreset(id: "anime_boy", name: "Anime Boy", avatarName: "HIVV_AI_Voice_7", fileName: "HIVV_voice_man_3")
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
