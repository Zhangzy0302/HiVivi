import SwiftUI

struct VoiceRippleMainNavPage: View {
    let onLogOut: () -> Void

    @State private var mapleQuartzChatSelectedTab: VoiceRippleMainTab = .home
    @State private var voiceMorphShowsAssistant = false
    @State private var toneTweakShowsParameter = false
    @State private var rippleWaveRoomShowsChatRoom = false
    @State private var rippleWaveFriendShowsListPage = false
    @State private var rippleWaveFriendShowsRequestPage = false
    @State private var rippleWaveBlockedShowsListPage = false
    @State private var emberFieldUserShowsSearchPage = false
    @State private var voiceCoinShowsWallet = false
    @State private var voiceProfileShowsEdit = false
    @State private var ivoryLaneDeleteShowsAccountDialog = false
    @State private var ivoryLaneDeleteIsDeletingAccount = false
    @State private var nobleSpringSurfWebAddress: String?
    @State private var rippleWaveRoomSelectedRoomID: String?
    @State private var toneMaskCurrentUser: VoiceUserProfileData?

    private let nobleSpringSurfUserAgreementAddress = "https://app.u5mmdj3g.link/users"
    private let nobleSpringSurfPrivacyPolicyAddress = "https://app.u5mmdj3g.link/privacy"
    private let ivoryLaneDeleteAccountDelay: TimeInterval = 0.75

