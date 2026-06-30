import SwiftUI

struct ToneMaskMinePage: View {
    let currentUser: VoiceUserProfileData?
    let onWalletTap: () -> Void
    let onEditProfileTap: () -> Void
    let onPrivacyAgreementTap: () -> Void
    let onUserAgreementTap: () -> Void
    let onLogOutTap: () -> Void
    let onDeleteAccountTap: () -> Void

    private let whisperToneItems = [
        "Wallet",
        "Privacy Agreement",
        "User Agreement",
        "Log Out",
        "Delete Account"
    ]

    init(
        currentUser: VoiceUserProfileData? = nil,
        onWalletTap: @escaping () -> Void = {},
        onEditProfileTap: @escaping () -> Void = {},
        onPrivacyAgreementTap: @escaping () -> Void = {},
        onUserAgreementTap: @escaping () -> Void = {},
        onLogOutTap: @escaping () -> Void = {},
        onDeleteAccountTap: @escaping () -> Void = {}
    ) {
        self.currentUser = currentUser
        self.onWalletTap = onWalletTap
        self.onEditProfileTap = onEditProfileTap
        self.onPrivacyAgreementTap = onPrivacyAgreementTap
        self.onUserAgreementTap = onUserAgreementTap
        self.onLogOutTap = onLogOutTap
        self.onDeleteAccountTap = onDeleteAccountTap
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }

            VStack(spacing: 0) {
                ToneMaskProfileHeader(
                    currentUser: currentUser,
                    onEditProfileTap: onEditProfileTap
                )
                    .padding(.top, 10)

                VStack(spacing: 17) {
                    ForEach(whisperToneItems, id: \.self) { mineSlateVoiceTitle in
                        Button(action: {
                            if mineSlateVoiceTitle == "Wallet" {
                                onWalletTap()
                            } else if mineSlateVoiceTitle == "Privacy Agreement" {
                                onPrivacyAgreementTap()
                            } else if mineSlateVoiceTitle == "User Agreement" {
                                onUserAgreementTap()
                            } else if mineSlateVoiceTitle == "Log Out" {
                                onLogOutTap()
                            } else if mineSlateVoiceTitle == "Delete Account" {
                                onDeleteAccountTap()
                            }
                        }) {
                            ToneMaskMenuRow(title: mineSlateVoiceTitle)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 38)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(VoiceEchoStyleKit.voiceShadowPanel)
                .clipShape(VoiceRippleTopRoundedShape(radius: 34))
                .padding(.top, 17)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ToneMaskProfileHeader: View {
    let currentUser: VoiceUserProfileData?
    let onEditProfileTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                VoiceImageSourceView(
                    voiceImageAddress: currentUser?.voiceUserAvatar ?? VoiceEchoStyleKit.voiceDefaultAvatarName,
                    contentMode: .fill
                )
                .frame(width: 98, height: 98)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )

                Button(action: onEditProfileTap) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.67, green: 0.40, blue: 1.0))
                            .frame(width: 29, height: 29)

                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 7, y: 7)
            }

            Text(currentUser?.voiceUserName.isEmpty == false ? currentUser?.voiceUserName ?? "HiVivi" : "HiVivi")
                .font(VoiceWhisperFontKit.bold(22))
                .foregroundColor(.white)

            Text("ID:\(currentUser?.voiceUserID ?? "--")")
                .font(VoiceWhisperFontKit.regular(17))
                .foregroundColor(.white.opacity(0.86))
        }
    }
}

private struct ToneMaskMenuRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(VoiceWhisperFontKit.regular(18))
                .foregroundColor(.white)

            Spacer()

            Text("→")
                .font(VoiceWhisperFontKit.bold(22))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .frame(height: 58)
        .background(VoiceEchoStyleKit.prismTrailPulsePurple)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
