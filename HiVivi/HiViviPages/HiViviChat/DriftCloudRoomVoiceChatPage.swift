import AVFoundation
import Combine
import SwiftUI
import UIKit

struct DriftCloudRoomVoiceChatPage: View {
    let opalBridgeRoomID: String?
    let isGuestUser: Bool
    let onGuestLimit: () -> Void
    let onRecharge: () -> Void
    let onBack: () -> Void

    @State private var sonicTalkShowsVoicePad = false
    @State private var whisperLineDraft = ""
    @State private var driftCloudReportShowsActionDialog = false
    @State private var driftCloudReportShowsReasonPage = false
    @State private var driftCloudRoomCurrentUserID: String?
    @State private var driftCloudRoomData: OpalBridgeRoomChatData?
    @State private var driftCloudRoomOtherUser: VoiceUserProfileData?
    @State private var driftCloudRoomMessages: [WhisperMessageData] = []
    @State private var driftCloudRoomOwnedVoiceOptions: [VoiceMorphAIVoicePreset] = []
    @State private var driftCloudRoomSelectedVoiceOption: VoiceMorphAIVoicePreset?
    @State private var driftCloudRoomVoiceSelectorExpanded = false
    @State private var driftCloudRoomShowsAssistant = false
    @StateObject private var driftCloudRoomVoiceRecorder = VoiceMorphAudioRecorder()
    @FocusState private var driftCloudRoomWhisperInputFocused: Bool

    private let driftCloudRoomWidth: CGFloat = 390
    private let driftCloudRoomPurple = VoiceEchoStyleKit.prismTrailPulsePurple

    init(
        opalBridgeRoomID: String? = nil,
        isGuestUser: Bool = false,
        onGuestLimit: @escaping () -> Void = {},
        onRecharge: @escaping () -> Void = {},
        onBack: @escaping () -> Void
    ) {
        self.opalBridgeRoomID = opalBridgeRoomID
        self.isGuestUser = isGuestUser
        self.onGuestLimit = onGuestLimit
        self.onRecharge = onRecharge
        self.onBack = onBack
    }

