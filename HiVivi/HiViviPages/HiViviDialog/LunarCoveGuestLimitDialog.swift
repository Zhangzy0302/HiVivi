import SwiftUI
import Combine

extension Notification.Name {
    static let lunarCoveGuestLimitDidRequestLogin = Notification.Name("lunarCoveGuestLimitDidRequestLogin")
}

@MainActor
final class LunarCoveGuestLimitCenter: ObservableObject {
    static let shared = LunarCoveGuestLimitCenter()

    @Published private(set) var lunarCoveGuestShowsLimitDialog = false

    private init() {}

    func show() {
        lunarCoveGuestShowsLimitDialog = true
    }

    func hide() {
        lunarCoveGuestShowsLimitDialog = false
    }

    func logInFromGuestLimit() {
        hide()
        SilverGardenSessionLoginStore.clearCurrentUserID()
        NotificationCenter.default.post(name: .lunarCoveGuestLimitDidRequestLogin, object: nil)
    }
}

struct LunarCoveGuestLimitOverlay: ViewModifier {
    @StateObject private var lunarCoveGuestLimitCenter = LunarCoveGuestLimitCenter.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if lunarCoveGuestLimitCenter.lunarCoveGuestShowsLimitDialog {
                LunarCoveGuestLimitDialog(
                    onCancel: {
                        lunarCoveGuestLimitCenter.hide()
                    },
                    onLogIn: {
                        lunarCoveGuestLimitCenter.logInFromGuestLimit()
                    }
                )
                .zIndex(100)
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.24), value: lunarCoveGuestLimitCenter.lunarCoveGuestShowsLimitDialog)
    }
}

extension View {
    func lunarCoveGuestLimitOverlay() -> some View {
        modifier(LunarCoveGuestLimitOverlay())
    }
}

struct LunarCoveGuestLimitDialog: View {
    let onCancel: () -> Void
    let onLogIn: () -> Void

    @State private var lunarCoveGuestShowsCard = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onCancel()
                }

            VStack(spacing: 0) {
                LunarCoveGuestHangingRibbon()
                    .zIndex(10)

                ZStack(alignment: .top) {
                    Image("HIVV_dialog_card_bg")
                        .resizable()
                        .frame(width: 280, height: 402)

                    Text("Log In")
                        .font(VoiceWhisperFontKit.bold(29))
                        .foregroundColor(.black)
                        .padding(.top, 38)

                    LunarCoveGuestInnerCard(
                        onCancel: onCancel,
                        onLogIn: onLogIn
                    )
                    .padding(.top, 133)

                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 54, height: 54)

                        Circle()
                            .fill(VoiceEchoStyleKit.toneLimeGlow)
                            .frame(width: 48, height: 48)

                        ZStack {
                            Circle()
                                .fill(Color(red: 0.39, green: 0.55, blue: 1.0))
                                .frame(width: 31, height: 31)

                            Image(systemName: "person.fill")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 54, height: 54)
                    .padding(.top, 94)
                }
                .offset(y: -10)
            }
            .offset(y: lunarCoveGuestShowsCard ? 0 : -520)
            .opacity(lunarCoveGuestShowsCard ? 1 : 0)
            .contentShape(Rectangle())
            .onTapGesture {}
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            lunarCoveGuestShowsCard = true
        }
        .animation(.easeOut(duration: 0.28), value: lunarCoveGuestShowsCard)
    }
}

private struct LunarCoveGuestHangingRibbon: View {
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

private struct LunarCoveGuestInnerCard: View {
    let onCancel: () -> Void
    let onLogIn: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("To ensure the normal operation of the function, please log in to your account first.")
                .tracking(-0.2)
                .font(VoiceWhisperFontKit.regular(15))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.top, 20)
                .padding(.horizontal, 6)

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

            Button(action: onLogIn) {
                Text("Log in")
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
        .frame(width: 212, height: 221)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview("LunarCove Guest Limit Dialog") {
    let _ = VoiceWhisperFontKit.registerFonts()

    LunarCoveGuestLimitDialog(
        onCancel: {},
        onLogIn: {}
    )
    .frame(width: 390, height: 844)
    .background(Color(red: 0.12, green: 0.12, blue: 0.16))
}
