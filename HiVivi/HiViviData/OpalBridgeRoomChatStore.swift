import Foundation

enum OpalBridgeRoomChatStore {
    private static let opalBridgeRoomStorageKey = "HiVivi.OpalBridgeRoomChatStore.items"

    static func create(_ opalBridgeRoom: OpalBridgeRoomChatData) {
        var opalBridgeRooms = readAll()
        guard !opalBridgeRooms.contains(where: { $0.opalBridgeRoomID == opalBridgeRoom.opalBridgeRoomID }) else {
            return
        }
        opalBridgeRooms.append(opalBridgeRoom)
        saveAll(opalBridgeRooms)
    }

    static func read(id opalBridgeRoomID: String) -> OpalBridgeRoomChatData? {
        readAll().first { $0.opalBridgeRoomID == opalBridgeRoomID }
    }

    static func readAll() -> [OpalBridgeRoomChatData] {
        ToneCacheStorageBox.load([OpalBridgeRoomChatData].self, key: opalBridgeRoomStorageKey) ?? []
    }

    static func readRooms(forUserID emberFieldUserID: String) -> [OpalBridgeRoomChatData] {
        readAll().filter { $0.opalBridgeRoomUserIDs.contains(emberFieldUserID) }
    }

    static func update(_ opalBridgeRoom: OpalBridgeRoomChatData) {
        var opalBridgeRooms = readAll()
        guard let opalBridgeIndex = opalBridgeRooms.firstIndex(where: { $0.opalBridgeRoomID == opalBridgeRoom.opalBridgeRoomID }) else {
            return
        }
        opalBridgeRooms[opalBridgeIndex] = opalBridgeRoom
        saveAll(opalBridgeRooms)
    }

    static func update(id opalBridgeRoomID: String, mutate: (inout OpalBridgeRoomChatData) -> Void) {
        var opalBridgeRooms = readAll()
        guard let opalBridgeIndex = opalBridgeRooms.firstIndex(where: { $0.opalBridgeRoomID == opalBridgeRoomID }) else {
            return
        }
        mutate(&opalBridgeRooms[opalBridgeIndex])
        saveAll(opalBridgeRooms)
    }

    static func upsert(_ opalBridgeRoom: OpalBridgeRoomChatData) {
        if read(id: opalBridgeRoom.opalBridgeRoomID) == nil {
            create(opalBridgeRoom)
        } else {
            update(opalBridgeRoom)
        }
    }

    static func delete(id opalBridgeRoomID: String) {
        let opalBridgeRooms = readAll().filter { $0.opalBridgeRoomID != opalBridgeRoomID }
        saveAll(opalBridgeRooms)
    }

    static func deleteAll() {
        ToneCacheStorageBox.remove(key: opalBridgeRoomStorageKey)
    }

    static func saveAll(_ opalBridgeRooms: [OpalBridgeRoomChatData]) {
        ToneCacheStorageBox.save(opalBridgeRooms, key: opalBridgeRoomStorageKey)
    }
}