    var body: some View {
        if driftCloudReportShowsReasonPage {
            HarborMintReportReasonPage(
                onBack: {
                    driftCloudReportShowsReasonPage = false
                },
                onFinish: { _ in
                    driftCloudReportShowsReasonPage = false
                    PrismTrailPulseToastLoadingCenter.shared.showToast("Report submitted", kind: .success)
                }
            )
        } else {
            ZStack(alignment: .top) {
                GeometryReader { _ in
                    VoiceRippleMainBackdrop()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    driftCloudRoomWhisperInputFocused = false
                }

                VStack(spacing: 0) {
                    OpalBridgeRoomChatHeader(
                        otherUser: driftCloudRoomOtherUser,
                        onBack: onBack,
                        onMoreTap: {
                            driftCloudRoomWhisperInputFocused = false
                            guard !isGuestUser else {
                                onGuestLimit()
                                return
                            }
                            driftCloudReportShowsActionDialog = true
                        }
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        driftCloudRoomWhisperInputFocused = false
                    }

                    DriftCloudRoomMessageStack(
                        currentUserID: driftCloudRoomCurrentUserID,
                        messages: driftCloudRoomMessages,
                        purple: driftCloudRoomPurple,
                        bottomInset: sonicTalkShowsVoicePad ? (driftCloudRoomVoiceSelectorExpanded ? 330 : 260) : 96
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        driftCloudRoomWhisperInputFocused = false
                    }
                    .frame(width: driftCloudRoomWidth)
                    .frame(maxHeight: .infinity)
                }
                .frame(width: driftCloudRoomWidth)

                if driftCloudReportShowsActionDialog {
                    JadeMeadowReportBlockDialog(
                        onDismiss: {
                            driftCloudReportShowsActionDialog = false
                        },
                        onReport: {
                            driftCloudReportShowsActionDialog = false
                            driftCloudReportShowsReasonPage = true
                        },
                        onBlock: {
                            driftCloudReportShowsActionDialog = false
                            driftCloudRoomBlockOtherUser()
                            PrismTrailPulseToastLoadingCenter.shared.showToast("Blocked", kind: .success)
                            onBack()
                        }
                    )
                    .zIndex(20)
                    .transition(.opacity)
                }

                NavigationLink(
                    destination: VoiceMorphAssistantPage(
                        isGuestUser: isGuestUser,
                        onGuestLimit: onGuestLimit,
                        onRecharge: {
                            driftCloudRoomShowsAssistant = false
                            onRecharge()
                        },
                        onBack: {
                            driftCloudRoomShowsAssistant = false
                        }
                    )
                    .navigationBarHidden(true)
                    .voiceNativeSwipeBackEnabled(),
                    isActive: $driftCloudRoomShowsAssistant
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                driftCloudRoomBottomInputArea
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .onAppear(perform: driftCloudRoomReloadData)
            .onChange(of: opalBridgeRoomID) { _ in
                driftCloudRoomReloadData()
            }
            .animation(.easeOut(duration: 0.24), value: driftCloudReportShowsActionDialog)
        }
    }

    private var driftCloudRoomBottomInputArea: some View {
        ZStack {
            if sonicTalkShowsVoicePad {
                DriftCloudRoomVoiceInputPad(
                    selectedVoice: driftCloudRoomSelectedVoiceOption,
                    ownedVoices: driftCloudRoomOwnedVoiceOptions,
                    isExpanded: $driftCloudRoomVoiceSelectorExpanded,
                    isRecording: driftCloudRoomVoiceRecorder.voiceMorphIsRecording,
                    onSelectVoice: { driftCloudVoiceOption in
                        driftCloudRoomSelectedVoiceOption = driftCloudVoiceOption
                    },
                    onEmptyTap: {
                        driftCloudRoomVoiceSelectorExpanded = false
                        sonicTalkShowsVoicePad = false
                        driftCloudRoomShowsAssistant = true
                    },
                    onClose: {
                        driftCloudRoomVoiceSelectorExpanded = false
                        sonicTalkShowsVoicePad = false
                    },
                    onStartRecording: driftCloudRoomStartVoiceRecording,
                    onStopRecording: driftCloudRoomStopVoiceRecording
                )
                    .padding(.bottom, 51)
            } else {
                DriftCloudRoomTextInputBar(
                    draftText: $whisperLineDraft,
                    isFocused: $driftCloudRoomWhisperInputFocused,
                    onVoiceTap: {
                        driftCloudRoomWhisperInputFocused = false
                        guard !isGuestUser else {
                            onGuestLimit()
                            return
                        }
                        sonicTalkShowsVoicePad = true
                    },
                    onSendTap: {
                        driftCloudRoomSendTextMessage()
                    }
                )
                .padding(.bottom, 18)
            }
        }
        .frame(width: driftCloudRoomWidth)
        .background(Color.clear)
    }

    private func driftCloudRoomReloadData() {
        let driftCloudCurrentID = SilverGardenSessionLoginStore.readCurrentUserID()
        driftCloudRoomCurrentUserID = driftCloudCurrentID

        guard let driftCloudCurrentID else {
            driftCloudRoomData = nil
            driftCloudRoomOtherUser = nil
            driftCloudRoomMessages = []
            return
        }

        let driftCloudSelectedRoom = opalBridgeRoomID
            .flatMap { OpalBridgeRoomChatStore.read(id: $0) }
            ?? OpalBridgeRoomChatStore.readRooms(forUserID: driftCloudCurrentID).first

        driftCloudRoomData = driftCloudSelectedRoom
        driftCloudRoomMessages = driftCloudSelectedRoom.map { WhisperMessageStore.readMessages(roomID: $0.opalBridgeRoomID) } ?? []
        driftCloudRoomReloadOwnedVoiceOptions(currentUserID: driftCloudCurrentID)

        let driftCloudOtherUserID = driftCloudSelectedRoom?.opalBridgeRoomUserIDs.first { $0 != driftCloudCurrentID }
        driftCloudRoomOtherUser = driftCloudOtherUserID.flatMap { VoiceUserProfileStore.read(id: $0) }
    }

    private func driftCloudRoomReloadOwnedVoiceOptions(currentUserID: String) {
        guard let driftCloudCurrentUser = VoiceUserProfileStore.read(id: currentUserID) else {
            driftCloudRoomOwnedVoiceOptions = []
            return
        }

        let driftCloudOwnedIDs = Set(driftCloudCurrentUser.voiceUserPurchasedAIVoiceIDs)
        driftCloudRoomOwnedVoiceOptions = VoiceMorphAIVoiceCatalog.all.filter { driftCloudOwnedIDs.contains($0.id) }

        if let driftCloudSelectedVoice = driftCloudRoomSelectedVoiceOption,
           !driftCloudRoomOwnedVoiceOptions.contains(driftCloudSelectedVoice) {
            driftCloudRoomSelectedVoiceOption = nil
        }
    }

    private func driftCloudRoomSendTextMessage() {
        guard !isGuestUser else {
            onGuestLimit()
            return
        }

        let driftCloudTrimmedText = whisperLineDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !driftCloudTrimmedText.isEmpty,
              let driftCloudCurrentUserID = driftCloudRoomCurrentUserID,
              let driftCloudRoomData else {
            return
        }

        let driftCloudSentAt = Date()
        let whisperMessage = WhisperMessageData(
            whisperMessageID: "whisper_message_\(UUID().uuidString)",
            whisperRoomID: driftCloudRoomData.opalBridgeRoomID,
            whisperSenderID: driftCloudCurrentUserID,
            whisperTextMessage: driftCloudTrimmedText,
            whisperVoiceFilePath: "",
            whisperVoiceDuration: 0,
            whisperSentAt: driftCloudSentAt
        )

        WhisperMessageStore.create(whisperMessage)
        OpalBridgeRoomChatStore.update(id: driftCloudRoomData.opalBridgeRoomID) { driftCloudRoom in
            driftCloudRoom.opalBridgeRoomLastMessageSentAt = driftCloudSentAt
            driftCloudRoom.opalBridgeRoomLastSenderID = driftCloudCurrentUserID
            driftCloudRoom.opalBridgeRoomLastMessageText = driftCloudTrimmedText
            driftCloudRoom.opalBridgeRoomUnreadMessageCount = 0
        }

        whisperLineDraft = ""
        driftCloudRoomWhisperInputFocused = false
        driftCloudRoomReloadData()
    }

    private func driftCloudRoomStartVoiceRecording() {
        guard !isGuestUser else {
            onGuestLimit()
            return
        }

        guard !driftCloudRoomVoiceRecorder.voiceMorphIsRecording else {
            return
        }

        driftCloudRoomWhisperInputFocused = false
        driftCloudRoomVoiceRecorder.voiceMorphStartRecording { result in
            switch result {
            case .success(let voiceURL):
                driftCloudRoomSendVoiceMessage(fileURL: voiceURL)
            case .failure(let error):
                PrismTrailPulseToastLoadingCenter.shared.showToast(error.localizedDescription, kind: .error)
            }
        }
    }

    private func driftCloudRoomStopVoiceRecording() {
        guard driftCloudRoomVoiceRecorder.voiceMorphIsRecording else {
            return
        }

        driftCloudRoomVoiceRecorder.voiceMorphStopRecording()
    }

    private func driftCloudRoomSendVoiceMessage(fileURL voiceURL: URL) {
        guard let driftCloudCurrentUserID = driftCloudRoomCurrentUserID,
              let driftCloudRoomData else {
            try? FileManager.default.removeItem(at: voiceURL)
            return
        }

        let driftCloudVoiceDuration = driftCloudRoomVoiceDuration(from: voiceURL)
        guard driftCloudVoiceDuration > 0.2 else {
            try? FileManager.default.removeItem(at: voiceURL)
            PrismTrailPulseToastLoadingCenter.shared.showToast("Hold longer to record.", kind: .normal)
            return
        }

        guard let driftCloudSelectedVoice = driftCloudRoomSelectedVoiceOption else {
            driftCloudRoomPersistVoiceMessage(
                fileURL: voiceURL,
                duration: driftCloudVoiceDuration,
                senderID: driftCloudCurrentUserID,
                roomID: driftCloudRoomData.opalBridgeRoomID
            )
            return
        }

        PrismTrailPulseToastLoadingCenter.shared.showLoading("Processing...", showsMask: false)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let driftCloudProcessedURL = try VoiceMorphAudioProcessor.voiceMorphRenderProcessedFile(
                    sourceURL: voiceURL,
                    config: driftCloudSelectedVoice.audioConfig
                )
                let driftCloudProcessedDuration = driftCloudRoomVoiceDuration(from: driftCloudProcessedURL)
                try? FileManager.default.removeItem(at: voiceURL)

                DispatchQueue.main.async {
                    PrismTrailPulseToastLoadingCenter.shared.hideLoading()
                    driftCloudRoomPersistVoiceMessage(
                        fileURL: driftCloudProcessedURL,
                        duration: driftCloudProcessedDuration > 0 ? driftCloudProcessedDuration : driftCloudVoiceDuration,
                        senderID: driftCloudCurrentUserID,
                        roomID: driftCloudRoomData.opalBridgeRoomID
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    PrismTrailPulseToastLoadingCenter.shared.hideLoading()
                    PrismTrailPulseToastLoadingCenter.shared.showToast(error.localizedDescription, kind: .error)
                    driftCloudRoomPersistVoiceMessage(
                        fileURL: voiceURL,
                        duration: driftCloudVoiceDuration,
                        senderID: driftCloudCurrentUserID,
                        roomID: driftCloudRoomData.opalBridgeRoomID
                    )
                }
            }
        }
    }

    private func driftCloudRoomPersistVoiceMessage(
        fileURL voiceURL: URL,
        duration driftCloudVoiceDuration: TimeInterval,
        senderID driftCloudCurrentUserID: String,
        roomID driftCloudRoomID: String
    ) {
        let driftCloudSentAt = Date()
        let whisperMessage = WhisperMessageData(
            whisperMessageID: "whisper_message_\(UUID().uuidString)",
            whisperRoomID: driftCloudRoomID,
            whisperSenderID: driftCloudCurrentUserID,
            whisperTextMessage: "",
            whisperVoiceFilePath: voiceURL.path,
            whisperVoiceDuration: driftCloudVoiceDuration,
            whisperSentAt: driftCloudSentAt
        )

        WhisperMessageStore.create(whisperMessage)
        OpalBridgeRoomChatStore.update(id: driftCloudRoomID) { driftCloudRoom in
            driftCloudRoom.opalBridgeRoomLastMessageSentAt = driftCloudSentAt
            driftCloudRoom.opalBridgeRoomLastSenderID = driftCloudCurrentUserID
            driftCloudRoom.opalBridgeRoomLastMessageText = "[Voice]"
            driftCloudRoom.opalBridgeRoomUnreadMessageCount = 0
        }

        driftCloudRoomReloadData()
    }

    private func driftCloudRoomVoiceDuration(from voiceURL: URL) -> TimeInterval {
        let driftCloudVoiceAsset = AVURLAsset(url: voiceURL)
        let driftCloudDuration = CMTimeGetSeconds(driftCloudVoiceAsset.duration)
        guard driftCloudDuration.isFinite, driftCloudDuration > 0 else {
            return 0
        }
        return driftCloudDuration
    }

    private func driftCloudRoomBlockOtherUser() {
        guard let driftCloudCurrentUserID = driftCloudRoomCurrentUserID,
              let driftCloudOtherUserID = driftCloudRoomOtherUser?.voiceUserID else {
            return
        }

        VoiceUserProfileStore.update(id: driftCloudCurrentUserID) { voiceUser in
            if !voiceUser.voiceUserBlockedIDs.contains(driftCloudOtherUserID) {
                voiceUser.voiceUserBlockedIDs.append(driftCloudOtherUserID)
            }
        }
    }
}

private struct OpalBridgeRoomChatHeader: View {
    let otherUser: VoiceUserProfileData?
    let onBack: () -> Void
    let onMoreTap: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Button(action: onBack) {
                Image("HIVV_back_btn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(PlainButtonStyle())

            VoiceImageSourceView(
                voiceImageAddress: otherUser?.voiceUserAvatar ?? VoiceEchoStyleKit.voiceDefaultAvatarName,
                contentMode: .fill
            )
            .frame(width: 46, height: 46)
            .clipShape(Circle())

            Text(otherUser?.voiceUserName ?? "Chat")
                .font(VoiceWhisperFontKit.bold(18))
                .foregroundColor(.white)

            Spacer()

            Button(action: onMoreTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 40, height: 40)

                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color.black)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .frame(width: 56, height: 56)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 46)
    }
}

