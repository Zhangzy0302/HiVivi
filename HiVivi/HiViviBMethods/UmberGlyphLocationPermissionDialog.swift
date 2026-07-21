import SwiftUI
import UIKit

struct UmberGlyphLocationPermissionDialog: View {
    let umberGlyphDismissAction: () -> Void
    let umberGlyphOpenSettingsAction: () -> Void
    @State private var umberGlyphShowsCard = false

    init(
        umberGlyphDismissAction: @escaping () -> Void,
        umberGlyphOpenSettingsAction: @escaping () -> Void
    ) {
        self.umberGlyphDismissAction = umberGlyphDismissAction
        self.umberGlyphOpenSettingsAction = umberGlyphOpenSettingsAction
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: umberGlyphDismissAction)

            VStack(spacing: 0) {
                Image("HIVV_hanging_ribbon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 248)
                    .zIndex(10)

                ZStack(alignment: .top) {
                    Image("HIVV_dialog_card_bg")
                        .resizable()
                        .frame(width: 280, height: 370)

                    UmberGlyphLocationInnerCard(
                        umberGlyphDismissAction: umberGlyphDismissAction,
                        umberGlyphOpenSettingsAction: umberGlyphOpenSettingsAction
                    )
                    .padding(.top, 82)

                    UmberGlyphLocationBadge()
                        .padding(.top, 51)
                }
                .offset(y: -10)
            }
            .offset(y: umberGlyphShowsCard ? 0 : -620)
            .opacity(umberGlyphShowsCard ? 1 : 0)
            .contentShape(Rectangle())
            .onTapGesture {}
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            umberGlyphShowsCard = true
        }
        .animation(.easeOut(duration: 0.28), value: umberGlyphShowsCard)
    }

    static func umberGlyphOpenAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

private struct UmberGlyphLocationBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 54, height: 54)

            Circle()
                .fill(VoiceEchoStyleKit.toneLimeGlow)
                .frame(width: 48, height: 48)

            Image(systemName: "location.fill")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(.black)
        }
        .frame(width: 54, height: 54)
    }
}

private struct UmberGlyphLocationInnerCard: View {
    let umberGlyphDismissAction: () -> Void
    let umberGlyphOpenSettingsAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Location Access")
                .font(VoiceWhisperFontKit.bold(20))
                .foregroundColor(.black)
                .padding(.top, 40)

            Text("Allow location access to continue signing in when the service requires regional verification.")
                .font(VoiceWhisperFontKit.regular(14))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 15)
                .padding(.top, 10)

            Spacer(minLength: 12)

            Button(action: umberGlyphOpenSettingsAction) {
                Text("Settings")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.black)
                    .frame(width: 142, height: 34)
                    .background(VoiceEchoStyleKit.toneActionGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: umberGlyphDismissAction) {
                Text("Not Now")
                    .font(VoiceWhisperFontKit.bold(18))
                    .foregroundColor(.white)
                    .frame(width: 142, height: 34)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
            .padding(.bottom, 18)
        }
        .frame(width: 228, height: 262)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview("UmberGlyph Location Permission Dialog") {
    let _ = VoiceWhisperFontKit.registerFonts()

    UmberGlyphLocationPermissionDialog(
        umberGlyphDismissAction: {},
        umberGlyphOpenSettingsAction: {}
    )
    .frame(width: 400, height: 844)
    .background(Color(red: 0.12, green: 0.12, blue: 0.16))
}
