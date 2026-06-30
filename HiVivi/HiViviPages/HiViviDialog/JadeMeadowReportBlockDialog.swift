import SwiftUI

struct JadeMeadowReportBlockDialog: View {
    let onDismiss: () -> Void
    let onReport: () -> Void
    let onBlock: () -> Void
    @State private var jadeMeadowReportShowsCard = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                Image("HIVV_hanging_ribbon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 248)
                    .zIndex(10)

                ZStack(alignment: .top) {
                    Image("HIVV_dialog_card_bg")
                        .resizable()
                        .frame(width: 280, height: 220)

                    JadeMeadowReportBlockInnerCard(
                        onReport: onReport,
                        onBlock: onBlock
                    )
                    .padding(.top, 61)

                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 54, height: 54)

                        Circle()
                            .fill(VoiceEchoStyleKit.toneLimeGlow)
                            .frame(width: 48, height: 48)

                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .heavy))
                            .foregroundColor(.red)
                    }
                    .frame(width: 54, height: 54)
                    .padding(.top, 30)
                }
                .offset(y: -10)
            }
            .padding(.top, 0)
            .offset(y: jadeMeadowReportShowsCard ? 0 : -520)
            .opacity(jadeMeadowReportShowsCard ? 1 : 0)
            .contentShape(Rectangle())
            .onTapGesture {}
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            jadeMeadowReportShowsCard = true
        }
        .animation(.easeOut(duration: 0.28), value: jadeMeadowReportShowsCard)
    }
}

private struct JadeMeadowReportBlockInnerCard: View {
    let onReport: () -> Void
    let onBlock: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            Button(action: onReport) {
                Text("Report")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.black)
                    .frame(width: 130, height: 36)
                    .background(VoiceEchoStyleKit.toneActionGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onBlock) {
                Text("Block")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.white)
                    .frame(width: 130, height: 36)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .frame(width: 176, height: 126)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview("JadeMeadow Report Block Dialog") {
    let _ = VoiceWhisperFontKit.registerFonts()

    JadeMeadowReportBlockDialog(
        onDismiss: {},
        onReport: {},
        onBlock: {}
    )
    .frame(width: 400, height: 844)
    .background(Color(red: 0.12, green: 0.12, blue: 0.16))
}