private struct DriftCloudRoomMessageStack: View {
    let currentUserID: String?
    let messages: [WhisperMessageData]
    let purple: Color
    let bottomInset: CGFloat

    @StateObject private var driftCloudRoomVoicePlayback = DriftCloudRoomVoicePlaybackCenter()

    var body: some View {
        ScrollViewReader { driftCloudRoomScrollProxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(messages) { whisperMessage in
                        let driftCloudIsMine = whisperMessage.whisperSenderID == currentUserID

                        if whisperMessage.whisperVoiceFilePath.isEmpty {
                            DriftCloudRoomBubbleRow(
                                alignment: driftCloudIsMine ? .trailing : .leading,
                                text: whisperMessage.whisperTextMessage,
                                bubbleColor: driftCloudIsMine ? .white : purple,
                                textColor: driftCloudIsMine ? Color(red: 0.12, green: 0.12, blue: 0.15) : .white,
                                width: DriftCloudRoomBubbleSizer.width(for: whisperMessage.whisperTextMessage),
                                tailSide: driftCloudIsMine ? .right : .left,
                                tailAssetName: driftCloudIsMine ? "HIVV_white_bubble_tail" : "HIVV_purple_bubble_tail"
                            )
                            .padding(.top, 19)
                            .padding(driftCloudIsMine ? .trailing : .leading, driftCloudIsMine ? 29 : 42)
                        } else {
                            DriftCloudRoomAudioBubble(
                                messageID: whisperMessage.whisperMessageID,
                                filePath: whisperMessage.whisperVoiceFilePath,
                                isMine: driftCloudIsMine,
                                duration: whisperMessage.whisperVoiceDuration,
                                purple: purple,
                                playbackCenter: driftCloudRoomVoicePlayback
                            )
                            .padding(.top, 19)
                            .padding(driftCloudIsMine ? .trailing : .leading, driftCloudIsMine ? 30 : 42)
                        }

                        DriftCloudRoomMessageTime(
                            alignment: driftCloudIsMine ? .trailing : .leading,
                            sentAt: whisperMessage.whisperSentAt
                        )
                        .padding(.top, 10)
                        .padding(driftCloudIsMine ? .trailing : .leading, driftCloudIsMine ? 48 : 106)
                        .id(whisperMessage.whisperMessageID)
                    }

                    Spacer()
                        .frame(height: bottomInset)
                }
                .frame(width: 390, alignment: .top)
            }
            .frame(width: 390, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .top)
            .onAppear {
                driftCloudRoomScrollToLastMessage(proxy: driftCloudRoomScrollProxy)
            }
            .onChange(of: messages) { _ in
                driftCloudRoomScrollToLastMessage(proxy: driftCloudRoomScrollProxy)
            }
            .onChange(of: bottomInset) { _ in
                driftCloudRoomScrollToLastMessage(proxy: driftCloudRoomScrollProxy)
            }
            .onDisappear {
                driftCloudRoomVoicePlayback.driftCloudRoomStopPlayback()
            }
        }
    }

    private func driftCloudRoomScrollToLastMessage(proxy driftCloudRoomScrollProxy: ScrollViewProxy) {
        guard let driftCloudLastMessageID = messages.last?.whisperMessageID else { return }
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.18)) {
                driftCloudRoomScrollProxy.scrollTo(driftCloudLastMessageID, anchor: .bottom)
            }
        }
    }
}

