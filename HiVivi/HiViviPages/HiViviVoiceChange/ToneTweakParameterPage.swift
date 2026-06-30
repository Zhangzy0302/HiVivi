import AVFoundation
import SwiftUI

struct ToneTweakParameterPage: View {
    let isGuestUser: Bool
    let onGuestLimit: () -> Void
    let onBack: () -> Void

    @State private var voiceTunePitch: Double = 0.5
    @State private var voiceTuneSpeed: Double = 0.34
    @State private var voiceTuneNoise: Double = 0.34
    @State private var voiceTuneEmotion: Double = 0.34
    @State private var voiceTuneReverb = "KTV"
    @State private var toneTweakShowsRecorder = false
    @State private var toneTweakHasUploadedVoice = false
    @State private var toneTweakOriginalVoiceURL: URL?
    @State private var toneTweakProcessedVoiceURL: URL?
    @State private var toneTweakCurrentPresetID: String?
    @State private var toneTweakRenderWorkItem: DispatchWorkItem?
    @State private var toneTweakPreviewPlayer: AVAudioPlayer?
    @StateObject private var voiceMorphRecorder = VoiceMorphAudioRecorder()

    private let tweakCanyonPanelColor = VoiceEchoStyleKit.voiceShadowPanel
    private let whisperGreen = VoiceEchoStyleKit.voiceNeonGreen
    private let voicePurple = VoiceEchoStyleKit.prismTrailPulsePurple

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
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                GeometryReader { _ in
                    VoiceRippleMainBackdrop()
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ToneTweakHeader(onBack: onBack)
                            .padding(.top, 10)

                        Text("Upload Your Own Voice")
                            .font(VoiceWhisperFontKit.bold(16))
                            .foregroundColor(.white)
                            .padding(.top, 28)

                        ToneTweakUploadArea(
                            hasUploadedVoice: toneTweakHasUploadedVoice,
                            onUploadTap: {
                                guard !isGuestUser else {
                                    onGuestLimit()
                                    return
                                }
                                toneTweakShowsRecorder = true
                            },
                            onPlayTap: toneTweakPlayProcessedVoice,
                            onClearTap: {
                                guard !isGuestUser else {
                                    onGuestLimit()
                                    return
                                }
                                toneTweakClearUploadedVoice()
                            }
                        )
                        .padding(.top, 14)

                        Text("Effect Adjustments")
                            .font(VoiceWhisperFontKit.bold(16))
                            .foregroundColor(.white)
                            .padding(.top, 22)

                        ToneTweakAdjustmentPanel(
                            pitch: $voiceTunePitch,
                            speed: $voiceTuneSpeed,
                            noise: $voiceTuneNoise,
                            emotion: $voiceTuneEmotion,
                            reverb: $voiceTuneReverb,
                            panelColor: tweakCanyonPanelColor,
                            accentColor: voicePurple
                        )
                        .padding(.top, 12)

                        Button(action: toneTweakSave) {
                            Text("save")
                                .font(VoiceWhisperFontKit.bold(16))
                                .foregroundColor(.black)
                                .frame(width: 188, height: 44)
                                .background(whisperGreen)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.top, 13)
                        .padding(.bottom, 34)
                    }
                    .padding(.horizontal, 24)
                }
            }

            if toneTweakShowsRecorder {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toneTweakShowsRecorder = false
                        }

                    ToneTweakRecorderSheet(
                        onCancel: {
                            voiceMorphRecorder.voiceMorphCancelRecording()
                            toneTweakShowsRecorder = false
                        },
                        onStartRecording: toneTweakStartRecording,
                        onStopRecording: toneTweakStopRecording,
                        isRecording: voiceMorphRecorder.voiceMorphIsRecording
                    )
                    .contentShape(Rectangle())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .ignoresSafeArea()
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.86), value: toneTweakShowsRecorder)
        .onAppear(perform: toneTweakLoadPreset)
        .onChange(of: voiceTunePitch) { _ in toneTweakScheduleProcessing() }
        .onChange(of: voiceTuneSpeed) { _ in toneTweakScheduleProcessing() }
        .onChange(of: voiceTuneNoise) { _ in toneTweakScheduleProcessing() }
        .onChange(of: voiceTuneEmotion) { _ in toneTweakScheduleProcessing() }
        .onChange(of: voiceTuneReverb) { _ in toneTweakScheduleProcessing() }
    }

    private func toneTweakLoadPreset() {
        guard let voiceUserID = toneTweakCurrentUserID(),
              let tonePreset = TimbrePresetVoiceStore.readCurrentPreset(userID: voiceUserID) else {
            return
        }

        toneTweakCurrentPresetID = tonePreset.timbrePresetID
        voiceTunePitch = tonePreset.timbrePresetPitch
        voiceTuneSpeed = tonePreset.timbrePresetSpeed
        voiceTuneNoise = tonePreset.timbrePresetNoiseReduction
        voiceTuneEmotion = tonePreset.timbrePresetEmotion
        voiceTuneReverb = tonePreset.timbrePresetReverb
        toneTweakClearPageVoiceState()
    }

    private func toneTweakSave() {
        guard !isGuestUser else {
            onGuestLimit()
            return
        }

        toneTweakSavePreset()
        PrismTrailPulseToastLoadingCenter.shared.showToast("Saved", kind: .success)
    }

    private func toneTweakStartRecording() {
        guard !voiceMorphRecorder.voiceMorphIsRecording else { return }

        voiceMorphRecorder.voiceMorphStartRecording { result in
            switch result {
            case .success(let voiceURL):
                toneTweakOriginalVoiceURL = voiceURL
                toneTweakRenderProcessedVoice(showLoading: true)
            case .failure(let error):
                PrismTrailPulseToastLoadingCenter.shared.showToast(error.localizedDescription, kind: .error)
            }
        }
    }

    private func toneTweakStopRecording() {
        guard voiceMorphRecorder.voiceMorphIsRecording else { return }
        voiceMorphRecorder.voiceMorphStopRecording()
        toneTweakShowsRecorder = false
    }

    private func toneTweakScheduleProcessing() {
        guard !isGuestUser else {
            return
        }

        guard toneTweakOriginalVoiceURL != nil else {
            toneTweakSavePreset()
            return
        }

        toneTweakRenderWorkItem?.cancel()
        let toneWorkItem = DispatchWorkItem {
            toneTweakRenderProcessedVoice(showLoading: false)
        }
        toneTweakRenderWorkItem = toneWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: toneWorkItem)
    }

    private func toneTweakRenderProcessedVoice(showLoading: Bool) {
        guard let toneOriginalURL = toneTweakOriginalVoiceURL else { return }

        let toneConfig = toneTweakCurrentConfig()
        if showLoading {
            PrismTrailPulseToastLoadingCenter.shared.showLoading("Processing...", showsMask: false)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let toneProcessedURL = try VoiceMorphAudioProcessor.voiceMorphRenderProcessedFile(
                    sourceURL: toneOriginalURL,
                    config: toneConfig
                )
                DispatchQueue.main.async {
                    toneTweakProcessedVoiceURL = toneProcessedURL
                    toneTweakHasUploadedVoice = true
                    if showLoading {
                        PrismTrailPulseToastLoadingCenter.shared.hideLoading()
                        PrismTrailPulseToastLoadingCenter.shared.showToast("Voice updated", kind: .success)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    if showLoading {
                        PrismTrailPulseToastLoadingCenter.shared.hideLoading()
                    }
                    PrismTrailPulseToastLoadingCenter.shared.showToast(error.localizedDescription, kind: .error)
                }
            }
        }
    }

    private func toneTweakPlayProcessedVoice() {
        guard let toneProcessedVoiceURL = toneTweakProcessedVoiceURL else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Record a voice first.", kind: .normal)
            return
        }

        do {
            let toneSession = AVAudioSession.sharedInstance()
            try toneSession.setCategory(.playback, mode: .default)
            try toneSession.setActive(true)

            let tonePlayer = try AVAudioPlayer(contentsOf: toneProcessedVoiceURL)
            tonePreviewPrepareAndPlay(tonePlayer)
        } catch {
            PrismTrailPulseToastLoadingCenter.shared.showToast(error.localizedDescription, kind: .error)
        }
    }

    private func toneTweakClearUploadedVoice() {
        toneTweakRenderWorkItem?.cancel()
        toneTweakRenderWorkItem = nil
        toneTweakClearPageVoiceState()
        PrismTrailPulseToastLoadingCenter.shared.showToast("Voice cleared", kind: .success)
    }

    private func toneTweakClearPageVoiceState() {
        toneTweakPreviewPlayer?.stop()
        toneTweakPreviewPlayer = nil
        toneTweakOriginalVoiceURL = nil
        toneTweakProcessedVoiceURL = nil
        toneTweakHasUploadedVoice = false
    }

    private func tonePreviewPrepareAndPlay(_ tonePlayer: AVAudioPlayer) {
        toneTweakPreviewPlayer = tonePlayer
        toneTweakPreviewPlayer?.prepareToPlay()
        toneTweakPreviewPlayer?.play()
    }

    private func toneTweakSavePreset() {
        let voiceUserID = toneTweakCurrentUserID() ?? "guest_voice_user"
        let tonePreset = TimbrePresetVoiceData(
            timbrePresetID: toneTweakCurrentPresetID ?? "timbre_preset_\(UUID().uuidString)",
            timbrePresetUserID: voiceUserID,
            timbrePresetVoiceName: "Custom Voice",
            timbrePresetPitch: voiceTunePitch,
            timbrePresetSpeed: voiceTuneSpeed,
            timbrePresetNoiseReduction: voiceTuneNoise,
            timbrePresetEmotion: voiceTuneEmotion,
            timbrePresetReverb: voiceTuneReverb,
            timbrePresetOriginalVoicePath: "",
            timbrePresetProcessedVoicePath: "",
            timbrePresetUpdatedAt: Date()
        )

        toneTweakCurrentPresetID = tonePreset.timbrePresetID
        TimbrePresetVoiceStore.upsert(tonePreset)
    }

    private func toneTweakCurrentConfig() -> VoiceMorphAudioConfig {
        VoiceMorphAudioConfig(
            voiceMorphPitch: voiceTunePitch,
            voiceMorphSpeed: voiceTuneSpeed,
            voiceMorphNoiseReduction: voiceTuneNoise,
            voiceMorphEmotion: voiceTuneEmotion,
            voiceMorphReverb: voiceTuneReverb
        )
    }

    private func toneTweakCurrentUserID() -> String? {
        SilverGardenSessionLoginStore.readCurrentUserID()
    }
}

