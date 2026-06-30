import SwiftUI

struct AmberStoneMaskGuideAuthPage: View {
    @State private var silverGardenSessionShowsHome = SilverGardenSessionLoginStore.hasCurrentUser
    @State private var amberStoneMaskShowsEmailAuth = false
    @State private var amberStoneMaskEmailAuthMode: BlueRiverMorphAuthMode = .signIn
    @AppStorage(VoiceEchoPersistentFlags.whisperAgreementAcceptedKey) private var voiceWhisperAgreementAccepted = false
    @State private var sonicEchoShowsEULA = false
    @State private var nobleSpringSurfGuideWebAddress: String?
    @State private var amberStoneMaskPendingAuthMode: BlueRiverMorphAuthMode?
    @State private var amberStoneMaskPendingGuestLogin = false
    @State private var amberStoneMaskShouldContinueAfterEULA = false

    private let toneShiftHorizontalInset: CGFloat = 54
    private let nobleSpringSurfUserAgreementAddress = "https://app.u5mmdj3g.link/users"
    private let nobleSpringSurfPrivacyPolicyAddress = "https://app.u5mmdj3g.link/privacy"
    private let amberStoneMaskGuestLoadingDelay: TimeInterval = 0.8

    var body: some View {
        Group {
            if silverGardenSessionShowsHome {
                VoiceRippleMainNavPage(
                    onLogOut: {
                        silverGardenSessionShowsHome = false
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled()
            } else {
                ZStack {
                    amberStoneMaskGuideContent
                    amberStoneMaskNavigationLinks
                }
            }
        }
        .navigationBarHidden(true)
        .voiceNativeSwipeBackEnabled()
        .onAppear {
            NobleSpringSurfWebPreheater.warmUp()
        }
        .onReceive(NotificationCenter.default.publisher(for: .lunarCoveGuestLimitDidRequestLogin)) { _ in
            silverGardenSessionShowsHome = false
            amberStoneMaskShowsEmailAuth = false
            amberStoneMaskEmailAuthMode = .signIn
        }
        .onChange(of: sonicEchoShowsEULA) { isShowingEULA in
            guard !isShowingEULA else {
                return
            }

            if amberStoneMaskShouldContinueAfterEULA {
                amberStoneMaskShouldContinueAfterEULA = false
                amberStoneMaskContinueAfterEULAIfNeeded()
            } else {
                amberStoneMaskPendingAuthMode = nil
                amberStoneMaskPendingGuestLogin = false
            }
        }
    }

    private var amberStoneMaskGuideContent: some View {
        GeometryReader { voiceWhisperProxy in
            let voiceWhisperSize = voiceWhisperProxy.size
            let toneShiftIsSmallScreen = voiceWhisperSize.height < 720
            let morphMicLogoSize = min(111, voiceWhisperSize.width * 0.3)
            let sonicChatButtonHeight: CGFloat = toneShiftIsSmallScreen ? 52 : 54
            let secretTimbreButtonWidth = min(250, voiceWhisperSize.width - toneShiftHorizontalInset * 2)

            ZStack {
                GeometryReader { _ in
                    VoiceWhisperGuideBackdrop()
                }

                VStack(spacing: 0) {
                    HStack {
                        Spacer()

                        Button(action: amberStoneMaskOpenEULA) {
                            Text("EULA")
                                .font(VoiceWhisperFontKit.regular(14))
                                .foregroundColor(.white)
                                .frame(width: 54, height: 31)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 22)

                    Spacer()

                    Image("HIVV_app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: morphMicLogoSize, height: morphMicLogoSize)
                        .clipShape(RoundedRectangle(cornerRadius: 30))

                    Spacer()
                        .frame(height: toneShiftIsSmallScreen ? 37 : 39)

                    VStack(spacing: 16) {
                        SonicChatGuideButton(
                            title: "Login by email",
                            fillColor: Color(red: 0.54, green: 1.0, blue: 0.43),
                            foregroundColor: .black,
                            width: secretTimbreButtonWidth,
                            height: sonicChatButtonHeight,
                            action: amberStoneMaskLoginByEmail
                        )

                        SonicChatGuideButton(
                            title: "I'm new",
                            fillColor: .white,
                            foregroundColor: .black,
                            width: secretTimbreButtonWidth,
                            height: sonicChatButtonHeight,
                            action: amberStoneMaskCreateNewAccount
                        )
                    }

                    Spacer()
                        .frame(height: toneShiftIsSmallScreen ? 19 : 20)

                    ToneShiftSignupLine(action: amberStoneMaskSignUp)

                    Spacer()
                        .frame(height: toneShiftIsSmallScreen ? 22 : 24)

                    Spacer()
                        .frame(height: toneShiftIsSmallScreen ? 22 : 23)

                    SecretTimbreAgreementRow(
                        isAccepted: $voiceWhisperAgreementAccepted,
                        onUserAgreement: amberStoneMaskOpenUserAgreement,
                        onPrivacyPolicy: amberStoneMaskOpenPrivacyPolicy
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, voiceWhisperProxy.safeAreaInsets.bottom + 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var amberStoneMaskNavigationLinks: some View {
        Group {
            NavigationLink(
                destination: BlueRiverMorphAuthEntryPage(
                    initialMode: amberStoneMaskEmailAuthMode,
                    onBackToGuide: {
                        amberStoneMaskShowsEmailAuth = false
                    },
                    onAuthComplete: {
                        amberStoneMaskCompleteEmailAuth()
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $amberStoneMaskShowsEmailAuth
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: SonicEchoEULAPage(
                    onBack: {
                        amberStoneMaskShouldContinueAfterEULA = false
                        sonicEchoShowsEULA = false
                    },
                    onAgreeFinished: {
                        amberStoneMaskFinishEULAAndContinue()
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $sonicEchoShowsEULA
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: NobleSpringSurfWebPage(
                    nobleSpringSurfWebAddress: nobleSpringSurfGuideWebAddress ?? nobleSpringSurfUserAgreementAddress,
                    onBack: {
                        nobleSpringSurfGuideWebAddress = nil
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: Binding(
                    get: {
                        nobleSpringSurfGuideWebAddress != nil
                    },
                    set: { isActive in
                        if !isActive {
                            nobleSpringSurfGuideWebAddress = nil
                        }
                    }
                )
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    private func amberStoneMaskOpenEULA() {
        sonicEchoShowsEULA = true
    }

    private func amberStoneMaskOpenUserAgreement() {
        nobleSpringSurfGuideWebAddress = nobleSpringSurfUserAgreementAddress
    }

    private func amberStoneMaskOpenPrivacyPolicy() {
        nobleSpringSurfGuideWebAddress = nobleSpringSurfPrivacyPolicyAddress
    }

    private func amberStoneMaskLoginByEmail() {
        amberStoneMaskValidateAgreementsThenOpen(.signIn)
    }

    private func amberStoneMaskCreateNewAccount() {
        amberStoneMaskValidateAgreementsThenEnterGuest()
    }

    private func amberStoneMaskSignUp() {
        amberStoneMaskValidateAgreementsThenOpen(.signUp)
    }

    private func amberStoneMaskValidateAgreementsThenOpen(_ voiceToneMode: BlueRiverMorphAuthMode) {
        guard VoiceEchoPersistentFlags.sonicEULAAccepted else {
            amberStoneMaskPendingAuthMode = voiceToneMode
            sonicEchoShowsEULA = true
            return
        }

        guard voiceWhisperAgreementAccepted else {
            PrismTrailPulseToastLoadingCenter.shared.showToast(
                "Please agree to User Agreement and Privacy Policy first.",
                kind: .normal
            )
            return
        }

        amberStoneMaskEmailAuthMode = voiceToneMode
        amberStoneMaskShowsEmailAuth = true
    }

    private func amberStoneMaskValidateAgreementsThenEnterGuest() {
        guard VoiceEchoPersistentFlags.sonicEULAAccepted else {
            amberStoneMaskPendingGuestLogin = true
            sonicEchoShowsEULA = true
            return
        }

        guard voiceWhisperAgreementAccepted else {
            PrismTrailPulseToastLoadingCenter.shared.showToast(
                "Please agree to User Agreement and Privacy Policy first.",
                kind: .normal
            )
            return
        }

        amberStoneMaskLoginAsGuestWithDelay()
    }

    private func amberStoneMaskFinishEULAAndContinue() {
        voiceWhisperAgreementAccepted = true
        amberStoneMaskShouldContinueAfterEULA = true
        sonicEchoShowsEULA = false
    }

    private func amberStoneMaskContinueAfterEULAIfNeeded() {
        let amberStonePendingMode = amberStoneMaskPendingAuthMode
        amberStoneMaskPendingAuthMode = nil
        let amberStoneShouldEnterGuest = amberStoneMaskPendingGuestLogin
        amberStoneMaskPendingGuestLogin = false
        
        guard amberStonePendingMode != nil || amberStoneShouldEnterGuest else {
            return
        }

        guard voiceWhisperAgreementAccepted else {
            PrismTrailPulseToastLoadingCenter.shared.showToast(
                "Please agree to User Agreement and Privacy Policy first.",
                kind: .normal
            )
            return
        }

        if amberStoneShouldEnterGuest {
            amberStoneMaskLoginAsGuestWithDelay()
        } else if let amberStonePendingMode {
            amberStoneMaskEmailAuthMode = amberStonePendingMode
            amberStoneMaskShowsEmailAuth = true
        }
    }

    private func amberStoneMaskLoginAsGuestWithDelay() {
        PrismTrailPulseToastLoadingCenter.shared.showLoading("Entering...", showsMask: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + amberStoneMaskGuestLoadingDelay) {
            let lunarCoveGuestUser = amberStoneMaskExistingOrCreatedGuestUser()
            SilverGardenSessionLoginStore.saveCurrentUserID(lunarCoveGuestUser.voiceUserID)
            PrismTrailPulseToastLoadingCenter.shared.hideLoading()
            silverGardenSessionShowsHome = true
        }
    }

    private func amberStoneMaskExistingOrCreatedGuestUser() -> VoiceUserProfileData {
        if let lunarCoveGuestUser = VoiceUserProfileStore.readAll().first(where: { $0.voiceUserIsGuest }) {
            return lunarCoveGuestUser
        }

        let lunarCoveGuestUserID = VoiceUserProfileStore.makeShortUserID()
        let lunarCoveGuestBirthday = Calendar.current.date(
            from: DateComponents(year: 2003, month: 1, day: 1)
        ) ?? Date()
        let lunarCoveGuestUser = VoiceUserProfileData(
            voiceUserID: lunarCoveGuestUserID,
            voiceUserEmail: "",
            voiceUserPassword: "",
            voiceUserAvatar: VoiceEchoStyleKit.voiceDefaultAvatarName,
            voiceUserName: "Guest Voice",
            voiceUserBirthday: lunarCoveGuestBirthday,
            voiceUserLocation: "LA",
            voiceUserGender: .unknown,
            voiceUserFriendIDs: [],
            voiceUserFriendRequestIDs: [],
            voiceUserBlockedIDs: [],
            voiceUserPurchasedAIVoiceIDs: [],
            voiceUserCoinCount: 99,
            voiceUserIsGuest: true
        )

        VoiceUserProfileStore.create(lunarCoveGuestUser)
        return lunarCoveGuestUser
    }

    private func amberStoneMaskAppleLogin() {}

    private func amberStoneMaskCompleteEmailAuth() {
        amberStoneMaskShowsEmailAuth = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            silverGardenSessionShowsHome = true
        }
    }
}

private struct VoiceWhisperGuideBackdrop: View {
    var body: some View {
        Image("HIVV_main_bg")
            .resizable()
            .scaledToFill()
            .overlay(Color.black.opacity(0.08))
            .ignoresSafeArea()
    }
}

private struct SonicChatGuideButton: View {
    let title: String
    let fillColor: Color
    let foregroundColor: Color
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(VoiceWhisperFontKit.bold(16))
                .foregroundColor(foregroundColor)
                .frame(width: width, height: height)
                .background(fillColor)
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct ToneShiftSignupLine: View {
    let action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("Don't have an account? ")
                .foregroundColor(.white.opacity(0.92))

            Button(action: action) {
                Text("Sign up")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .underline()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .font(VoiceWhisperFontKit.regular(12))
    }
}

private struct SecretTimbreAgreementRow: View {
    @Binding var isAccepted: Bool
    let onUserAgreement: () -> Void
    let onPrivacyPolicy: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Button(action: { isAccepted.toggle() }) {
                ZStack {
                    Circle()
                        .fill(isAccepted ? Color(red: 0.64, green: 0.41, blue: 1.0) : Color.clear)
                        .frame(width: 17, height: 17)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )

                    if isAccepted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 34, height: 34)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            HStack(spacing: 2) {
                Text("Agree with ")
                    .foregroundColor(.white.opacity(0.9))

                Button(action: onUserAgreement) {
                    Text("User Agreement")
                        .foregroundColor(.white)
                        .underline()
                }
                .buttonStyle(PlainButtonStyle())

                Text(" and ")
                    .foregroundColor(.white.opacity(0.9))

                Button(action: onPrivacyPolicy) {
                    Text("Privacy Policy")
                        .foregroundColor(.white)
                        .underline()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(VoiceWhisperFontKit.regular(11))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
        }
    }
}

#Preview("Voice Whisper - Guide Auth") {
    let _ = VoiceWhisperFontKit.registerFonts()
    AmberStoneMaskGuideAuthPage()
}
