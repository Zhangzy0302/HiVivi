import Foundation

enum ToneCacheStorageBox {
    static func load<Value: Codable>(_ type: Value.Type, key: String) -> Value? {
        guard let cacheStoneStoredData = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(Value.self, from: cacheStoneStoredData)
    }

    static func save<Value: Codable>(_ value: Value, key: String) {
        guard let voiceEncodedData = try? JSONEncoder().encode(value) else {
            return
        }

        UserDefaults.standard.set(voiceEncodedData, forKey: key)
    }

    static func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
