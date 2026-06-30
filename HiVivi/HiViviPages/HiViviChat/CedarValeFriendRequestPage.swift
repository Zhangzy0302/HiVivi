import SwiftUI

struct CedarValeFriendRequestPage: View {
    let isGuestUser: Bool
    let onGuestLimit: () -> Void
    let onBack: () -> Void

    @State private var cedarValeRequestUsers: [VoiceUserProfileData] = []
    @State private var cedarValeRequestPendingUser: VoiceUserProfileData?

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

                Text("Request to add you as a friend:")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.white)
                    .padding(.top, 13)

                VStack(spacing: 14) {
                    ForEach(cedarValeRequestUsers) { cedarValeRequestUser in
                        CedarValeFriendRequestRow(
                            user: cedarValeRequestUser,
                            onAgree: {
                                guard !isGuestUser else {
                                    onGuestLimit()
                                    return
                                }
                                cedarValeRequestPendingUser = cedarValeRequestUser
                            }
                        )
                    }

                    if cedarValeRequestUsers.isEmpty {
                        Text("No friend requests")
                            .font(VoiceWhisperFontKit.regular(13))
                            .foregroundColor(.white.opacity(0.62))
                            .frame(width: 350, height: 56)
                    }
                }
                .padding(.top, 21)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: 390, alignment: .leading)

            if let cedarValeRequestPendingUser {
                KineticBreezeFriendAgreeDialog(
                    userName: cedarValeRequestPendingUser.voiceUserName,
                    onDismiss: {
                        self.cedarValeRequestPendingUser = nil
                    },
                    onDisagree: {
                        cedarValeRequestDisagree(with: cedarValeRequestPendingUser)
                        self.cedarValeRequestPendingUser = nil
                    },
                    onAgree: {
                        cedarValeRequestAgree(with: cedarValeRequestPendingUser)
                        self.cedarValeRequestPendingUser = nil
                    }
                )
                .zIndex(20)
                .transition(.opacity)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: cedarValeRequestReloadUsers)
        .animation(.easeOut(duration: 0.24), value: cedarValeRequestPendingUser)
    }

    private func cedarValeRequestReloadUsers() {
        guard let cedarValeCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID(),
              let cedarValeCurrentUser = VoiceUserProfileStore.read(id: cedarValeCurrentUserID) else {
            cedarValeRequestUsers = []
            return
        }

        let cedarValeBlockedIDs = Set(cedarValeCurrentUser.voiceUserBlockedIDs)
        let emberFieldUsersByID = Dictionary(
            uniqueKeysWithValues: VoiceUserProfileStore.readAll().map { ($0.voiceUserID, $0) }
        )

        cedarValeRequestUsers = cedarValeCurrentUser.voiceUserFriendRequestIDs
            .filter { !cedarValeBlockedIDs.contains($0) }
            .compactMap { emberFieldUsersByID[$0] }
    }

    private func cedarValeRequestAgree(with cedarValeRequestUser: VoiceUserProfileData) {
        guard let cedarValeCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            return
        }

        VoiceUserProfileStore.update(id: cedarValeCurrentUserID) { cedarValeCurrentUser in
            cedarValeCurrentUser.voiceUserFriendRequestIDs.removeAll { $0 == cedarValeRequestUser.voiceUserID }
            if !cedarValeCurrentUser.voiceUserFriendIDs.contains(cedarValeRequestUser.voiceUserID) {
                cedarValeCurrentUser.voiceUserFriendIDs.append(cedarValeRequestUser.voiceUserID)
            }
        }

        VoiceUserProfileStore.update(id: cedarValeRequestUser.voiceUserID) { cedarValeOtherUser in
            if !cedarValeOtherUser.voiceUserFriendIDs.contains(cedarValeCurrentUserID) {
                cedarValeOtherUser.voiceUserFriendIDs.append(cedarValeCurrentUserID)
            }
        }

        PrismTrailPulseToastLoadingCenter.shared.showToast("Added", kind: .success)
        cedarValeRequestReloadUsers()
    }

    private func cedarValeRequestDisagree(with cedarValeRequestUser: VoiceUserProfileData) {
        guard let cedarValeCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            return
        }

        VoiceUserProfileStore.update(id: cedarValeCurrentUserID) { cedarValeCurrentUser in
            cedarValeCurrentUser.voiceUserFriendRequestIDs.removeAll { $0 == cedarValeRequestUser.voiceUserID }
        }

        PrismTrailPulseToastLoadingCenter.shared.showToast("Request removed", kind: .normal)
        cedarValeRequestReloadUsers()
    }
}

private struct CedarValeFriendRequestRow: View {
    let user: VoiceUserProfileData
    let onAgree: () -> Void

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

            Button(action: onAgree) {
                Text("Agree")
                    .font(VoiceWhisperFontKit.regular(11))
                    .foregroundColor(.black)
                    .frame(width: 50, height: 27)
                    .background(VoiceEchoStyleKit.toneActionGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 18)
        }
        .padding(.leading, 11)
        .frame(width: 350, height: 73)
        .background(Color.white.opacity(0.11))
        .clipShape(Capsule())
    }
}

#Preview("CedarVale Friend - Requests") {
    let _ = VoiceWhisperFontKit.registerFonts()
    CedarValeFriendRequestPage {}
}
