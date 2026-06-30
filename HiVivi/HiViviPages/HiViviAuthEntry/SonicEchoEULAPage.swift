import SwiftUI

struct SonicEchoEULAPage: View {
    let onBack: () -> Void
    let onOpenTerms: (() -> Void)?
    let onOpenPrivacy: (() -> Void)?
    let onAgreeFinished: () -> Void

    @State private var whisperToneAgreementAccepted = VoiceEchoPersistentFlags.whisperAgreementAccepted
    @State private var sonicEchoWebAddress: String?

    private let sonicEchoPanelColor = VoiceEchoStyleKit.voiceShadowPanel
    private let voicePulsePurpleColor = VoiceEchoStyleKit.styleBrookSoftPurple
    private let sonicEchoUserAgreementAddress = "https://app.u5mmdj3g.link/users"
    private let sonicEchoPrivacyPolicyAddress = "https://app.u5mmdj3g.link/privacy"

    init(
        onBack: @escaping () -> Void = {},
        onOpenTerms: (() -> Void)? = nil,
        onOpenPrivacy: (() -> Void)? = nil,
        onAgreeFinished: @escaping () -> Void = {}
    ) {
        self.onBack = onBack
        self.onOpenTerms = onOpenTerms
        self.onOpenPrivacy = onOpenPrivacy
        self.onAgreeFinished = onAgreeFinished
    }