private struct ToneTweakHeader: View {
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 17) {
            Button(action: onBack) {
                Image("HIVV_back_btn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(PlainButtonStyle())

            Text("Parameter Settings")
                .font(VoiceWhisperFontKit.bold(18))
                .foregroundColor(.white)

            Spacer()
        }
    }
}

private struct ToneTweakUploadArea: View {
    let hasUploadedVoice: Bool
    let onUploadTap: () -> Void
    let onPlayTap: () -> Void
    let onClearTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: hasUploadedVoice ? onPlayTap : onUploadTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 21, style: .continuous)
                        .fill(VoiceEchoStyleKit.voiceMossPanel)
                        .frame(height: 103)

                    if hasUploadedVoice {
                        ToneTweakVoicePlayback(width: 184)
                    } else {
                        ZStack(alignment: .center) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.14))
                                    .frame(width: 56, height: 56)

                                Circle()
                                    .fill(Color.white.opacity(0.16))
                                    .frame(width: 36, height: 36)

                                Image("HIVV_icon_mic")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }

                            Image("HIVV_finder_poinst")
                                .resizable()
                                .frame(width: 54, height: 54)
                                .offset(x: 20, y: 20)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            if hasUploadedVoice {
                Button(action: onClearTap) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.52))
                            .frame(width: 30, height: 30)

                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
                .padding(.trailing, 10)
            }
        }
    }
}

