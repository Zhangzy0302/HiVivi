import SwiftUI

struct IvoryLaneDeleteAccountDialog: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void
    @State private var ivoryLaneDeleteShowsCard = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 0) {
                IvoryLaneDeleteHangingRibbon()
                    .zIndex(10)

                ZStack(alignment: .top) {
                    Image("HIVV_dialog_card_bg")
                        .resizable()
                        .frame(width: 280, height: 424)

                    Image("HIVV_text_delete")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 54)
                        .padding(.top, 34)

                    IvoryLaneDeleteInnerCard(
                        onCancel: onCancel,
                        onConfirm: onConfirm
                    )
                    .padding(.top, 137)

                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 54, height: 54)

                        Circle()
                            .fill(VoiceEchoStyleKit.toneLimeGlow)
                            .frame(width: 48, height: 48)

                        Image("HIVV_delete_accout_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                    }
                    .frame(width: 54, height: 54)
                    .padding(.top, 102)
                }.offset(y: -10)
            }
            .padding(.top, 0)
            .offset(y: ivoryLaneDeleteShowsCard ? 0 : -520)
            .opacity(ivoryLaneDeleteShowsCard ? 1 : 0)
            .contentShape(Rectangle())
            .onTapGesture {}
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            ivoryLaneDeleteShowsCard = true
        }
        .animation(.easeOut(duration: 0.28), value: ivoryLaneDeleteShowsCard)
    }
}

private struct IvoryLaneDeleteHangingRibbon: View {
    var body: some View {
        ZStack(alignment: .top) {
            Image("HIVV_hanging_ribbon")
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 248)
                .offset(y: -2)
        }
        .frame(width: 55, height: 246)
        .clipped()
    }
}

private struct IvoryLaneDeleteInnerCard: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("After deletion, all\ndata will be cleared.\nThis operation is\nirreversible. Please\nchoose carefully.")
                .font(VoiceWhisperFontKit.regular(15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(9)
                .padding(.top, 25)

            Button(action: onCancel) {
                Text("Cancel")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.black)
                    .frame(width: 122, height: 32)
                    .background(VoiceEchoStyleKit.toneActionGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 19)

            Button(action: onConfirm) {
                Text("Confirm")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.white)
                    .frame(width: 122, height: 32)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 11)

            Spacer()
        }
        .frame(width: 227, height: 261)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview("IvoryLane Delete Account Dialog") {
    let _ = VoiceWhisperFontKit.registerFonts()

    IvoryLaneDeleteAccountDialog(
        onCancel: {},
        onConfirm: {}
    )
    .frame(width: 400, height: 844)
    .background(Color(red: 0.12, green: 0.12, blue: 0.16))
}
