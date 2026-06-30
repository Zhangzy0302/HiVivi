import SwiftUI

struct EmberFieldUserSearchPage: View {
    let isGuestUser: Bool
    let onGuestLimit: () -> Void
    let onBack: () -> Void

    @State private var voiceSearchKeyword = ""
    @State private var emberFieldSearchResults: [VoiceUserProfileData] = []
    @State private var emberFieldSearchCurrentUser: VoiceUserProfileData?
    @State private var emberFieldSearchLoadingWorkItem: DispatchWorkItem?
    @FocusState private var emberFieldUserSearchFocused: Bool

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
                .contentShape(Rectangle())
                .onTapGesture {
                    emberFieldUserSearchFocused = false
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

                EmberFieldUserSearchField(
                    text: $voiceSearchKeyword,
                    isFocused: $emberFieldUserSearchFocused
                )
                .padding(.top, 21)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(emberFieldSearchResults) { emberFieldVoiceUser in
                            EmberFieldUserSearchResultRow(
                                user: emberFieldVoiceUser,
                                addState: emberFieldSearchAddState(for: emberFieldVoiceUser),
                                onAddTap: {
                                    emberFieldSearchSendFriendRequest(to: emberFieldVoiceUser)
                                }
                            )
                        }

                        if !voiceSearchKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && emberFieldSearchResults.isEmpty {
                            Text("No users found")
                                .font(VoiceWhisperFontKit.regular(13))
                                .foregroundColor(.white.opacity(0.62))
                                .frame(width: 350, height: 56)
                        }
                    }
                    .padding(.top, 19)
                    .padding(.bottom, 40)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: 390, alignment: .leading)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear(perform: emberFieldSearchReload)
        .onChange(of: voiceSearchKeyword) { _ in
            emberFieldSearchScheduleNetworkDelay()
        }
        .onDisappear {
            emberFieldSearchCancelLoading()
        }
    }

    private func emberFieldSearchReload() {
        emberFieldSearchLoadCurrentUser()
        emberFieldSearchFilterUsers()
    }

    private func emberFieldSearchLoadCurrentUser() {
        if let emberFieldCurrentUserID = SilverGardenSessionLoginStore.readCurrentUserID() {
            emberFieldSearchCurrentUser = VoiceUserProfileStore.read(id: emberFieldCurrentUserID)
        }
    }

    private func emberFieldSearchScheduleNetworkDelay() {
        emberFieldSearchCancelLoading()

        let emberFieldKeyword = voiceSearchKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !emberFieldKeyword.isEmpty else {
            emberFieldSearchResults = []
            return
        }

        emberFieldSearchResults = []
        PrismTrailPulseToastLoadingCenter.shared.showLoading("Searching...", showsMask: false)

        let emberFieldWorkItem = DispatchWorkItem {
            emberFieldSearchLoadCurrentUser()
            emberFieldSearchFilterUsers()
            PrismTrailPulseToastLoadingCenter.shared.hideLoading()
            emberFieldSearchLoadingWorkItem = nil
        }

        emberFieldSearchLoadingWorkItem = emberFieldWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: emberFieldWorkItem)
    }

    private func emberFieldSearchCancelLoading() {
        emberFieldSearchLoadingWorkItem?.cancel()
        emberFieldSearchLoadingWorkItem = nil
        PrismTrailPulseToastLoadingCenter.shared.hideLoading()
    }

    private func emberFieldSearchFilterUsers() {
        let emberFieldKeyword = voiceSearchKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !emberFieldKeyword.isEmpty else {
            emberFieldSearchResults = []
            return
        }

        let emberFieldLowerKeyword = emberFieldKeyword.lowercased()
        let emberFieldCurrentUserID = emberFieldSearchCurrentUser?.voiceUserID
        let emberFieldBlockedIDs = Set(emberFieldSearchCurrentUser?.voiceUserBlockedIDs ?? [])

        emberFieldSearchResults = VoiceUserProfileStore
            .readAll()
            .filter { emberFieldVoiceUser in
                emberFieldVoiceUser.voiceUserID != emberFieldCurrentUserID
                    && !emberFieldBlockedIDs.contains(emberFieldVoiceUser.voiceUserID)
            }
            .filter { emberFieldVoiceUser in
                emberFieldVoiceUser.voiceUserID.lowercased().contains(emberFieldLowerKeyword)
                    || emberFieldVoiceUser.voiceUserName.lowercased().contains(emberFieldLowerKeyword)
            }
            .sorted { firstUser, secondUser in
                emberFieldSearchRank(firstUser, keyword: emberFieldLowerKeyword) < emberFieldSearchRank(secondUser, keyword: emberFieldLowerKeyword)
            }
    }

    private func emberFieldSearchRank(_ emberFieldVoiceUser: VoiceUserProfileData, keyword: String) -> Int {
        let emberFieldUserID = emberFieldVoiceUser.voiceUserID.lowercased()
        let emberFieldUserName = emberFieldVoiceUser.voiceUserName.lowercased()

        if emberFieldUserID == keyword || emberFieldUserName == keyword {
            return 0
        }
        if emberFieldUserID.hasPrefix(keyword) || emberFieldUserName.hasPrefix(keyword) {
            return 1
        }
        return 2
    }

    private func emberFieldSearchAddState(for emberFieldVoiceUser: VoiceUserProfileData) -> EmberFieldUserAddState {
        guard let emberFieldCurrentUser = emberFieldSearchCurrentUser else {
            return .addable
        }

        if emberFieldCurrentUser.voiceUserFriendIDs.contains(emberFieldVoiceUser.voiceUserID) {
            return .friend
        }

        if emberFieldVoiceUser.voiceUserFriendRequestIDs.contains(emberFieldCurrentUser.voiceUserID) {
            return .sent
        }

        return .addable
    }

    private func emberFieldSearchSendFriendRequest(to emberFieldVoiceUser: VoiceUserProfileData) {
        guard !isGuestUser else {
            onGuestLimit()
            return
        }

        guard let emberFieldCurrentUser = emberFieldSearchCurrentUser,
              emberFieldSearchAddState(for: emberFieldVoiceUser) == .addable else {
            return
        }

        VoiceUserProfileStore.update(id: emberFieldVoiceUser.voiceUserID) { targetUser in
            if !targetUser.voiceUserFriendRequestIDs.contains(emberFieldCurrentUser.voiceUserID) {
                targetUser.voiceUserFriendRequestIDs.append(emberFieldCurrentUser.voiceUserID)
            }
        }

        PrismTrailPulseToastLoadingCenter.shared.showToast("Friend request sent", kind: .success)
        emberFieldSearchReload()
    }
}

