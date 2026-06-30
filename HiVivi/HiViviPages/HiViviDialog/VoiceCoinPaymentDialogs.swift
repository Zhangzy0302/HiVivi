import SwiftUI

struct VoiceCoinPaymentDialog: View {
    let onCancel: () -> Void
    let onSure: () -> Void

    var body: some View {
        VoiceCoinDialogShell(onBackgroundTap: onCancel) {
            VoiceCoinPurchaseCard(
                coinImageName: "HIVV_coin",
                message: "Are you sure you want to spend 200 gold coins to unlock and use AI?",
                cardBackgroundHeight: 372,
                innerCardHeight: 195,
                onCancel: onCancel,
                onSure: onSure
            )
        }
    }
}

struct VoiceCoinInsufficientDialog: View {
    let onCancel: () -> Void
    let onSure: () -> Void

    var body: some View {
        VoiceCoinDialogShell(onBackgroundTap: onCancel) {
            VoiceCoinPurchaseCard(
                coinImageName: "HIVV_no_money_coin",
                message: "Sorry, your account balance is insufficient. Please go to recharge.",
                cardBackgroundHeight: 400,
                innerCardHeight: 219,
                onCancel: onCancel,
                onSure: onSure
            )
        }
    }
}

private struct VoiceCoinDialogShell<Content: View>: View {
    let onBackgroundTap: () -> Void
    let content: Content
    @State private var voiceCoinShowsCard = false

    init(
        onBackgroundTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onBackgroundTap = onBackgroundTap
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onBackgroundTap()
                }

            VStack(spacing: 0) {
                Image("HIVV_hanging_ribbon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 248)
                    .zIndex(10)

                content
                    .offset(y: -10)
            }
            .offset(y: voiceCoinShowsCard ? 0 : -520)
            .opacity(voiceCoinShowsCard ? 1 : 0)
            .contentShape(Rectangle())
            .onTapGesture {}
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            voiceCoinShowsCard = true
        }
        .animation(.easeOut(duration: 0.28), value: voiceCoinShowsCard)
    }
}

private struct VoiceCoinPurchaseCard: View {
    let coinImageName: String
    let message: String
    let cardBackgroundHeight: CGFloat
    let innerCardHeight: CGFloat
    let onCancel: () -> Void
    let onSure: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Image("HIVV_dialog_card_bg")
                .resizable()
                .frame(width: 280, height: cardBackgroundHeight)

            Image("HIVV_text_purchase")
                .resizable()
                .scaledToFit()
                .frame(width: 164, height: 52)
                .padding(.top, 31)

            VoiceCoinDialogInnerCard(
                message: message,
                cardHeight: innerCardHeight,
                onCancel: onCancel,
                onSure: onSure
            )
            .padding(.top, 128)

            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 54, height: 54)

                Circle()
                    .fill(VoiceEchoStyleKit.toneLimeGlow)
                    .frame(width: 48, height: 48)

                Image(coinImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            .frame(width: 54, height: 54)
            .padding(.top, 94)
        }
    }
}

private struct VoiceCoinDialogInnerCard: View {
    let message: String
    let cardHeight: CGFloat
    let onCancel: () -> Void
    let onSure: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(VoiceWhisperFontKit.regular(15))
                .foregroundColor(.black)
                .tracking(-1.2)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            Spacer()

            Button(action: onCancel) {
                Text("Cancel")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.black)
                    .frame(width: 122, height: 32)
                    .background(VoiceEchoStyleKit.toneActionGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onSure) {
                Text("Sure")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.white)
                    .frame(width: 122, height: 32)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
            .padding(.bottom, 15)
        }
        .padding(.horizontal, 11)
        .frame(width: 212, height: cardHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview("Voice Coin Payment Dialog") {
    let _ = VoiceWhisperFontKit.registerFonts()

    VoiceCoinPaymentDialog(
        onCancel: {},
        onSure: {}
    )
    .frame(width: 400, height: 844)
    .background(Color(red: 0.12, green: 0.12, blue: 0.16))
}

#Preview("Voice Coin Insufficient Dialog") {
    let _ = VoiceWhisperFontKit.registerFonts()

    VoiceCoinInsufficientDialog(
        onCancel: {},
        onSure: {}
    )
    .frame(width: 400, height: 844)
    .background(Color(red: 0.12, green: 0.12, blue: 0.16))
}
