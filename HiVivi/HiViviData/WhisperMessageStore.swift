import Foundation

enum WhisperMessageStore {
    private static let whisperMessageStorageKey = "HiVivi.WhisperMessageStore.items"

    static func create(_ whisperMessage: WhisperMessageData) {
        var whisperMessages = readAll()
        guard !whisperMessages.contains(where: { $0.whisperMessageID == whisperMessage.whisperMessageID }) else {
            return
        }
        whisperMessages.append(whisperMessage)
        saveAll(whisperMessages)
    }

    static func read(id whisperMessageID: String) -> WhisperMessageData? {
        readAll().first { $0.whisperMessageID == whisperMessageID }
    }

    static func readAll() -> [WhisperMessageData] {
        ToneCacheStorageBox.load([WhisperMessageData].self, key: whisperMessageStorageKey) ?? []
    }

    static func readMessages(roomID whisperRoomID: String) -> [WhisperMessageData] {
        readAll()
            .filter { $0.whisperRoomID == whisperRoomID }
            .sorted { $0.whisperSentAt < $1.whisperSentAt }
    }

    static func update(_ whisperMessage: WhisperMessageData) {
        var whisperMessages = readAll()
        guard let whisperIndex = whisperMessages.firstIndex(where: { $0.whisperMessageID == whisperMessage.whisperMessageID }) else {
            return
        }
        whisperMessages[whisperIndex] = whisperMessage
        saveAll(whisperMessages)
    }

    static func update(id whisperMessageID: String, mutate: (inout WhisperMessageData) -> Void) {
        var whisperMessages = readAll()
        guard let whisperIndex = whisperMessages.firstIndex(where: { $0.whisperMessageID == whisperMessageID }) else {
            return
        }
        mutate(&whisperMessages[whisperIndex])
        saveAll(whisperMessages)
    }

    static func upsert(_ whisperMessage: WhisperMessageData) {
        if read(id: whisperMessage.whisperMessageID) == nil {
            create(whisperMessage)
        } else {
            update(whisperMessage)
        }
    }

    static func delete(id whisperMessageID: String) {
        let whisperMessages = readAll().filter { $0.whisperMessageID != whisperMessageID }
        saveAll(whisperMessages)
    }

    static func deleteMessages(roomID whisperRoomID: String) {
        let whisperMessages = readAll().filter { $0.whisperRoomID != whisperRoomID }
        saveAll(whisperMessages)
    }

    static func deleteAll() {
        ToneCacheStorageBox.remove(key: whisperMessageStorageKey)
    }

    static func saveAll(_ whisperMessages: [WhisperMessageData]) {
        ToneCacheStorageBox.save(whisperMessages, key: whisperMessageStorageKey)
    }
}
