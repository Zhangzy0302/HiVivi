import SwiftUI

struct KineticBreezeFriendAgreeDialog: View {
    let userName: String
    let onDismiss: () -> Void
    let onDisagree: () -> Void
    let onAgree: () -> Void
    @State private var kineticBreezeFriendShowsCard = false

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
                        .frame(width: 280, height: 302)

                    KineticBreezeFriendAgreeInnerCard(
                        userName: userName,
                        onDisagree: onDisagree,
                        onAgree: onAgree
                    )
                    .padding(.top, 74)

                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 54, height: 54)

                        Circle()
                            .fill(VoiceEchoStyleKit.toneLimeGlow)
                            .frame(width: 48, height: 48)

                        Image("HIVV_add_friend")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 33, height: 33)
                    }
                    .frame(width: 54, height: 54)
                    .padding(.top, 41)
                }
                .offset(y: -10)
            }
            .padding(.top, 0)
            .offset(y: kineticBreezeFriendShowsCard ? 0 : -520)
            .opacity(kineticBreezeFriendShowsCard ? 1 : 0)
            .contentShape(Rectangle())
            .onTapGesture {}
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            kineticBreezeFriendShowsCard = true
        }
        .animation(.easeOut(duration: 0.28), value: kineticBreezeFriendShowsCard)
    }
}

private struct KineticBreezeFriendAgreeInnerCard: View {
    let userName: String
    let onDisagree: () -> Void
    let onAgree: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("\(userName) has requested to\nadd you as a friend.")
                .font(VoiceWhisperFontKit.regular(15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .padding(.top, 33)

            Button(action: onAgree) {
                Text("Agree")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.black)
                    .frame(width: 122, height: 32)
                    .background(VoiceEchoStyleKit.toneActionGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 21)

            Button(action: onDisagree) {
                Text("Disagree")
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
        .frame(width: 227, height: 199)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview("KineticBreeze Friend Agree Dialog") {
    let _ = VoiceWhisperFontKit.registerFonts()

    KineticBreezeFriendAgreeDialog(
        userName: "Alice",
        onDismiss: {},
        onDisagree: {},
        onAgree: {}
    )
    .frame(width: 390, height: 844)
    .background(Color(red: 0.12, green: 0.12, blue: 0.16))
}