private enum EmberFieldUserAddState {
    case addable
    case sent
    case friend

    var title: String {
        switch self {
        case .addable:
            return "Add to"
        case .sent:
            return "Sent"
        case .friend:
            return "Friend"
        }
    }

    var isEnabled: Bool {
        self == .addable
    }
}

private struct EmberFieldUserSearchField: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            TextField("", text: $text, prompt: Text("Please enter the ID or username.").foregroundColor(.white.opacity(0.42)))
                .font(VoiceWhisperFontKit.regular(12))
                .foregroundColor(.white)
                .tint(.white)
                .focused(isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, 18)
        .frame(width: 350, height: 53)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct EmberFieldUserSearchResultRow: View {
    let user: VoiceUserProfileData
    let addState: EmberFieldUserAddState
    let onAddTap: () -> Void

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

            Button(action: onAddTap) {
                Text(addState.title)
                    .font(VoiceWhisperFontKit.regular(11))
                    .foregroundColor(addState.isEnabled ? .black : .white.opacity(0.7))
                    .frame(width: 52, height: 27)
                    .background(
                        Group {
                            if addState.isEnabled {
                                VoiceEchoStyleKit.toneActionGradient
                            } else {
                                LinearGradient(
                                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.18)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        }
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!addState.isEnabled)
            .padding(.trailing, 18)
        }
        .padding(.leading, 11)
        .frame(width: 350, height: 73)
        .background(Color.white.opacity(0.11))
        .clipShape(Capsule())
    }
}

#Preview("EmberField User - Search") {
    let _ = VoiceWhisperFontKit.registerFonts()
    EmberFieldUserSearchPage {}
}