private enum DriftCloudRoomTailSide {
    case left
    case right
}

private struct DriftCloudRoomBubbleRow: View {
    let alignment: HorizontalAlignment
    let text: String
    let bubbleColor: Color
    let textColor: Color
    let width: CGFloat
    let tailSide: DriftCloudRoomTailSide
    let tailAssetName: String

    var body: some View {
        HStack {
            if alignment == .trailing {
                Spacer()
            }

            DriftCloudRoomDecoratedBubble(
                tailSide: tailSide,
                tailAssetName: tailAssetName
            ) {
                Text(text)
                    .font(VoiceWhisperFontKit.regular(13))
                    .foregroundColor(textColor)
                    .lineSpacing(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(width: width, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(bubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            if alignment == .leading {
                Spacer()
            }
        }
    }
}

private struct DriftCloudRoomDecoratedBubble<Content: View>: View {
    let tailSide: DriftCloudRoomTailSide
    let tailAssetName: String
    let content: Content

    init(
        tailSide: DriftCloudRoomTailSide,
        tailAssetName: String,
        @ViewBuilder content: () -> Content
    ) {
        self.tailSide = tailSide
        self.tailAssetName = tailAssetName
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: tailSide == .right ? .bottomTrailing : .bottomLeading) {
            Image(tailAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: tailSide == .right ? 27 : 29, height: tailSide == .right ? 18 : 20)
                .offset(
                    x: tailSide == .right ? 13 : -13,
                    y: 3
                )

            content
        }
    }
}

private struct DriftCloudRoomMessageTime: View {
    let alignment: HorizontalAlignment
    let sentAt: Date

    var body: some View {
        HStack {
            if alignment == .trailing {
                Spacer()
            }

            Text(OpalBridgeRoomChatTimeFormatter.timeText(from: sentAt))
                .font(VoiceWhisperFontKit.regular(10))
                .foregroundColor(.white.opacity(0.80))

            if alignment == .leading {
                Spacer()
            }
        }
    }
}

private struct DriftCloudRoomAudioBubble: View {
    let messageID: String
    let filePath: String
    let isMine: Bool
    let duration: TimeInterval
    let purple: Color
    @ObservedObject var playbackCenter: DriftCloudRoomVoicePlaybackCenter

    private var driftCloudRoomIsPlaying: Bool {
        playbackCenter.driftCloudRoomPlayingMessageID == messageID
    }

    var body: some View {
        HStack {
            if isMine {
                Spacer()
            }

            DriftCloudRoomDecoratedBubble(
                tailSide: isMine ? .right : .left,
                tailAssetName: isMine ? "HIVV_white_bubble_tail" : "HIVV_purple_bubble_tail"
            ) {
                Button {
                    playbackCenter.driftCloudRoomTogglePlayback(
                        messageID: messageID,
                        filePath: filePath
                    )
                } label: {
                    HStack(spacing: 7) {
                        ZStack {
                            Image("HIVV_icon_audio")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .opacity(driftCloudRoomIsPlaying ? 0.35 : 1)

                            if driftCloudRoomIsPlaying {
                                Image(systemName: "pause.fill")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(isMine ? Color(red: 0.14, green: 0.14, blue: 0.16) : .white)
                            }
                        }

                        Text("\(max(1, Int(duration.rounded())))s")
                            .font(VoiceWhisperFontKit.bold(13))
                            .foregroundColor(isMine ? Color(red: 0.14, green: 0.14, blue: 0.16) : .white)
                    }
                    .padding(.leading, 11)
                    .padding(.trailing, 12)
                    .frame(height: 36)
                    .background(isMine ? Color.white : purple)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(driftCloudRoomIsPlaying ? VoiceEchoStyleKit.voiceNeonGreen.opacity(0.8) : Color.clear, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .scaleEffect(driftCloudRoomIsPlaying ? 1.03 : 1)
                    .animation(.easeOut(duration: 0.16), value: driftCloudRoomIsPlaying)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if !isMine {
                Spacer()
            }
        }
    }
}

private final class DriftCloudRoomVoicePlaybackCenter: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var driftCloudRoomPlayingMessageID: String?

    private var driftCloudRoomAudioPlayer: AVAudioPlayer?

    func driftCloudRoomTogglePlayback(messageID: String, filePath: String) {
        if driftCloudRoomPlayingMessageID == messageID {
            driftCloudRoomStopPlayback()
            return
        }

        driftCloudRoomPlayVoice(messageID: messageID, filePath: filePath)
    }

    func driftCloudRoomStopPlayback() {
        driftCloudRoomAudioPlayer?.stop()
        driftCloudRoomAudioPlayer = nil
        driftCloudRoomPlayingMessageID = nil
    }

    private func driftCloudRoomPlayVoice(messageID: String, filePath: String) {
        guard let driftCloudVoiceURL = driftCloudRoomVoiceURL(from: filePath),
              FileManager.default.fileExists(atPath: driftCloudVoiceURL.path) else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Voice file unavailable.", kind: .normal)
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            let driftCloudPlayer = try AVAudioPlayer(contentsOf: driftCloudVoiceURL)
            driftCloudPlayer.delegate = self
            driftCloudPlayer.prepareToPlay()

            driftCloudRoomStopPlayback()
            driftCloudRoomAudioPlayer = driftCloudPlayer
            driftCloudRoomPlayingMessageID = messageID
            driftCloudPlayer.play()
        } catch {
            driftCloudRoomStopPlayback()
            PrismTrailPulseToastLoadingCenter.shared.showToast("Unable to play voice.", kind: .error)
        }
    }

    private func driftCloudRoomVoiceURL(from filePath: String) -> URL? {
        let driftCloudTrimmedPath = filePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !driftCloudTrimmedPath.isEmpty else {
            return nil
        }

        if driftCloudTrimmedPath.hasPrefix("file://"),
           let driftCloudFileURL = URL(string: driftCloudTrimmedPath),
           driftCloudFileURL.isFileURL {
            return driftCloudFileURL
        }

        if driftCloudTrimmedPath.hasPrefix("/") {
            return URL(fileURLWithPath: driftCloudTrimmedPath)
        }

        return nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        driftCloudRoomStopPlayback()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        driftCloudRoomStopPlayback()
    }
}

private struct DriftCloudRoomTextInputBar: View {
    @Binding var draftText: String
    let isFocused: FocusState<Bool>.Binding
    let onVoiceTap: () -> Void
    let onSendTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onVoiceTap) {
                Image("HIVV_icon_audio")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 27, height: 27)
                    .frame(width: 46, height: 52)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            HStack(spacing: 0) {
                TextField("", text: $draftText)
                    .font(VoiceWhisperFontKit.regular(16))
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.16))
                    .tint(Color(red: 0.13, green: 0.13, blue: 0.16))
                    .multilineTextAlignment(.leading)
                    .focused(isFocused)
                    .submitLabel(.send)
                    .onSubmit(onSendTap)
                    .placeholder(when: draftText.isEmpty) {
                        Text("Say something")
                            .font(VoiceWhisperFontKit.regular(16))
                            .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62))
                    }
                    .frame(width: 224, height: 48, alignment: .leading)
                    .padding(.leading, 18)