private struct ToneTweakAdjustmentPanel: View {
    @Binding var pitch: Double
    @Binding var speed: Double
    @Binding var noise: Double
    @Binding var emotion: Double
    @Binding var reverb: String

    let panelColor: Color
    let accentColor: Color

    private let reverbs = ["KTV", "Room", "Ethereal", "Concert"]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ToneTweakSliderRow(title: "Pitch", value: $pitch, accentColor: accentColor)
            ToneTweakSliderRow(title: "Speaking speed", value: $speed, accentColor: accentColor)
            ToneTweakSliderRow(title: "Noise Reduction", value: $noise, accentColor: accentColor)
            ToneTweakSliderRow(title: "Emotion", value: $emotion, accentColor: accentColor)

            VStack(alignment: .leading, spacing: 9) {
                Text("Reverb")
                    .font(VoiceWhisperFontKit.bold(14))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    ForEach(reverbs, id: \.self) { voiceRoom in
                        Button(action: { reverb = voiceRoom }) {
                            Text(voiceRoom)
                                .font(VoiceWhisperFontKit.regular(10))
                                .foregroundColor(reverb == voiceRoom ? .white : Color(red: 0.35, green: 0.36, blue: 0.40))
                                .frame(height: 22)
                                .padding(.horizontal, 12)
                                .background(reverb == voiceRoom ? accentColor : Color(red: 0.84, green: 0.86, blue: 0.90))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 18)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panelColor)
        .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
    }
}

