import SwiftUI

struct BlueRiverMorphAuthEntryPage: View {
    let onBackToGuide: () -> Void
    let onAuthComplete: () -> Void

    @State private var voicePulseAuthMode: BlueRiverMorphAuthMode
    @State private var whisperWaveEmail = ""
    @State private var whisperWavePassword = ""
    @State private var whisperWaveConfirmPassword = ""
    @State private var voiceProfileShowsRegisterEdit = false
    @State private var blueRiverMorphIsNavigating = false
    @FocusState private var voicePulseFocusedField: BlueRiverMorphAuthField?

    private let voicePulsePanelColor = VoiceEchoStyleKit.voiceShadowPanel
    private let blueRiverMorphMintColor = Color(red: 0.86, green: 0.94, blue: 0.89)
    private let toneTwistActionColor = LinearGradient(
        colors: [
            Color(red: 0.68, green: 1.0, blue: 0.43),
            Color(red: 0.38, green: 0.98, blue: 0.56)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    private let blueRiverMorphLoginLoadingDelay: TimeInterval = 0.6
    private let blueRiverMorphRegisterLoadingDelay: TimeInterval = 0.55

    init(
        initialMode: BlueRiverMorphAuthMode = .signIn,
        onBackToGuide: @escaping () -> Void = {},
        onAuthComplete: @escaping () -> Void = {}
    ) {
        _voicePulseAuthMode = State(initialValue: initialMode)
        self.onBackToGuide = onBackToGuide
        self.onAuthComplete = onAuthComplete
    }

    var body: some View {
        ZStack {
            blueRiverMorphAuthContent
            blueRiverMorphNavigationLinks
        }
        .navigationBarHidden(true)
        .voiceNativeSwipeBackEnabled()
    }

    private var blueRiverMorphAuthContent: some View {
        GeometryReader { voicePulseProxy in
            let whisperWavePanelTop = 164.0

            ZStack(alignment: .top) {
                GeometryReader { _ in
                    BlueRiverMorphAuthBackdrop()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            blueRiverMorphClearFocus()
                        }
                }
                

                ZStack(alignment: .top) {
                    BlueRiverMorphAuthTopBar(onBack: blueRiverMorphBackTapped)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)

                    BlueRiverMorphAuthTitle(mode: voicePulseAuthMode)
                        .padding(.top, voicePulseAuthMode == .forgotPassword ? 33 : 71)

                    Spacer()
                }
                .zIndex(1)

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: whisperWavePanelTop)

                    VStack(spacing: 22) {
                        BlueRiverMorphAuthInputField(
                            iconName: "HIVV_icon_email",
                            placeholder: "Email",
                            text: $whisperWaveEmail,
                            isSecure: false,
                            focusedField: $voicePulseFocusedField,
                            field: .email,
                            fillColor: blueRiverMorphMintColor
                        )

                        BlueRiverMorphAuthInputField(
                            iconName: "HIVV_icon_password",
                            placeholder: "Password",
                            text: $whisperWavePassword,
                            isSecure: true,
                            focusedField: $voicePulseFocusedField,
                            field: .password,
                            fillColor: blueRiverMorphMintColor
                        )

                        if voicePulseAuthMode.needsConfirmPassword {
                            BlueRiverMorphAuthInputField(
                                iconName: "HIVV_icon_password",
                                placeholder: "Enter the password again",
                                text: $whisperWaveConfirmPassword,
                                isSecure: true,
                                focusedField: $voicePulseFocusedField,
                                field: .confirmPassword,
                                fillColor: blueRiverMorphMintColor
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        if voicePulseAuthMode == .signIn {
                            BlueRiverMorphForgetButton {
                                blueRiverMorphSwitchMode(.forgotPassword)
                            }
                            .frame(alignment: .trailing)
                            .padding(.top, -3)
                        }

                        Spacer()
                            .frame(height: voicePulseAuthMode == .signIn ? 113 : 60)

                        BlueRiverMorphPrimaryButton(
                            title: voicePulseAuthMode.actionTitle,
                            gradient: toneTwistActionColor,
                            action: blueRiverMorphSubmit
                        )
                        .allowsHitTesting(!blueRiverMorphIsNavigating)
                        .opacity(blueRiverMorphIsNavigating ? 0.72 : 1)

                    }
                    .padding(.top, 37)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(
                        voicePulsePanelColor
                            .contentShape(Rectangle())
                            .onTapGesture {
                                blueRiverMorphClearFocus()
                            }
                    )
                    .clipShape(BlueRiverMorphTopRoundedShape(radius: 28))
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: voicePulseAuthMode)
        }
    }

    private var blueRiverMorphNavigationLinks: some View {
        Group {
            NavigationLink(
                destination: VoiceProfileEditPage(
                    registerEmail: whisperWaveEmail,
                    registerPassword: whisperWavePassword,
                    onBack: {
                        voiceProfileShowsRegisterEdit = false
                    },
                    onSave: { _ in },
                    onRegisterComplete: { voiceUserID in
                        guard !blueRiverMorphIsNavigating else {
                            return
                        }
                        blueRiverMorphIsNavigating = true
                        SilverGardenSessionLoginStore.saveCurrentUserID(voiceUserID)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            blueRiverMorphIsNavigating = false
                            onAuthComplete()
                        }
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled(),
                isActive: $voiceProfileShowsRegisterEdit
            ) {
                EmptyView()
            }
            .hidden()

        }
    }

    private func blueRiverMorphSwitchMode(_ toneTwistMode: BlueRiverMorphAuthMode) {
        blueRiverMorphClearFocus()
        voicePulseAuthMode = toneTwistMode
    }

    private func blueRiverMorphSubmit() {
        guard !blueRiverMorphIsNavigating else {
            return
        }

        blueRiverMorphClearFocus()

        switch voicePulseAuthMode {
        case .signIn:
            blueRiverMorphHandleSignIn()
        case .signUp:
            blueRiverMorphHandleSignUp()
        case .forgotPassword:
            blueRiverMorphHandleForgotPassword()
        }
    }

    private func blueRiverMorphHandleSignIn() {
        let voiceLoginEmail = whisperWaveEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let voiceLoginPassword = whisperWavePassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !voiceLoginEmail.isEmpty, !voiceLoginPassword.isEmpty else {
            blueRiverMorphShowToast("Please enter email and password.", kind: .normal)
            return
        }

        guard let blueRiverLoginUser = VoiceUserProfileStore.readAll().first(where: {
            $0.voiceUserEmail.caseInsensitiveCompare(voiceLoginEmail) == .orderedSame
                && $0.voiceUserPassword == voiceLoginPassword
        }) else {
            blueRiverMorphShowToast("Email or password is incorrect.", kind: .error)
            return
        }

        blueRiverMorphIsNavigating = true
        PrismTrailPulseToastLoadingCenter.shared.showLoading("Loading...", showsMask: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + blueRiverMorphLoginLoadingDelay) {
            SilverGardenSessionLoginStore.saveCurrentUserID(blueRiverLoginUser.voiceUserID)
            PrismTrailPulseToastLoadingCenter.shared.hideLoading()
            blueRiverMorphIsNavigating = false
            onAuthComplete()
        }
    }

    private func blueRiverMorphHandleSignUp() {
        let voiceRegisterEmail = whisperWaveEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let voiceRegisterPassword = whisperWavePassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let voiceRegisterConfirmPassword = whisperWaveConfirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !voiceRegisterEmail.isEmpty, !voiceRegisterPassword.isEmpty else {
            blueRiverMorphShowToast("Please enter email and password.", kind: .normal)
            return
        }
        guard voiceRegisterPassword == voiceRegisterConfirmPassword else {
            blueRiverMorphShowToast("The two passwords are different.", kind: .error)
            return
        }
        guard !VoiceUserProfileStore.readAll().contains(where: {
            $0.voiceUserEmail.caseInsensitiveCompare(voiceRegisterEmail) == .orderedSame
        }) else {
            blueRiverMorphShowToast("This email has been registered.", kind: .error)
            return
        }

        whisperWaveEmail = voiceRegisterEmail
        whisperWavePassword = voiceRegisterPassword
        whisperWaveConfirmPassword = voiceRegisterConfirmPassword
        blueRiverMorphIsNavigating = true
        PrismTrailPulseToastLoadingCenter.shared.showLoading("Loading...", showsMask: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + blueRiverMorphRegisterLoadingDelay) {
            PrismTrailPulseToastLoadingCenter.shared.hideLoading()
            voiceProfileShowsRegisterEdit = true
            blueRiverMorphIsNavigating = false
        }
    }

    private func blueRiverMorphHandleForgotPassword() {
        let voiceResetEmail = whisperWaveEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !voiceResetEmail.isEmpty else {
            blueRiverMorphShowToast("Please enter your email.", kind: .normal)
            return
        }
        guard VoiceUserProfileStore.readAll().contains(where: {
            $0.voiceUserEmail.caseInsensitiveCompare(voiceResetEmail) == .orderedSame
        }) else {
            blueRiverMorphShowToast("This email is not registered.", kind: .error)
            return
        }
        guard !whisperWavePassword.isEmpty else {
            blueRiverMorphShowToast("Please enter a new password.", kind: .normal)
            return
        }
        guard whisperWavePassword == whisperWaveConfirmPassword else {
            blueRiverMorphShowToast("The two passwords are different.", kind: .error)
            return
        }

        if let voiceResetUser = VoiceUserProfileStore.readAll().first(where: {
            $0.voiceUserEmail.caseInsensitiveCompare(voiceResetEmail) == .orderedSame
        }) {
            VoiceUserProfileStore.update(id: voiceResetUser.voiceUserID) { voiceUser in
                voiceUser.voiceUserPassword = whisperWavePassword
            }
            blueRiverMorphSwitchMode(.signIn)
            blueRiverMorphShowToast("Password updated.", kind: .success)
        }
    }

    private func blueRiverMorphShowToast(_ voiceMessage: String, kind voiceKind: PrismTrailPulseToastKind) {
        PrismTrailPulseToastLoadingCenter.shared.showToast(voiceMessage, kind: voiceKind)
    }

    private func blueRiverMorphBackTapped() {
        guard !blueRiverMorphIsNavigating else {
            return
        }

        if voicePulseAuthMode == .signIn || voicePulseAuthMode == .signUp {
            blueRiverMorphClearFocus()
            onBackToGuide()
        } else {
            blueRiverMorphSwitchMode(.signIn)
        }
    }

    private func blueRiverMorphClearFocus() {
        voicePulseFocusedField = nil
    }
}

enum BlueRiverMorphAuthMode {
    case signIn
    case signUp
    case forgotPassword

    var title: String {
        switch self {
        case .signIn:
            return "Sign in"
        case .signUp:
            return "Sign up"
        case .forgotPassword:
            return "Forget\npassword"
        }
    }

    var actionTitle: String {
        switch self {
        case .signIn:
            return "Log in"
        case .signUp:
            return "Sign up"
        case .forgotPassword:
            return "Save"
        }
    }

    var needsConfirmPassword: Bool {
        self != .signIn
    }
}

private enum BlueRiverMorphAuthField: Hashable {
    case email
    case password
    case confirmPassword
}

private struct BlueRiverMorphAuthBackdrop: View {
    var body: some View {
        Image("HIVV_main_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

private struct BlueRiverMorphTopRoundedShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let voicePulseRadius = min(radius, rect.width / 2, rect.height / 2)
        var whisperWavePath = Path()

        whisperWavePath.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        whisperWavePath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + voicePulseRadius))
        whisperWavePath.addQuadCurve(
            to: CGPoint(x: rect.minX + voicePulseRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        whisperWavePath.addLine(to: CGPoint(x: rect.maxX - voicePulseRadius, y: rect.minY))
        whisperWavePath.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + voicePulseRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        whisperWavePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        whisperWavePath.closeSubpath()

        return whisperWavePath
    }
}

private struct BlueRiverMorphAuthTopBar: View {
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

private struct BlueRiverMorphAuthTitle: View {
    let mode: BlueRiverMorphAuthMode

    var body: some View {
        Text(mode.title)
            .font(VoiceWhisperFontKit.bold(36))
            .italic()
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .id(mode.title)
            .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}

private struct BlueRiverMorphAuthInputField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let focusedField: FocusState<BlueRiverMorphAuthField?>.Binding
    let field: BlueRiverMorphAuthField
    let fillColor: Color

    var body: some View {
        HStack(spacing: 9) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)

            Group {
                if isSecure {
                    SecureField("", text: $text, prompt: prompt)
                } else {
                    TextField("", text: $text, prompt: prompt)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
            }
            .font(VoiceWhisperFontKit.regular(16))
            .foregroundColor(Color(red: 0.10, green: 0.17, blue: 0.24))
            .tint(Color(red: 0.10, green: 0.17, blue: 0.24))
            .focused(focusedField, equals: field)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(fillColor)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .onTapGesture {
            focusedField.wrappedValue = field
        }
        .padding(.horizontal, 30)
    }

    private var prompt: Text {
        Text(placeholder)
            .font(VoiceWhisperFontKit.regular(16))
            .foregroundColor(Color(red: 0.50, green: 0.58, blue: 0.62))
    }
}

private struct BlueRiverMorphForgetButton: View {
    let action: () -> Void

    var body: some View {
        HStack{
            Spacer()
            Button(action: action) {
                Text("Forgot ?")
                    .font(VoiceWhisperFontKit.bold(16))
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
        }.padding(.horizontal, 30)
        
    }
}

private struct BlueRiverMorphPrimaryButton: View {
    let title: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(VoiceWhisperFontKit.bold(20))
                .foregroundColor(.black)
                .frame(width: 229, height: 64)
                .background(gradient)
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("BlueRiver Morph - Auth Entry") {
    let _ = VoiceWhisperFontKit.registerFonts()
    BlueRiverMorphAuthEntryPage()
}