                Spacer(minLength: 0)

                Button(action: onSendTap) {
                    Image("HIVV_send_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 39, height: 39)
                        .frame(width: 48, height: 52)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 294, height: 48)
            .background(Color.white)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .onTapGesture {
                isFocused.wrappedValue = true
            }
        }
        .frame(width: 340, height: 52)
        .contentShape(Rectangle())
    }
}

private enum DriftCloudRoomBubbleSizer {
    static let maxWidth: CGFloat = 263

    private static let driftCloudHorizontalPadding: CGFloat = 28
    private static let driftCloudMeasureFont = UIFont(
        name: VoiceWhisperFontKit.toneShiftRegularName,
        size: 13
    ) ?? .systemFont(ofSize: 13)

    static func width(for driftCloudText: String) -> CGFloat {
        let driftCloudAvailableTextWidth = maxWidth - driftCloudHorizontalPadding
        let driftCloudMeasuredSize = NSString(string: driftCloudText).boundingRect(
            with: CGSize(width: driftCloudAvailableTextWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: driftCloudMeasureFont],
            context: nil
        ).size
        let driftCloudMeasuredWidth = ceil(driftCloudMeasuredSize.width) + driftCloudHorizontalPadding
        return min(maxWidth, max(driftCloudHorizontalPadding, driftCloudMeasuredWidth))
    }
}