private struct ToneTweakSliderRow: View {
    let title: String
    @Binding var value: Double
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(VoiceWhisperFontKit.bold(14))
                .foregroundColor(.white)

            Slider(value: $value, in: 0...1)
                .tint(accentColor)
        }
    }
}

private struct ToneTweakVoicePlayback: View {
    let width: CGFloat

    var body: some View {
        HStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 32, height: 32)

                Image(systemName: "play.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }

            HStack(spacing: 3) {
                ForEach(0..<18, id: \.self) { tweakCanyonWaveIndex in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white)
                        .frame(width: 2, height: CGFloat([6, 12, 9, 17, 7, 14][tweakCanyonWaveIndex % 6]))
                }
            }
        }
        .padding(.leading, 11)
        .padding(.trailing, 18)
        .frame(width: width, height: 50)
        .background(Color.white.opacity(0.13))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct ToneTweakRecorderSheet: View {
    let onCancel: () -> Void
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    let isRecording: Bool

    @State private var tonePressHasStartedRecording = false

    var body: some View {
        ZStack(alignment: .top) {
            Image("HIVV_record_bg")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 189)

            VStack(spacing: 0) {
                Text("Release to Send")
                    .font(VoiceWhisperFontKit.regular(10))
                    .foregroundColor(isRecording ? VoiceEchoStyleKit.voiceNeonGreen : .white)
                    .padding(.top, 41)

                ZStack {
                    Circle()
                        .fill(isRecording ? VoiceEchoStyleKit.prismTrailPulsePurple.opacity(0.32) : Color.white.opacity(0.13))
                        .frame(width: 52, height: 52)

                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(isRecording ? 0.28 : 0.16))
                            .frame(width: 35, height: 35)

                        Image(systemName: "mic.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }

                    if isRecording {
                        Circle()
                            .stroke(VoiceEchoStyleKit.voiceNeonGreen.opacity(0.88), lineWidth: 2)
                            .frame(width: 64, height: 64)
                    }
                }
                .frame(width: 86, height: 86)
                .contentShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !tonePressHasStartedRecording else { return }
                            tonePressHasStartedRecording = true
                            onStartRecording()
                        }
                        .onEnded { _ in
                            guard tonePressHasStartedRecording else { return }
                            tonePressHasStartedRecording = false
                            onStopRecording()
                        }
                )
                .padding(.top, 17)

                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: 189)
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(height: 189)
        .ignoresSafeArea(edges: .bottom)
        .onTapGesture(count: 2, perform: onCancel)
    }
}

#Preview("Tone Tweak - Parameter") {
    let _ = VoiceWhisperFontKit.registerFonts()
    ToneTweakParameterPage {}
}
