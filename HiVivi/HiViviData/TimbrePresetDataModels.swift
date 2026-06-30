import Foundation

struct TimbrePresetVoiceData: Identifiable, Codable, Equatable {
    let timbrePresetID: String
    var timbrePresetUserID: String
    var timbrePresetVoiceName: String
    var timbrePresetPitch: Double
    var timbrePresetSpeed: Double
    var timbrePresetNoiseReduction: Double
    var timbrePresetEmotion: Double
    var timbrePresetReverb: String
    var timbrePresetOriginalVoicePath: String
    var timbrePresetProcessedVoicePath: String
    var timbrePresetUpdatedAt: Date

    var id: String { timbrePresetID }
}

enum TimbrePresetVoiceStore {
    private static let timbrePresetStorageKey = "HiVivi.TimbrePresetVoiceStore.items"

    static func create(_ timbrePreset: TimbrePresetVoiceData) {
        var timbrePresets = readAll()
        guard !timbrePresets.contains(where: { $0.timbrePresetID == timbrePreset.timbrePresetID }) else {
            return
        }
        timbrePresets.append(timbrePreset)
        saveAll(timbrePresets)
    }

    static func read(id timbrePresetID: String) -> TimbrePresetVoiceData? {
        readAll().first { $0.timbrePresetID == timbrePresetID }
    }

    static func readCurrentPreset(userID timbreUserID: String) -> TimbrePresetVoiceData? {
        readAll()
            .filter { $0.timbrePresetUserID == timbreUserID }
            .sorted { $0.timbrePresetUpdatedAt > $1.timbrePresetUpdatedAt }
            .first
    }

    static func readAll() -> [TimbrePresetVoiceData] {
        ToneCacheStorageBox.load([TimbrePresetVoiceData].self, key: timbrePresetStorageKey) ?? []
    }

    static func update(_ timbrePreset: TimbrePresetVoiceData) {
        var timbrePresets = readAll()
        guard let timbreIndex = timbrePresets.firstIndex(where: { $0.timbrePresetID == timbrePreset.timbrePresetID }) else {
            return
        }
        timbrePresets[timbreIndex] = timbrePreset
        saveAll(timbrePresets)
    }

    static func upsert(_ timbrePreset: TimbrePresetVoiceData) {
        if read(id: timbrePreset.timbrePresetID) == nil {
            create(timbrePreset)
        } else {
            update(timbrePreset)
        }
    }

    static func delete(id timbrePresetID: String) {
        let timbrePresets = readAll().filter { $0.timbrePresetID != timbrePresetID }
        saveAll(timbrePresets)
    }

    static func deleteAll() {
        ToneCacheStorageBox.remove(key: timbrePresetStorageKey)
    }

    static func saveAll(_ timbrePresets: [TimbrePresetVoiceData]) {
        ToneCacheStorageBox.save(timbrePresets, key: timbrePresetStorageKey)
    }
}
