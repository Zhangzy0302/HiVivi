import SwiftUI

struct FrostGroveFriendListPage: View {
    let isGuestUser: Bool
    let onGuestLimit: () -> Void
    let onBack: () -> Void

    @State private var frostGroveFriendUsers: [VoiceUserProfileData] = []
    @State private var frostGroveFriendSelectedRoomID: String?
    @State private var frostGroveFriendShowsChatRoom = false

    init(
        isGuestUser: Bool = false,
        onGuestLimit: @escaping () -> Void = {},
        onBack: @escaping () -> Void
    ) {
        self.isGuestUser = isGuestUser
        self.onGuestLimit = onGuestLimit
        self.onBack = onBack
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }

            VStack(alignment: .leading, spacing: 0) {
                Button(action: onBack) {
                    Image("HIVV_back_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .frame(width: 58, height: 58)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 10)

                Text("My Friends")
                    .font(VoiceWhisperFontKit.bold(22))
                    .foregroundColor(.white)
                    .padding(.top, 13)

                VStack(spacing: 17) {
                    ForEach(frostGroveFriendUsers) { frostGroveFriendUser in
                        Button(action: {
                            frostGroveFriendOpenRoom(with: frostGroveFriendUser)
                        }) {
                            FrostGroveFriendListRow(user: frostGroveFriendUser)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    if frostGroveFriendUsers.isEmpty {
                        Text("No friends yet")
                            .font(VoiceWhisperFontKit.regular(13))
                            .foregroundColor(.white.opacity(0.62))
                            .frame(width: 350, height: 56)
                    }
                }
                .padding(.top, 22)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: 390, alignment: .leading)

            NavigationLink(
                destination: DriftCloudRoomVoiceChatPage(
                    opalBridgeRoomID: frostGroveFriendSelectedRoomID,
                    isGuestUser: isGuestUser,
                    onGuestLimit: onGuestLimit,
                    onBack: {
                        frostGroveFriendShowsChatRoom = false
                        frostGroveFriendSelectedRoomID = nil
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: Binding(
                    get: {
                        frostGroveFriendShowsChatRoom
                    },
                    set: { isActive in
                        frostGroveFriendShowsChatRoom = isActive
                        if !isActive {
                            frostGroveFriendSelectedRoomID = nil
                        }
                    }
                )
            ) {
                EmptyView()
            }
            .hidden()
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: frostGroveFriendReloadUsers)
    }

    private func frostGroveFriendReloadUsers() {
        guard let frostGroveCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID(),
              let frostGroveCurrentUser = VoiceUserProfileStore.read(id: frostGroveCurrentUserID) else {
            frostGroveFriendUsers = []
            return
        }

        let frostGroveBlockedIDs = Set(frostGroveCurrentUser.voiceUserBlockedIDs)
        let emberFieldUsersByID = Dictionary(
            uniqueKeysWithValues: VoiceUserProfileStore.readAll().map { ($0.voiceUserID, $0) }
        )

        frostGroveFriendUsers = frostGroveCurrentUser.voiceUserFriendIDs
            .filter { !frostGroveBlockedIDs.contains($0) }
            .compactMap { emberFieldUsersByID[$0] }
    }

    private func frostGroveFriendOpenRoom(with frostGroveFriendUser: VoiceUserProfileData) {
        guard let frostGroveCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            return
        }

        if let frostGroveExistingRoom = OpalBridgeRoomChatStore.readRooms(forUserID: frostGroveCurrentUserID).first(where: {
            $0.opalBridgeRoomUserIDs.contains(frostGroveFriendUser.voiceUserID)
        }) {
            frostGroveFriendSelectedRoomID = frostGroveExistingRoom.opalBridgeRoomID
            frostGroveFriendShowsChatRoom = true
            return
        }

        guard !isGuestUser else {
            onGuestLimit()
            return
        }

        let frostGroveNewRoom = OpalBridgeRoomChatData(
            opalBridgeRoomID: "frostGrove_room_\(UUID().uuidString)",
            opalBridgeRoomUserIDs: [frostGroveCurrentUserID, frostGroveFriendUser.voiceUserID],
            opalBridgeRoomLastMessageSentAt: Date(),
            opalBridgeRoomLastSenderID: frostGroveCurrentUserID,
            opalBridgeRoomLastMessageText: "",
            opalBridgeRoomUnreadMessageCount: 0
        )
        OpalBridgeRoomChatStore.create(frostGroveNewRoom)
        frostGroveFriendSelectedRoomID = frostGroveNewRoom.opalBridgeRoomID
        frostGroveFriendShowsChatRoom = true
    }
}

private struct FrostGroveFriendListRow: View {
    let user: VoiceUserProfileData

    var body: some View {
        HStack(spacing: 11) {
            VoiceImageSourceView(voiceImageAddress: user.voiceUserAvatar, contentMode: .fill)
                .frame(width: 58, height: 58)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(user.voiceUserName)
                    .font(VoiceWhisperFontKit.bold(17))
                    .foregroundColor(.white)

                Text("ID:\(user.voiceUserID)")
                    .font(VoiceWhisperFontKit.regular(13))
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "message.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(VoiceEchoStyleKit.voiceNeonGreen)
                .frame(width: 46, height: 46)
                .padding(.trailing, 13)
        }
        .padding(.leading, 11)
        .frame(width: 350, height: 73)
        .background(Color.white.opacity(0.11))
        .clipShape(Capsule())
    }
}

#Preview("FrostGrove Friend - List") {
    let _ = VoiceWhisperFontKit.registerFonts()
    FrostGroveFriendListPage(onBack: {})
}
