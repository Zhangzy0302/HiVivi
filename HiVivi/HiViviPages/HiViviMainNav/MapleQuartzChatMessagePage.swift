import SwiftUI

struct MapleQuartzChatMessagePage: View {
    let onOpenChatRoom: (String) -> Void
    let onFriends: () -> Void
    let onSearchUser: () -> Void
    let onFriendRequests: () -> Void
    let onBlacklist: () -> Void
    @State private var mapleQuartzRoomVisibleItems: [MapleQuartzChatRoomListItem] = []

    init(
        onOpenChatRoom: @escaping (String) -> Void = { _ in },
        onFriends: @escaping () -> Void = {},
        onSearchUser: @escaping () -> Void = {},
        onFriendRequests: @escaping () -> Void = {},
        onBlacklist: @escaping () -> Void = {}
    ) {
        self.onOpenChatRoom = onOpenChatRoom
        self.onFriends = onFriends
        self.onSearchUser = onSearchUser
        self.onFriendRequests = onFriendRequests
        self.onBlacklist = onBlacklist
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Chat")
                            .font(VoiceWhisperFontKit.bold(17))
                            .foregroundColor(.white)

                        Spacer()

                    }
                    .padding(.top, 10)

                    Button(action: onSearchUser) {
                        MapleQuartzChatSearchBar()
                    }
                    .buttonStyle(PlainButtonStyle())
                        .padding(.top, 13)