    init(onLogOut: @escaping () -> Void = {}) {
        self.onLogOut = onLogOut
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { _ in
                Group {
                    switch mapleQuartzChatSelectedTab {
                    case .home:
                        SonicWaveHomePage(
                            onAIVoiceChanger: {
                                voiceRippleOpenAssistant()
                            },
                            onAdjustingVoice: {
                                voiceRippleOpenParameter()
                            },
                            onOpenChatRoom: { opalBridgeRoomID in
                                voiceRippleOpenChatRoom(opalBridgeRoomID)
                            }
                        )
                    case .messages:
                        MapleQuartzChatMessagePage(
                            onOpenChatRoom: { opalBridgeRoomID in
                                voiceRippleOpenChatRoom(opalBridgeRoomID)
                            },
                            onFriends: {
                                voiceRippleOpenFriends()
                            },
                            onSearchUser: {
                                voiceRippleOpenUserSearch()
                            },
                            onFriendRequests: {
                                voiceRippleOpenFriendRequests()
                            },
                            onBlacklist: {
                                voiceRippleOpenBlacklist()
                            }
                        )
                    case .mine:
                        ToneMaskMinePage(
                            currentUser: toneMaskCurrentUser,
                            onWalletTap: {
                                voiceRippleOpenWallet()
                            },
                            onEditProfileTap: {
                                voiceRippleOpenProfileEdit()
                            },
                            onPrivacyAgreementTap: {
                                voiceRippleOpenWeb(nobleSpringSurfPrivacyPolicyAddress)
                            },
                            onUserAgreementTap: {
                                voiceRippleOpenWeb(nobleSpringSurfUserAgreementAddress)
                            },
                            onLogOutTap: voiceRippleHandleLogOut,
                            onDeleteAccountTap: {
                                voiceRippleRequireMember {
                                    ivoryLaneDeleteShowsAccountDialog = true
                                }
                            }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            

            VoiceRippleBottomNavBar(selectedTab: $mapleQuartzChatSelectedTab)

            voiceRippleNavigationLinks

            if ivoryLaneDeleteShowsAccountDialog {
                IvoryLaneDeleteAccountDialog(
                    onCancel: {
                        guard !ivoryLaneDeleteIsDeletingAccount else {
                            return
                        }
                        ivoryLaneDeleteShowsAccountDialog = false
                    },
                    onConfirm: {
                        ivoryLaneDeleteShowsAccountDialog = false
                        voiceRippleDeleteCurrentAccount()
                    }
                )
                .zIndex(10)
                .transition(.opacity)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeOut(duration: 0.24), value: ivoryLaneDeleteShowsAccountDialog)
        .navigationBarHidden(true)
        .voiceNativeSwipeBackEnabled()
        .onAppear {
            NobleSpringSurfWebPreheater.warmUp()
            voiceRippleReloadCurrentUser()
        }
    }

    private func voiceRippleHandleLogOut() {
        voiceRippleResetRoutes()
        SilverGardenSessionLoginStore.clearCurrentUserID()
        toneMaskCurrentUser = nil
        mapleQuartzChatSelectedTab = .home
        onLogOut()
    }

    private func voiceRippleReloadCurrentUser() {
        guard let rippleWaveCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            toneMaskCurrentUser = nil
            return
        }

        toneMaskCurrentUser = VoiceUserProfileStore.read(id: rippleWaveCurrentUserID)
    }

    private func voiceRippleDeleteCurrentAccount() {
        guard !ivoryLaneDeleteIsDeletingAccount else {
            return
        }

        guard let rippleWaveCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            voiceRippleHandleLogOut()
            return
        }

        ivoryLaneDeleteIsDeletingAccount = true
        PrismTrailPulseToastLoadingCenter.shared.showLoading("Deleting...", showsMask: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + ivoryLaneDeleteAccountDelay) {
            VoiceUserProfileStore.delete(id: rippleWaveCurrentUserID)
            PrismTrailPulseToastLoadingCenter.shared.hideLoading()
            PrismTrailPulseToastLoadingCenter.shared.showToast("Account deleted", kind: .success)
            ivoryLaneDeleteIsDeletingAccount = false
            voiceRippleHandleLogOut()
        }
    }

    private func voiceRippleSaveProfile(_ voiceProfileDraft: VoiceProfileDraft) {
        guard let rippleWaveCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() else {
            voiceProfileShowsEdit = false
            return
        }

        VoiceUserProfileStore.update(id: rippleWaveCurrentUserID) { voiceUser in
            let toneProfileName = voiceProfileDraft.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            if !toneProfileName.isEmpty {
                voiceUser.voiceUserName = toneProfileName
            }
            voiceUser.voiceUserAvatar = voiceProfileDraft.avatarName.isEmpty ? VoiceEchoStyleKit.voiceDefaultAvatarName : voiceProfileDraft.avatarName
            voiceUser.voiceUserBirthday = Self.voiceRippleDate(from: voiceProfileDraft.birthday)
            voiceUser.voiceUserLocation = voiceProfileDraft.location
            voiceUser.voiceUserGender = Self.voiceRippleUserGender(from: voiceProfileDraft.gender)
        }
        voiceRippleReloadCurrentUser()
        voiceProfileShowsEdit = false
        PrismTrailPulseToastLoadingCenter.shared.showToast("Saved", kind: .success)
    }

    private static func voiceRippleDate(from voiceDateText: String) -> Date {
        let toneFormatter = DateFormatter()
        toneFormatter.dateFormat = "yyyy-MM-dd"
        toneFormatter.locale = Locale(identifier: "en_US_POSIX")
        return toneFormatter.date(from: voiceDateText) ?? Date()
    }

    private static func voiceRippleBirthdayText(from voiceDate: Date?) -> String {
        let toneFormatter = DateFormatter()
        toneFormatter.dateFormat = "yyyy-MM-dd"
        toneFormatter.locale = Locale(identifier: "en_US_POSIX")
        return toneFormatter.string(from: voiceDate ?? Date())
    }

    private static func voiceRippleProfileGender(from voiceUserGender: VoiceUserGender?) -> VoiceProfileGender {
        switch voiceUserGender {
        case .male:
            return .male
        default:
            return .female
        }
    }

    private static func voiceRippleUserGender(from voiceProfileGender: VoiceProfileGender) -> VoiceUserGender {
        switch voiceProfileGender {
        case .female:
            return .female
        case .male:
            return .male
        }
    }

    private func voiceRippleResetRoutes() {
        voiceMorphShowsAssistant = false
        toneTweakShowsParameter = false
        rippleWaveRoomShowsChatRoom = false
        rippleWaveFriendShowsListPage = false
        rippleWaveFriendShowsRequestPage = false
        rippleWaveBlockedShowsListPage = false
        emberFieldUserShowsSearchPage = false
        voiceCoinShowsWallet = false
        voiceProfileShowsEdit = false
        nobleSpringSurfWebAddress = nil
        rippleWaveRoomSelectedRoomID = nil
    }

    private var voiceRippleIsGuestUser: Bool {
        toneMaskCurrentUser?.voiceUserIsGuest == true
    }

    private func voiceRippleRequireMember(_ rippleWaveMemberAction: () -> Void) {
        guard !ivoryLaneDeleteIsDeletingAccount else {
            return
        }

        voiceRippleReloadCurrentUser()
        guard !voiceRippleIsGuestUser else {
            LunarCoveGuestLimitCenter.shared.show()
            return
        }

        rippleWaveMemberAction()
    }

    private func voiceRippleOpenAssistant() {
        voiceRippleResetRoutes()
        voiceMorphShowsAssistant = true
    }

    private func voiceRippleOpenParameter() {
        voiceRippleResetRoutes()
        toneTweakShowsParameter = true
    }

    private func voiceRippleOpenChatRoom(_ opalBridgeRoomID: String) {
        voiceRippleResetRoutes()
        rippleWaveRoomSelectedRoomID = opalBridgeRoomID
        rippleWaveRoomShowsChatRoom = true
    }

    private func voiceRippleOpenFriends() {
        voiceRippleResetRoutes()
        rippleWaveFriendShowsListPage = true
    }

    private func voiceRippleOpenUserSearch() {
        voiceRippleResetRoutes()
        emberFieldUserShowsSearchPage = true
    }

    private func voiceRippleOpenFriendRequests() {
        voiceRippleResetRoutes()
        rippleWaveFriendShowsRequestPage = true
    }

    private func voiceRippleOpenBlacklist() {
        voiceRippleResetRoutes()
        rippleWaveBlockedShowsListPage = true
    }

    private func voiceRippleOpenWallet() {
        voiceRippleRequireMember {
            voiceRippleResetRoutes()
            voiceCoinShowsWallet = true
        }
    }

    private func voiceRippleOpenWalletFromAssistant() {
        voiceRippleRequireMember {
            voiceMorphShowsAssistant = false
            DispatchQueue.main.async {
                voiceRippleResetRoutes()
                voiceCoinShowsWallet = true
            }
        }
    }

    private func voiceRippleOpenProfileEdit() {
        voiceRippleRequireMember {
            voiceRippleResetRoutes()
            voiceProfileShowsEdit = true
        }
    }

    private func voiceRippleOpenWeb(_ rippleWaveWebAddress: String) {
        voiceRippleResetRoutes()
        nobleSpringSurfWebAddress = rippleWaveWebAddress
    }

    private var voiceRippleNavigationLinks: some View {
        Group {
            NavigationLink(
                destination: NobleSpringSurfWebPage(
                    nobleSpringSurfWebAddress: nobleSpringSurfWebAddress ?? nobleSpringSurfUserAgreementAddress,
                    onBack: {
                        nobleSpringSurfWebAddress = nil
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: Binding(
                    get: {
                        nobleSpringSurfWebAddress != nil
                    },
                    set: { isActive in
                        if !isActive {
                            nobleSpringSurfWebAddress = nil
                        }
                    }
                )
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: VoiceMorphAssistantPage(
                    isGuestUser: voiceRippleIsGuestUser,
                    onGuestLimit: {
                        LunarCoveGuestLimitCenter.shared.show()
                    },
                    onRecharge: {
                        voiceRippleOpenWalletFromAssistant()
                    },
                    onBack: {
                        voiceMorphShowsAssistant = false
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $voiceMorphShowsAssistant
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: ToneTweakParameterPage(
                    isGuestUser: voiceRippleIsGuestUser,
                    onGuestLimit: {
                        LunarCoveGuestLimitCenter.shared.show()
                    },
                    onBack: {
                        toneTweakShowsParameter = false
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $toneTweakShowsParameter
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: DriftCloudRoomVoiceChatPage(
                    opalBridgeRoomID: rippleWaveRoomSelectedRoomID,
                    isGuestUser: voiceRippleIsGuestUser,
                    onGuestLimit: {
                        LunarCoveGuestLimitCenter.shared.show()
                    },
                    onRecharge: {
                        voiceRippleOpenWallet()
                    },
                    onBack: {
                        rippleWaveRoomShowsChatRoom = false
                        rippleWaveRoomSelectedRoomID = nil
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: Binding(
                    get: {
                        rippleWaveRoomShowsChatRoom
                    },
                    set: { isActive in
                        rippleWaveRoomShowsChatRoom = isActive
                        if !isActive {
                            rippleWaveRoomSelectedRoomID = nil
                        }
                    }
                )
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: FrostGroveFriendListPage(
                    isGuestUser: voiceRippleIsGuestUser,
                    onGuestLimit: {
                        LunarCoveGuestLimitCenter.shared.show()
                    },
                    onBack: {
                        rippleWaveFriendShowsListPage = false
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $rippleWaveFriendShowsListPage
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: EmberFieldUserSearchPage(
                    isGuestUser: voiceRippleIsGuestUser,
                    onGuestLimit: {
                        LunarCoveGuestLimitCenter.shared.show()
                    },
                    onBack: {
                        emberFieldUserShowsSearchPage = false
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $emberFieldUserShowsSearchPage
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: CedarValeFriendRequestPage(
                    isGuestUser: voiceRippleIsGuestUser,
                    onGuestLimit: {
                        LunarCoveGuestLimitCenter.shared.show()
                    },
                    onBack: {
                        rippleWaveFriendShowsRequestPage = false
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $rippleWaveFriendShowsRequestPage
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: GoldenPeakBlacklistPage {
                    rippleWaveBlockedShowsListPage = false
                }
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $rippleWaveBlockedShowsListPage
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: VoiceCoinWalletPage {
                    voiceCoinShowsWallet = false
                }
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $voiceCoinShowsWallet
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: VoiceProfileEditPage(
                    avatarName: toneMaskCurrentUser?.voiceUserAvatar ?? VoiceEchoStyleKit.voiceDefaultAvatarName,
                    nickname: toneMaskCurrentUser?.voiceUserName ?? "",
                    birthday: Self.voiceRippleBirthdayText(from: toneMaskCurrentUser?.voiceUserBirthday),
                    location: toneMaskCurrentUser?.voiceUserLocation ?? "La",
                    gender: Self.voiceRippleProfileGender(from: toneMaskCurrentUser?.voiceUserGender),
                    onBack: {
                        voiceProfileShowsEdit = false
                    },
                    onSave: voiceRippleSaveProfile
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $voiceProfileShowsEdit
            ) {
                EmptyView()
            }
            .hidden()
        }
    }
}

private enum VoiceRippleMainTab: CaseIterable {
    case home
    case messages
    case mine

    var normalIcon: String {
        switch self {
        case .home:
            return "HIVV_nav_home"
        case .messages:
            return "HIVV_nav_message"
        case .mine:
            return "HIVV_nav_mine"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:
            return "HIVV_nav_home_selected"
        case .messages:
            return "HIVV_nav_message_s"
        case .mine:
            return "HIVV_nav_mine_selected"
        }
    }
}

struct VoiceRippleMainBackdrop: View {
    var body: some View {
        Image("HIVV_main_bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}

struct VoiceRippleAvatar: View {
    let seed: Int
    let size: CGFloat

    private var voiceMaskGradient: LinearGradient {
        let rippleWaveColors: [[Color]] = [
            [Color(red: 1.0, green: 0.88, blue: 0.42), Color(red: 0.72, green: 0.45, blue: 1.0)],
            [Color(red: 0.96, green: 0.78, blue: 0.52), Color(red: 0.47, green: 0.88, blue: 0.64)],
            [Color(red: 0.94, green: 0.70, blue: 0.55), Color(red: 0.64, green: 0.76, blue: 1.0)],
            [Color(red: 0.92, green: 0.74, blue: 0.50), Color(red: 0.45, green: 0.84, blue: 0.75)],
            [Color(red: 0.72, green: 0.87, blue: 0.98), Color(red: 0.93, green: 0.72, blue: 0.54)]
        ]
        let toneColors = rippleWaveColors[seed % rippleWaveColors.count]
        return LinearGradient(colors: toneColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(voiceMaskGradient)

            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: size * 0.72, height: size * 0.72)
                .offset(x: size * 0.12, y: -size * 0.1)

            Text(["D", "N", "V", "AI", "M"][seed % 5])
                .font(VoiceWhisperFontKit.bold(size > 70 ? 28 : 16))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

private struct VoiceRippleBottomNavBar: View {
    @Binding var selectedTab: VoiceRippleMainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(VoiceRippleMainTab.allCases, id: \.self) { mapleQuartzChatTab in
                Button(action: { selectedTab = mapleQuartzChatTab }) {
                    ZStack {
                        Image(selectedTab == mapleQuartzChatTab ? mapleQuartzChatTab.selectedIcon : mapleQuartzChatTab.normalIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28, alignment: .center)
                    }
                    .frame(width: 64, height: 50, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 37)
        .padding(.top, 13)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
        .frame(height: 78)
        .background(Color.black)
    }
}

struct VoiceRippleTopRoundedShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let toneMaskRadius = min(radius, rect.width / 2, rect.height / 2)
        var voiceRipplePath = Path()

        voiceRipplePath.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        voiceRipplePath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + toneMaskRadius))
        voiceRipplePath.addQuadCurve(
            to: CGPoint(x: rect.minX + toneMaskRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        voiceRipplePath.addLine(to: CGPoint(x: rect.maxX - toneMaskRadius, y: rect.minY))
        voiceRipplePath.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + toneMaskRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        voiceRipplePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        voiceRipplePath.closeSubpath()

        return voiceRipplePath
    }
}

#Preview("Voice Ripple - Main Nav") {
    let _ = VoiceWhisperFontKit.registerFonts()
    VoiceRippleMainNavPage()
}
