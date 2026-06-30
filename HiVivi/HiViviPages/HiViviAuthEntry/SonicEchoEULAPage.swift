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
                                    .tracking(-0.4)
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
This End User License Agreement ("Agreement") applies to your use of the HiVivi application ("App"), which provides AI voice changing and instant messaging services. By downloading, accessing or using the App, you accept and agree to this Agreement. If you do not agree, you must not use the App.

1. Eligibility

You must be at least 18 years old to use HiVivi. You agree to provide truthful and accurate age information. Users under the age of 18 are strictly prohibited from accessing or using the App's features.

2. User Content Rules

You may post and share text, voice messages, AI-modified voice audio and related content ("User Content") on HiVivi.

2.1 Prohibited Content

You agree not to upload or distribute content that is illegal, abusive, harmful, offensive or inappropriate, including:

- Hate speech, harassment, threats, insults or personal attacks;
- Pornographic, vulgar or sexually explicit material;
- Content promoting violence, discrimination or illegal activities;
- Fake voice impersonation for fraud, harassment or infringement;
- False, misleading information or unauthorized commercial advertising.

2.2 Content License

You retain ownership of your User Content. You hereby grant HiVivi a free, non-exclusive, perpetual license to use, display, distribute and optimize your User Content within the App for service operation and feature improvement.

3. Reporting & Enforcement

You may report violating content through the App's built-in reporting tool. We will review reports within 24 hours and take actions including content removal, warnings, temporary restrictions or permanent account suspension for repeated violations.

4. Privacy Policy

Your use of HiVivi is subject to our Privacy Policy. By using the App, you acknowledge that you have read and agreed to how we collect and protect your personal data, chat records and voice data.

5. Account Termination

We reserve the right to suspend or terminate your account at any time, with or without notice, for violations or operational reasons. You may stop using the App and delete your account at any time.

6. Agreement Updates

We may revise this Agreement from time to time. Updated terms will be posted in the App. Continued use of the App after updates constitutes acceptance of the revised Agreement.

7. Disclaimer

The App is provided on an "as is" and "as available" basis. We do not guarantee uninterrupted, error-free or secure service, nor the accuracy of user-generated content.

8. Liability Limitation

To the maximum extent permitted by applicable law, HiVivi shall not be liable for any direct or indirect damages arising from your use of the App.
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