                    HStack(spacing: 0) {
                        Button(action: onFriends) {
                            MapleQuartzChatToolButton(iconName: "HIVV_friends", title: "Friends")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Button(action: onFriendRequests) {
                            MapleQuartzChatToolButton(iconName: "HIVV_add_friend", title: "Add Friend")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                        Button(action: onBlacklist) {
                            MapleQuartzChatToolButton(iconName: "HIVV_blacklist", title: "Blacklist")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 31)
                    .padding(.top, 24)

                    VStack(spacing: 14) {
                        ForEach(mapleQuartzRoomVisibleItems) { mapleQuartzRoomItem in
                            Button(action: {
                                onOpenChatRoom(mapleQuartzRoomItem.roomID)
                            }) {
                                MapleQuartzChatMessageRow(item: mapleQuartzRoomItem)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top, 25)
                    .padding(.bottom, 112)
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear(perform: mapleQuartzRoomReloadVisibleRooms)
    }

    private func mapleQuartzRoomReloadVisibleRooms() {
        mapleQuartzRoomVisibleItems = MapleQuartzChatRoomListBuilder.visibleItems()
    }
}

enum MapleQuartzChatRoomListBuilder {
    static func visibleItems() -> [MapleQuartzChatRoomListItem] {
        guard let mapleQuartzRoomCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID(),
              let mapleQuartzRoomCurrentUser = VoiceUserProfileStore.read(id: mapleQuartzRoomCurrentUserID) else {
            return []
        }

        let mapleQuartzRoomBlockedIDs = Set(mapleQuartzRoomCurrentUser.voiceUserBlockedIDs)
        let mapleQuartzRoomUsersByID = Dictionary(
            uniqueKeysWithValues: VoiceUserProfileStore.readAll().map { ($0.voiceUserID, $0) }
        )

        return OpalBridgeRoomChatStore
            .readRooms(forUserID: mapleQuartzRoomCurrentUserID)
            .filter { mapleQuartzRoomData in
                let mapleQuartzRoomOtherUserIDs = mapleQuartzRoomData.opalBridgeRoomUserIDs.filter { $0 != mapleQuartzRoomCurrentUserID }
                return mapleQuartzRoomOtherUserIDs.allSatisfy { !mapleQuartzRoomBlockedIDs.contains($0) }
            }
            .sorted { $0.opalBridgeRoomLastMessageSentAt > $1.opalBridgeRoomLastMessageSentAt }
            .enumerated()
            .map { mapleQuartzRoomIndex, mapleQuartzRoomData in
                let mapleQuartzRoomOtherUserID = mapleQuartzRoomData.opalBridgeRoomUserIDs.first { $0 != mapleQuartzRoomCurrentUserID }
                let mapleQuartzRoomOtherUser = mapleQuartzRoomOtherUserID.flatMap { mapleQuartzRoomUsersByID[$0] }

                return MapleQuartzChatRoomListItem(
                    roomID: mapleQuartzRoomData.opalBridgeRoomID,
                    avatarAddress: mapleQuartzRoomOtherUser?.voiceUserAvatar ?? "",
                    avatarSeed: mapleQuartzRoomIndex,
                    displayName: mapleQuartzRoomOtherUser?.voiceUserName ?? "Unknown Voice",
                    lastMessageText: mapleQuartzRoomData.opalBridgeRoomLastMessageText,
                    sentAt: mapleQuartzRoomData.opalBridgeRoomLastMessageSentAt,
                    unreadCount: mapleQuartzRoomData.opalBridgeRoomUnreadMessageCount
                )
            }
    }
}

struct MapleQuartzChatRoomListItem: Identifiable, Equatable {
    let roomID: String
    let avatarAddress: String
    let avatarSeed: Int
    let displayName: String
    let lastMessageText: String
    let sentAt: Date
    let unreadCount: Int

    var id: String { roomID }
}

private struct MapleQuartzChatSearchBar: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text("Search")
                .font(VoiceWhisperFontKit.regular(12))
                .foregroundColor(.white.opacity(0.42))

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct MapleQuartzChatToolButton: View {
    let iconName: String
    let title: String

    var body: some View {
        VStack(spacing: 7) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            Text(title)
                .font(VoiceWhisperFontKit.regular(10))
                .foregroundColor(.white)
        }
        .frame(width: 92)
        .contentShape(Rectangle())
    }
}

struct MapleQuartzChatMessageRow: View {
    let item: MapleQuartzChatRoomListItem

    var body: some View {
        HStack(spacing: 9) {
            VoiceImageSourceView(voiceImageAddress: item.avatarAddress, contentMode: .fill)
                .frame(width: 48, height: 48)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(item.displayName)
                    .font(VoiceWhisperFontKit.bold(14))
                    .foregroundColor(.white)

                Text(item.lastMessageText)
                    .font(VoiceWhisperFontKit.regular(11))
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(MapleQuartzChatTimeFormatter.chatTimeText(from: item.sentAt))
                    .font(VoiceWhisperFontKit.regular(9))
                    .foregroundColor(.white.opacity(0.66))

                if item.unreadCount > 0 {
                    Text("\(min(item.unreadCount, 99))")
                        .font(VoiceWhisperFontKit.bold(9))
                        .foregroundColor(.white)
                        .frame(width: 14, height: 14)
                        .background(Color(red: 1.0, green: 0.24, blue: 0.31))
                        .clipShape(Circle())
                }
            }
            .padding(.trailing, 15)
        }
        .padding(.leading, 8)
        .frame(height: 58)
        .background(Color.white.opacity(0.11))
        .clipShape(Capsule())
    }
}

private enum MapleQuartzChatTimeFormatter {
    private static let mapleQuartzRoomCalendar = Calendar.current

    static func chatTimeText(from mapleQuartzRoomDate: Date) -> String {
        if mapleQuartzRoomCalendar.isDateInToday(mapleQuartzRoomDate) {
            return mapleQuartzRoomHourMinuteFormatter.string(from: mapleQuartzRoomDate)
        }

        if mapleQuartzRoomCalendar.isDateInYesterday(mapleQuartzRoomDate) {
            return "Yesterday"
        }

        return mapleQuartzRoomMonthDayFormatter.string(from: mapleQuartzRoomDate)
    }

    private static let mapleQuartzRoomHourMinuteFormatter: DateFormatter = {
        let mapleQuartzRoomFormatter = DateFormatter()
        mapleQuartzRoomFormatter.dateFormat = "HH:mm"
        return mapleQuartzRoomFormatter
    }()

    private static let mapleQuartzRoomMonthDayFormatter: DateFormatter = {
        let mapleQuartzRoomFormatter = DateFormatter()
        mapleQuartzRoomFormatter.dateFormat = "MM/dd"
        return mapleQuartzRoomFormatter
    }()
}
