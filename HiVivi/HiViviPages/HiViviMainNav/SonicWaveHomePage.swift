import AVFoundation
import Combine
import SwiftUI

struct SonicWaveHomePage: View {
    let onAIVoiceChanger: () -> Void
    let onAdjustingVoice: () -> Void
    let onOpenChatRoom: (String) -> Void

    @State private var homeBeaconHomeRecentChatItems: [MapleQuartzChatRoomListItem] = []
    @StateObject private var sonicWaveAudioPreview = SonicWaveAIVoicePreviewController()

    init(
        onAIVoiceChanger: @escaping () -> Void = {},
        onAdjustingVoice: @escaping () -> Void = {},
        onOpenChatRoom: @escaping (String) -> Void = { _ in }
    ) {
        self.onAIVoiceChanger = onAIVoiceChanger
        self.onAdjustingVoice = onAdjustingVoice
        self.onOpenChatRoom = onOpenChatRoom
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    SonicWaveAIVoiceStrip(
                        playingVoiceID: sonicWaveAudioPreview.playingVoiceID,
                        onVoiceTap: sonicWavePlayVoicePreview
                    )
                        .padding(.top, 10)

                    Text("Recommend")
                        .font(VoiceWhisperFontKit.bold(22))
                        .foregroundColor(.white)
                        .padding(.top, 28)

                    HStack(spacing: 20) {
                        SonicWaveRecommendCard(
                            imageName: "HIVV_smile_sun",
                            imageFill: Color(red: 0.70, green: 1.0, blue: 0.40),
                            title: "AI Voice Changer",
                            subtitle: "Discover Diverse\nVoices",
                            action: onAIVoiceChanger
                        )

                        SonicWaveRecommendCard(
                            imageName: "HIVV_adjust_voice",
                            imageFill: .white,
                            title: "Adjusting Your Voice",
                            subtitle: "",
                            action: onAdjustingVoice
                        )
                    }
                    .padding(.top, 12)

                    Text("Recent Chats")
                        .font(VoiceWhisperFontKit.bold(22))
                        .foregroundColor(.white)
                        .padding(.top, 27)

                    VStack(spacing: 14) {
                        ForEach(homeBeaconHomeRecentChatItems) { homeBeaconRoomItem in
                            Button(action: {
                                onOpenChatRoom(homeBeaconRoomItem.roomID)
                            }) {
                                MapleQuartzChatMessageRow(item: homeBeaconRoomItem)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        if homeBeaconHomeRecentChatItems.isEmpty {
                            Text("No recent chats")
                                .font(VoiceWhisperFontKit.regular(13))
                                .foregroundColor(.white.opacity(0.62))
                                .frame(height: 56)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 22)
                    .padding(.bottom, 112)
                    .padding(.horizontal, -4)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear(perform: homeBeaconHomeReloadRecentChats)
        .onDisappear {
            sonicWaveAudioPreview.stop()
        }
    }

    private func homeBeaconHomeReloadRecentChats() {
        homeBeaconHomeRecentChatItems = MapleQuartzChatRoomListBuilder.visibleItems()
    }

    private func sonicWavePlayVoicePreview(_ voicePreset: VoiceMorphAIVoicePreset) {
        guard let voiceURL = VoiceMorphAIVoiceCatalog.voiceMorphAudioURL(for: voicePreset) else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Voice file not found", kind: .error)
            return
        }

        do {
            try sonicWaveAudioPreview.toggle(url: voiceURL, voiceID: voicePreset.id)
        } catch {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Voice playback failed", kind: .error)
        }
    }
}

private struct SonicWaveAIVoiceStrip: View {
    let playingVoiceID: String?
    let onVoiceTap: (VoiceMorphAIVoicePreset) -> Void

    private let sonicWaveVoices = VoiceMorphAIVoiceCatalog.homeFeatured

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(sonicWaveVoices) { voiceEchoItem in
                    SonicWaveAIVoiceBadge(
                        item: voiceEchoItem,
                        isPlaying: playingVoiceID == voiceEchoItem.id,
                        action: {
                            onVoiceTap(voiceEchoItem)
                        }
                    )
                }
            }
            .padding(.horizontal, 2)
        }
        .padding(.horizontal, -2)
    }
}

private struct SonicWaveAIVoiceBadge: View {
    let item: VoiceMorphAIVoicePreset
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(item.avatarName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isPlaying ? VoiceEchoStyleKit.voiceNeonGreen : Color.white.opacity(0.18), lineWidth: isPlaying ? 2 : 1)
                    )

                HStack(spacing: 8) {
                    SonicWaveVoiceformBars(isPlaying: isPlaying)

                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(isPlaying ? 0.36 : 0.24))
                            .frame(width: 23, height: 23)

                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: isPlaying ? 0 : 1)
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, 6)
                .frame(width: 111, height: 31)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(isPlaying ? 0.20 : 0.14))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(isPlaying ? 0.18 : 0.08), lineWidth: 1)
                )
            }
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct SonicWaveVoiceformBars: View {
    let isPlaying: Bool

    private let sonicWaveHeights: [CGFloat] = [8, 12, 6, 15, 10, 18, 9, 14, 7, 16, 11, 13, 8, 17, 10, 6]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(sonicWaveHeights.enumerated()), id: \.offset) { voiceIndex, voiceHeight in
                Capsule()
                    .fill(Color.white.opacity(isPlaying && voiceIndex % 3 == 0 ? 0.95 : 0.72))
                    .frame(width: 1.2, height: voiceHeight)
            }
        }
        .frame(width: 64, height: 22)
    }
}

@MainActor
private final class SonicWaveAIVoicePreviewController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var playingVoiceID: String?

    private var voiceAudioPlayer: AVAudioPlayer?

    func toggle(url voiceURL: URL, voiceID: String) throws {
        if playingVoiceID == voiceID && voiceAudioPlayer?.isPlaying == true {
            stop()
            return
        }

        stop()
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)

        let voicePlayer = try AVAudioPlayer(contentsOf: voiceURL)
        voicePlayer.delegate = self
        voicePlayer.prepareToPlay()
        voicePlayer.play()

        voiceAudioPlayer = voicePlayer
        playingVoiceID = voiceID
    }

    func stop() {
        voiceAudioPlayer?.stop()
        voiceAudioPlayer = nil
        playingVoiceID = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            stop()
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            stop()
        }
    }
}

private struct SonicWaveRecommendCard: View {
    let imageName: String
    let imageFill: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    imageFill

                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 69)
                        .padding(.horizontal, 18)
                }
                .frame(height: 93)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(VoiceWhisperFontKit.bold(14))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(subtitle)
                        .font(VoiceWhisperFontKit.regular(12))
                        .foregroundColor(.white.opacity(0.72))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 4)

                    HStack {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.35))
                                .frame(width: 25, height: 25)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.leading, 11)
                .padding(.top, 10)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
                .frame(height: 102)
                .background(Color(red: 0.17, green: 0.17, blue: 0.20))
            }
            .frame(width: 162, height: 195)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
