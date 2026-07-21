import Combine
import SwiftUI

struct DriftCloudVideoCallingPage: View {
    let otherUser: VoiceUserProfileData?
    let onBack: () -> Void

    @State private var driftCloudCallingDotCount = 0

    private let driftCloudCallWidth: CGFloat = 390
    private let driftCloudCallDark = Color(red: 0.10, green: 0.10, blue: 0.14)
    private let driftCloudCallGreen = VoiceEchoStyleKit.voiceNeonGreen
    private let driftCloudCallPurple = VoiceEchoStyleKit.prismTrailPulsePurple
    private let driftCloudCallingTimer = Timer.publish(every: 0.45, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            GeometryReader { _ in
                driftCloudCallBackground
            }

            VStack(spacing: 0) {
                driftCloudCallHeader
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                Spacer()
                    .frame(height: 188)

                driftCloudCallProfile

                Spacer()

                Button(action: onBack) {
                    Image("HIVV_call_down_button")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 67, height: 67)
                        .shadow(color: driftCloudCallPurple.opacity(0.35), radius: 20, x: 0, y: 12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 92)
            }
            .frame(width: driftCloudCallWidth)
        }
        .onReceive(driftCloudCallingTimer) { _ in
            driftCloudCallingDotCount = (driftCloudCallingDotCount + 1) % 4
        }
    }

    private var driftCloudCallBackground: some View {
        Image("HIVV_main_bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }

    private var driftCloudCallHeader: some View {
        HStack {
            Button(action: onBack) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 44, height: 44)

                    Image("HIVV_back_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: {}) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 44, height: 44)

                    HStack(spacing: 5) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color.black)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(height: 44)
    }

    private var driftCloudCallProfile: some View {
        VStack(spacing: 22) {
            ZStack {
                VoiceImageSourceView(
                    voiceImageAddress: otherUser?.voiceUserAvatar ?? VoiceEchoStyleKit.voiceDefaultAvatarName,
                    contentMode: .fill
                )
                .frame(width: 82, height: 82)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(driftCloudCallGreen, lineWidth: 3)
                }
            }
            .frame(width: 124, height: 124)

            VStack(spacing: 8) {
                Text(otherUser?.voiceUserName ?? "Chat")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.white)

                Text("Calling" + String(repeating: ".", count: driftCloudCallingDotCount))
                    .font(VoiceWhisperFontKit.regular(12))
                    .foregroundColor(.white.opacity(0.82))
                    .frame(width: 86, alignment: .leading)
            }
        }
        .offset(y: -14)
    }
}