    var body: some View {
        ZStack {
            GeometryReader { voicePulseProxy in
                ZStack(alignment: .top) {
                    GeometryReader { _ in
                        SonicEchoLicenseBackdrop()
                    }

                    ZStack(alignment: .top) {
                        SonicEchoLicenseTopBar(onBack: sonicEchoBackTapped)
                            .padding(.top, 10)
                            .padding(.horizontal, 20)

                        Text("EULA")
                            .font(VoiceWhisperFontKit.bold(36))
                            .italic()
                            .foregroundColor(.white)
                            .padding(.top, 50)
                    }
                    .zIndex(1)

                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 112)

                        VStack(spacing: 0) {
                            ScrollView(showsIndicators: false) {
                                Text(SonicEchoLicenseCopy.eulaText)
                                    .font(VoiceWhisperFontKit.regular(16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 28)
                                    .padding(.bottom, 18)
                            }
                            .frame(maxHeight: .infinity)

                            SonicEchoLicenseLinkRow(
                                onTerms: sonicEchoOpenTerms,
                                onPrivacy: sonicEchoOpenPrivacy
                            )
                            .padding(.horizontal, 48)
                            .padding(.top, 12)

                            SonicEchoLicenseActionRow(
                                onCancel: sonicEchoCancelTapped,
                                onAgree: sonicEchoAgreeTapped
                            )
                            .padding(.top, 22)

                            Spacer()
                                .frame(height: 16)

                            SonicEchoAgreementRow(
                                isAccepted: $whisperToneAgreementAccepted,
                                accentColor: voicePulsePurpleColor,
                                onUserAgreement: sonicEchoOpenTerms,
                                onPrivacyPolicy: sonicEchoOpenPrivacy
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, voicePulseProxy.safeAreaInsets.bottom + 12)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .background(.white.opacity(0.1))
                        .clipShape(SonicEchoTopRoundedShape(radius: 40))
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }

            NavigationLink(
                destination: NobleSpringSurfWebPage(
                    nobleSpringSurfWebAddress: sonicEchoWebAddress ?? sonicEchoUserAgreementAddress,
                    onBack: {
                        self.sonicEchoWebAddress = nil
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: Binding(
                    get: {
                        sonicEchoWebAddress != nil
                    },
                    set: { isActive in
                        if !isActive {
                            sonicEchoWebAddress = nil
                        }
                    }
                )
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarHidden(true)
        .voiceNativeSwipeBackEnabled()
        .onAppear {
            NobleSpringSurfWebPreheater.warmUp()
        }
    }

    private func sonicEchoBackTapped() {
        onBack()
    }

    private func sonicEchoOpenTerms() {
        if let onOpenTerms {
            onOpenTerms()
        } else {
            sonicEchoWebAddress = sonicEchoUserAgreementAddress
        }
    }

    private func sonicEchoOpenPrivacy() {
        if let onOpenPrivacy {
            onOpenPrivacy()
        } else {
            sonicEchoWebAddress = sonicEchoPrivacyPolicyAddress
        }
    }

    private func sonicEchoCancelTapped() {
        VoiceEchoPersistentFlags.sonicEULAAccepted = false
        onBack()
    }

    private func sonicEchoAgreeTapped() {
        VoiceEchoPersistentFlags.sonicEULAAccepted = true
        VoiceEchoPersistentFlags.whisperAgreementAccepted = true
        whisperToneAgreementAccepted = true
        onAgreeFinished()
    }
}

private enum SonicEchoLicenseCopy {
    static let eulaText = """
This End User License Agreement (EULA) governs your use of the Nomi Application (the "App"). By downloading, accessing or using the App, you agree to be bound by this Agreement. If you do not agree, you may not use the App.

1. Qualifications

By using the App, you confirm that you are at least 18 years of age. You agree to provide true and accurate age information. If you are under 18, you are prohibited from using the App.

2. User Generated Content

This App allows users to post, share and view street dance-related video content (including supporting text and pictures). By posting content ("User Content") on the App, you agree to the following:

2.1 Prohibited Content

You may not post offensive, harmful, inappropriate or illegal content, including but not limited to:

- Hate speech, abuse, harassment, threats or personal attacks;
- Pornographic, explicit or vulgar content;
- Content promoting violence, discrimination, illegal activities or infringing others' rights;
- Content irrelevant to street dance, violating public order and good customs, or used for unauthorized advertising;
- False or misleading information.

2.2 Content Licensing

You retain ownership of your User Content, but by posting it, you grant Funksy a non-exclusive, royalty-free license to use, distribute, display and promote such content within the App and its related services.

3. Reporting and Response Mechanism

3.1 Your Responsibilities

If you find content violating this EULA, report it immediately via the App's reporting mechanism.

3.2 Our Response

We will review reported content within 24 hours and take appropriate measures (e.g., removing content, warning or banning users). Repeated violations may result in permanent account suspension.

4. Privacy Policy

By using the App, you acknowledge having read and agreed to our [Privacy Policy], which details how we collect, use and protect your personal information.

5. Termination

We may terminate or suspend your access to the App at any time, with or without notice. You may stop using the App and delete your account at any time.

6. Modification of the Agreement

We may amend this Agreement at any time. Changes will be announced in the App; your continued use constitutes acceptance of revised terms.

7. Disclaimer

The App is provided "AS IS" without any warranties. We do not guarantee it will be uninterrupted, error-free or secure, nor the accuracy of its content.

8. Limitation of Liability

To the fullest extent permitted by law, we are not liable for any damages arising from your use of the App or its content.
"""
}

private struct SonicEchoLicenseBackdrop: View {
    var body: some View {
        Image("HIVV_main_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

private struct SonicEchoTopRoundedShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var toneShiftPath = Path()

        toneShiftPath.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        toneShiftPath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        toneShiftPath.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        toneShiftPath.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        toneShiftPath.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        toneShiftPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        toneShiftPath.closeSubpath()

        return toneShiftPath
    }
}

private struct SonicEchoLicenseTopBar: View {
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image("HIVV_back_btn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
    }
}

private struct SonicEchoLicenseLinkRow: View {
    let onTerms: () -> Void
    let onPrivacy: () -> Void

    var body: some View {
        HStack {
            Button(action: onTerms) {
                Text("Terms of Use")
                    .underline()
            }

            Spacer()

            Button(action: onPrivacy) {
                Text("Privacy Policy")
                    .underline()
            }
        }
        .font(VoiceWhisperFontKit.bold(14))
        .foregroundColor(.white.opacity(0.92))
        .buttonStyle(PlainButtonStyle())
    }
}

private struct SonicEchoLicenseActionRow: View {
    let onCancel: () -> Void
    let onAgree: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            Button(action: onCancel) {
                Text("Cancel")
                    .font(VoiceWhisperFontKit.bold(16))
                    .foregroundColor(.white)
                    .frame(width: 128, height: 48)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: onAgree) {
                Text("I agree")
                    .font(VoiceWhisperFontKit.bold(16))
                    .foregroundColor(VoiceEchoStyleKit.styleBrookSoftPurple)
                    .frame(width: 128, height: 48)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct SonicEchoAgreementRow: View {
    @Binding var isAccepted: Bool
    let accentColor: Color
    let onUserAgreement: () -> Void
    let onPrivacyPolicy: () -> Void

    var body: some View {
        HStack(spacing: 5) {
            Button(action: { isAccepted.toggle() }) {
                ZStack {
                    Circle()
                        .fill(isAccepted ? accentColor : Color.clear)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )

                    if isAccepted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .onChange(of: isAccepted) { newValue in
                VoiceEchoPersistentFlags.whisperAgreementAccepted = newValue
            }

            Text("Agree with ")
                .foregroundColor(.white.opacity(0.9))

            Button(action: onUserAgreement) {
                Text("User Agreement")
                    .underline()
            }
            .buttonStyle(PlainButtonStyle())

            Text(" and ")
                .foregroundColor(.white.opacity(0.9))

            Button(action: onPrivacyPolicy) {
                Text("Privacy Policy")
                    .underline()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .font(VoiceWhisperFontKit.regular(11))
        .foregroundColor(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

#Preview("Sonic EulaGarden - EULA") {
    let _ = VoiceWhisperFontKit.registerFonts()
    SonicEchoEULAPage()
}