private enum OpalBridgeRoomChatTimeFormatter {
    static func timeText(from driftCloudDate: Date) -> String {
        driftCloudFormatter.string(from: driftCloudDate)
    }

    private static let driftCloudFormatter: DateFormatter = {
        let driftCloudFormatter = DateFormatter()
        driftCloudFormatter.dateFormat = "H:mm"
        return driftCloudFormatter
    }()
}

private struct DriftCloudRoomVoiceInputPad: View {
    let selectedVoice: VoiceMorphAIVoicePreset?
    let ownedVoices: [VoiceMorphAIVoicePreset]
    @Binding var isExpanded: Bool
    let isRecording: Bool
    let onSelectVoice: (VoiceMorphAIVoicePreset) -> Void
    let onEmptyTap: () -> Void
    let onClose: () -> Void
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void

    @State private var driftCloudRoomPressHasStartedRecording = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                        .contentShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 180, height: 32)

            Button(action: driftCloudRoomToggleVoiceSelector) {
                VStack(spacing: 0) {
                    if let selectedVoice {
                        Image(selectedVoice.avatarName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 43, height: 43)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 43, height: 43)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white.opacity(0.80))
                            )
                    }

                    HStack(spacing: 5) {
                        Text(selectedVoice?.name ?? "AI Voice")
                            .font(VoiceWhisperFontKit.regular(17))
                            .foregroundColor(.white)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.82))
                    }
                    .padding(.top, 14)
                }
                .frame(width: 180)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 2)

            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if ownedVoices.isEmpty {
                            DriftCloudRoomEmptyVoiceOptionButton(action: onEmptyTap)
                        } else {
                            ForEach(ownedVoices) { driftCloudVoiceOption in
                                Button(action: {
                                    onSelectVoice(driftCloudVoiceOption)
                                    withAnimation(.easeOut(duration: 0.18)) {
                                        isExpanded = false
                                    }
                                }) {
                                    DriftCloudRoomVoiceOptionChip(
                                        voiceOption: driftCloudVoiceOption,
                                        isSelected: selectedVoice == driftCloudVoiceOption
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(width: 230, height: 68)
                .padding(.top, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            ZStack {
                Circle()
                    .fill(Color.white.opacity(isRecording ? 0.16 : 0.08))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .stroke(isRecording ? VoiceEchoStyleKit.voiceNeonGreen.opacity(0.78) : Color.white.opacity(0.12), lineWidth: 1)
                    )

                Circle()
                    .fill(Color.white.opacity(isRecording ? 0.24 : 0.15))
                    .frame(width: 61, height: 61)

                Image("HIVV_icon_mic")
                    .resizable()
                    .frame(width: 33, height: 33)
            }
            .frame(width: 104, height: 104)
            .contentShape(Circle())
            .scaleEffect(isRecording ? 1.06 : 1)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !driftCloudRoomPressHasStartedRecording else {
                            return
                        }
                        driftCloudRoomPressHasStartedRecording = true
                        onStartRecording()
                    }
                    .onEnded { _ in
                        guard driftCloudRoomPressHasStartedRecording else {
                            return
                        }
                        driftCloudRoomPressHasStartedRecording = false
                        onStopRecording()
                    }
            )
            .padding(.top, isExpanded ? 10 : 14)
        }
        .frame(width: isExpanded ? 230 : 180, height: isExpanded ? 314 : 234)
        .animation(.easeOut(duration: 0.18), value: isExpanded)
        .animation(.easeOut(duration: 0.16), value: isRecording)
    }

    private func driftCloudRoomToggleVoiceSelector() {
        withAnimation(.easeOut(duration: 0.18)) {
            isExpanded.toggle()
        }
    }
}

private struct DriftCloudRoomEmptyVoiceOptionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white.opacity(0.72))
                    )

                Text("Empty")
                    .font(VoiceWhisperFontKit.regular(9))
                    .foregroundColor(.white.opacity(0.72))
                    .lineLimit(1)
                    .frame(width: 58)
            }
            .frame(width: 58, height: 64)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct DriftCloudRoomVoiceOptionChip: View {
    let voiceOption: VoiceMorphAIVoicePreset
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(voiceOption.avatarName)
                .resizable()
                .scaledToFill()
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? VoiceEchoStyleKit.voiceNeonGreen : Color.white.opacity(0.0), lineWidth: 2)
                )

            Text(voiceOption.name)
                .font(VoiceWhisperFontKit.regular(9))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 58)
        }
        .frame(width: 58, height: 64)
    }
}

private extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}

#Preview("DriftCloud Room - Chat") {
    let _ = VoiceWhisperFontKit.registerFonts()
    DriftCloudRoomVoiceChatPage {}
}
