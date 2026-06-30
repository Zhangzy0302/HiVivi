import SwiftUI

struct GoldenPeakBlacklistPage: View {
    let onBack: () -> Void

    @State private var goldenPeakBlockedUsers: [VoiceUserProfileData] = []

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

                Text("Blacklist")
                    .font(VoiceWhisperFontKit.bold(22))
                    .foregroundColor(.white)
                    .padding(.top, 13)

                VStack(spacing: 17) {
                    ForEach(goldenPeakBlockedUsers) { goldenPeakBlockedUser in
                        GoldenPeakBlacklistRow(
                            user: goldenPeakBlockedUser,
                            onRemove: {
                                goldenPeakBlockedRemoveUser(goldenPeakBlockedUser)
                            }
                        )
                    }

                    if goldenPeakBlockedUsers.isEmpty {
                        Text("No blocked users")
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
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: goldenPeakBlockedReloadUsers)
    }

    private func goldenPeakBlockedReloadUsers() {
        guard let goldenPeakCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID(),
              let goldenPeakCurrentUser = VoiceUserProfileStore.read(id: goldenPeakCurrentUserID) else {
            goldenPeakBlockedUsers = []
            return
        }

        let emberFieldUsersByID = Dictionary(
            uniqueKeysWithValues: VoiceUserProfileStore.readAll().map { ($0.voiceUserID, $0) }
        )

        goldenPeakBlockedUsers = goldenPeakCurrentUser.voiceUserBlockedIDs
            .compactMap { emberFieldUsersByID[$0] }
    }

    private func goldenPeakBlockedRemoveUser(_ goldenPeakBlockedUser: VoiceUserProfileData) {
        guard let goldenPeakCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            return
        }

        VoiceUserProfileStore.update(id: goldenPeakCurrentUserID) { goldenPeakCurrentUser in
            goldenPeakCurrentUser.voiceUserBlockedIDs.removeAll { $0 == goldenPeakBlockedUser.voiceUserID }
        }

        PrismTrailPulseToastLoadingCenter.shared.showToast("Removed from blacklist", kind: .success)
        goldenPeakBlockedReloadUsers()
    }
}

private struct GoldenPeakBlacklistRow: View {
    let user: VoiceUserProfileData
    let onRemove: () -> Void

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

            Button(action: onRemove) {
                Image(systemName: "person.crop.circle.badge.minus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(VoiceEchoStyleKit.voiceNeonGreen)
                    .frame(width: 46, height: 46)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 13)
        }
        .padding(.leading, 11)
        .frame(width: 350, height: 73)
        .background(Color.white.opacity(0.11))
        .clipShape(Capsule())
    }
}

#Preview("GoldenPeak Blacklist") {
    let _ = VoiceWhisperFontKit.registerFonts()
    GoldenPeakBlacklistPage(onBack: {})
}
