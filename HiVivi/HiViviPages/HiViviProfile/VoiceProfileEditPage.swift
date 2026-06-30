import PhotosUI
import SwiftUI

struct VoiceProfileDraft {
    var email: String?
    var password: String?
    var avatarName: String
    var nickname: String
    var birthday: String
    var location: String
    var gender: VoiceProfileGender
}

enum VoiceProfileGender {
    case female
    case male
}

struct VoiceProfileEditPage: View {
    let registerEmail: String?
    let registerPassword: String?
    let onBack: () -> Void
    let onSave: (VoiceProfileDraft) -> Void
    let onRegisterComplete: (String) -> Void

    @State private var profileBloomNameNickname: String
    @State private var sonicAvatarSelectedName: String
    @State private var toneBirthBirthday: String
    @State private var toneBirthSelectedDate: Date
    @State private var chatPlaceLocation: String
    @State private var voiceGenderSelection: VoiceProfileGender
    @State private var toneProfileActiveChoice: VoiceProfileChoicePanel?
    @State private var profileBloomAvatarShowsPicker = false
    @State private var voiceProfileShowsPhotoPicker = false
    @State private var voiceProfileIsSavingRegistration = false
    @FocusState private var whisperProfileFocusedField: VoiceProfileField?

    private let profileBloomMintFill = Color(red: 0.86, green: 0.94, blue: 0.89)
    private let profileBloomTextDark = Color(red: 0.50, green: 0.58, blue: 0.62)
    private let profileBloomPlaceOptions = ["La", "New York", "Miami", "Chicago", "Seattle"]
    private let sonicAvatarOptions = [
        VoiceEchoStyleKit.voiceDefaultAvatarName,
        "HIVVI_ava_0",
        "HIVVI_ava_1",
        "HIVVI_ava_2",
        "HIVVI_ava_3",
        "HIVVI_ava_4",
        "HIVVI_ava_5"
    ]
    private let voiceProfileRegisterLoadingDelay: TimeInterval = 0.65
    private static let toneBirthFormatter: DateFormatter = {
        let toneBirthFormatter = DateFormatter()
        toneBirthFormatter.dateFormat = "yyyy-MM-dd"
        toneBirthFormatter.locale = Locale(identifier: "en_US_POSIX")
        return toneBirthFormatter
    }()

    init(
        registerEmail: String? = nil,
        registerPassword: String? = nil,
        avatarName: String = VoiceEchoStyleKit.voiceDefaultAvatarName,
        nickname: String = "",
        birthday: String = "2003-01-01",
        location: String = "La",
        gender: VoiceProfileGender = .female,
        onBack: @escaping () -> Void = {},
        onSave: @escaping (VoiceProfileDraft) -> Void = { _ in },
        onRegisterComplete: @escaping (String) -> Void = { _ in }
    ) {
        self.registerEmail = registerEmail
        self.registerPassword = registerPassword
        self.onBack = onBack
        self.onSave = onSave
        self.onRegisterComplete = onRegisterComplete
        _profileBloomNameNickname = State(initialValue: nickname)
        _sonicAvatarSelectedName = State(initialValue: avatarName.isEmpty ? VoiceEchoStyleKit.voiceDefaultAvatarName : avatarName)
        _toneBirthBirthday = State(initialValue: birthday)
        _toneBirthSelectedDate = State(initialValue: Self.voiceProfileDate(from: birthday))
        _chatPlaceLocation = State(initialValue: location)
        _voiceGenderSelection = State(initialValue: gender)
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }
                .contentShape(Rectangle())
                .onTapGesture {
                    voiceProfileClearEditingState()
                }

            VStack(spacing: 0) {
                Button(action: voiceProfileBackTapped) {
                    Image("HIVV_back_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .frame(width: 58, height: 58)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
                .padding(.horizontal, 18)

                ZStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                            .frame(height: 70)

                        VoiceProfileFieldTitle(title: "Nickname:")

                        VoiceProfileInputCapsule(
                            placeholder: "Please enter",
                            text: $profileBloomNameNickname,
                            focusedField: $whisperProfileFocusedField,
                            field: .nickname,
                            fillColor: profileBloomMintFill,
                            textColor: profileBloomTextDark,
                            isFocused: whisperProfileFocusedField == .nickname
                        )
                        .padding(.top, 13)

                        VoiceProfileFieldTitle(title: "Birthday:")
                            .padding(.top, 18)

                        VoiceProfilePickerCapsule(
                            value: toneBirthBirthday,
                            fillColor: profileBloomMintFill,
                            textColor: profileBloomTextDark,
                            isExpanded: toneProfileActiveChoice == .birthday
                        ) {
                            voiceProfileToggleChoice(.birthday)
                        }
                        .padding(.top, 13)

                        VoiceProfileFieldTitle(title: "Location:")
                            .padding(.top, 18)

                        VoiceProfilePickerCapsule(
                            value: chatPlaceLocation,
                            fillColor: profileBloomMintFill,
                            textColor: profileBloomTextDark,
                            isExpanded: toneProfileActiveChoice == .location
                        ) {
                            voiceProfileToggleChoice(.location)
                        }
                        .padding(.top, 13)

                        VoiceProfileFieldTitle(title: "Gender:")
                            .padding(.top, 18)

                        HStack(spacing: 51) {
                            VoiceProfileGenderButton(
                                title: "Female",
                                imageName: "HIVV_female",
                                isSelected: voiceGenderSelection == .female
                            ) {
                                voiceProfileClearEditingState()
                                voiceGenderSelection = .female
                            }

                            VoiceProfileGenderButton(
                                title: "Male",
                                imageName: "HIVV_male",
                                isSelected: voiceGenderSelection == .male
                            ) {
                                voiceProfileClearEditingState()
                                voiceGenderSelection = .male
                            }
                        }
                        .padding(.top, 14)

                        Button(action: voiceProfileSaveTapped) {
                            Text("Save")
                                .font(VoiceWhisperFontKit.bold(21))
                                .foregroundColor(.black)
                                .frame(width: 216, height: 59)
                                .background(VoiceEchoStyleKit.toneActionGradient)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(!voiceProfileIsSavingRegistration)
                        .opacity(voiceProfileIsSavingRegistration ? 0.72 : 1)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .frame(width: 390, height: 652, alignment: .top)
                    .background(
                        VoiceEchoStyleKit.voiceShadowPanel
                            .contentShape(Rectangle())
                            .onTapGesture {
                                voiceProfileClearEditingState()
                            }
                    )
                    
                    .clipShape(VoiceRippleTopRoundedShape(radius: 34))
                    .overlay(alignment: .topLeading) {
                        voiceProfileChoiceOverlay
                    }
                    .padding(.top, 54)

                    VoiceProfileAvatarEditor(
                        avatarName: sonicAvatarSelectedName,
                        isExpanded: profileBloomAvatarShowsPicker
                    ) {
                        voiceProfileToggleAvatarPicker()
                    }
                }
                .padding(.top, 2)
            }

        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeOut(duration: 0.18), value: profileBloomAvatarShowsPicker)
        .sheet(isPresented: $voiceProfileShowsPhotoPicker) {
            VoiceProfilePhotoPicker { voiceProfileImage in
                voiceProfileSavePickedAvatar(voiceProfileImage)
            }
        }
        .onChange(of: voiceProfileShowsPhotoPicker) { voiceProfileIsPresented in
            if !voiceProfileIsPresented {
                profileBloomAvatarShowsPicker = false
            }
        }
    }

    private func voiceProfileSaveTapped() {
        guard !voiceProfileIsSavingRegistration else {
            return
        }

        voiceProfileClearEditingState()
        let profileBloomTrimmedNickname = profileBloomNameNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !profileBloomTrimmedNickname.isEmpty else {
            PrismTrailPulseToastLoadingCenter.shared.showToast("Please enter nickname", kind: .normal)
            return
        }

        let voiceProfileDraft = VoiceProfileDraft(
            email: registerEmail,
            password: registerPassword,
            avatarName: sonicAvatarSelectedName,
            nickname: profileBloomTrimmedNickname,
            birthday: toneBirthBirthday,
            location: chatPlaceLocation,
            gender: voiceGenderSelection
        )

        if let voiceRegisterEmail = registerEmail,
           let voiceRegisterPassword = registerPassword {
            let voiceCreatedUser = voiceProfileCreateRegisteredUser(
                email: voiceRegisterEmail,
                password: voiceRegisterPassword,
                draft: voiceProfileDraft
            )
            VoiceUserProfileStore.create(voiceCreatedUser)
            voiceProfileIsSavingRegistration = true
            PrismTrailPulseToastLoadingCenter.shared.showLoading("Loading...", showsMask: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + voiceProfileRegisterLoadingDelay) {
                PrismTrailPulseToastLoadingCenter.shared.hideLoading()
                onRegisterComplete(voiceCreatedUser.voiceUserID)
                voiceProfileIsSavingRegistration = false
            }
        } else {
            onSave(voiceProfileDraft)
        }
    }

    private func voiceProfileBackTapped() {
        guard !voiceProfileIsSavingRegistration else {
            return
        }

        onBack()
    }

    private func voiceProfileCreateRegisteredUser(
        email: String,
        password: String,
        draft: VoiceProfileDraft
    ) -> VoiceUserProfileData {
        VoiceUserProfileData(
            voiceUserID: VoiceUserProfileStore.makeShortUserID(),
            voiceUserEmail: email,
            voiceUserPassword: password,
            voiceUserAvatar: draft.avatarName.isEmpty ? VoiceEchoStyleKit.voiceDefaultAvatarName : draft.avatarName,
            voiceUserName: draft.nickname.trimmingCharacters(in: .whitespacesAndNewlines),
            voiceUserBirthday: voiceProfileBirthdayDate(from: draft.birthday),
            voiceUserLocation: draft.location,
            voiceUserGender: voiceProfileUserGender(from: draft.gender),
            voiceUserFriendIDs: [],
            voiceUserFriendRequestIDs: [],
            voiceUserBlockedIDs: [],
            voiceUserCoinCount: 0,
            voiceUserIsGuest: false
        )
    }

    private func voiceProfileBirthdayDate(from birthday: String) -> Date {
        let toneBirthFormatter = DateFormatter()
        toneBirthFormatter.dateFormat = "yyyy-MM-dd"
        toneBirthFormatter.locale = Locale(identifier: "en_US_POSIX")
        return toneBirthFormatter.date(from: birthday) ?? Date()
    }

    private func voiceProfileUserGender(from gender: VoiceProfileGender) -> VoiceUserGender {
        switch gender {
        case .female:
            return .female
        case .male:
            return .male
        }
    }

    private var voiceProfileChoiceOverlay: some View {
        Group {
            switch toneProfileActiveChoice {
            case .birthday:
                VoiceProfileDatePickerPanel(
                    selectedDate: $toneBirthSelectedDate,
                    fillColor: profileBloomMintFill,
                    textColor: profileBloomTextDark
                )
                .onChange(of: toneBirthSelectedDate) { toneNewBirthday in
                    toneBirthBirthday = Self.toneBirthFormatter.string(from: toneNewBirthday)
                }
                .padding(.top, 311)
            case .location:
                VoiceProfileChoiceList(
                    values: profileBloomPlaceOptions,
                    selectedValue: chatPlaceLocation,
                    fillColor: profileBloomMintFill,
                    textColor: profileBloomTextDark
                ) { profileBloomChoiceLocation in
                    chatPlaceLocation = profileBloomChoiceLocation
                    toneProfileActiveChoice = nil
                }
                .padding(.top, 421)
            case .none:
                EmptyView()
            }
        }
        .padding(.leading, 18)
        .zIndex(4)
    }

    private func voiceProfileToggleChoice(_ choice: VoiceProfileChoicePanel) {
        whisperProfileFocusedField = nil
        profileBloomAvatarShowsPicker = false
        toneProfileActiveChoice = toneProfileActiveChoice == choice ? nil : choice
    }

    private func voiceProfileToggleAvatarPicker() {
        whisperProfileFocusedField = nil
        toneProfileActiveChoice = nil
        profileBloomAvatarShowsPicker = true
        voiceProfileShowsPhotoPicker = true
    }

    private func voiceProfileClearEditingState() {
        whisperProfileFocusedField = nil
        toneProfileActiveChoice = nil
        profileBloomAvatarShowsPicker = false
    }

    private static func voiceProfileDate(from birthday: String) -> Date {
        toneBirthFormatter.date(from: birthday) ?? Date()
    }

    private func voiceProfileSavePickedAvatar(_ voiceProfileImage: UIImage) {
        do {
            sonicAvatarSelectedName = try VoiceProfileAvatarImageStore.save(image: voiceProfileImage)
            profileBloomAvatarShowsPicker = false
        } catch {
            profileBloomAvatarShowsPicker = false
            PrismTrailPulseToastLoadingCenter.shared.showToast("Avatar upload failed", kind: .error)
        }
    }
}

private enum VoiceProfileField: Hashable {
    case nickname
}

private enum VoiceProfileChoicePanel {
    case birthday
    case location
}

private struct VoiceProfileAvatarEditor: View {
    let avatarName: String
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                VoiceImageSourceView(
                    voiceImageAddress: avatarName,
                    contentMode: .fill
                )
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isExpanded ? VoiceEchoStyleKit.voiceNeonGreen : Color.white, lineWidth: 4)
                    )

                ZStack {
                    Circle()
                        .fill(VoiceEchoStyleKit.prismTrailPulsePurple)
                        .frame(width: 28, height: 28)

                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 3, y: 1)
            }
            .frame(width: 98, height: 98)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct VoiceProfilePhotoPicker: UIViewControllerRepresentable {
    let onPick: (UIImage) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var voiceProfileConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        voiceProfileConfiguration.filter = .images
        voiceProfileConfiguration.selectionLimit = 1

        let voiceProfilePicker = PHPickerViewController(configuration: voiceProfileConfiguration)
        voiceProfilePicker.delegate = context.coordinator
        return voiceProfilePicker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPick: (UIImage) -> Void

        init(onPick: @escaping (UIImage) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let voiceProfileProvider = results.first?.itemProvider,
                  voiceProfileProvider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            voiceProfileProvider.loadObject(ofClass: UIImage.self) { [weak self] voiceProfileObject, _ in
                guard let voiceProfileImage = voiceProfileObject as? UIImage else {
                    return
                }

                DispatchQueue.main.async {
                    self?.onPick(voiceProfileImage)
                }
            }
        }
    }
}

private enum VoiceProfileAvatarImageStore {
    static func save(image: UIImage) throws -> String {
        let voiceProfileDirectory = try avatarDirectory()
        let voiceProfileFileURL = voiceProfileDirectory
            .appendingPathComponent("voice_avatar_\(UUID().uuidString)")
            .appendingPathExtension("jpg")

        guard let voiceProfileData = image.jpegData(compressionQuality: 0.88) else {
            throw CocoaError(.fileWriteUnknown)
        }

        try voiceProfileData.write(to: voiceProfileFileURL, options: [.atomic])
        return voiceProfileFileURL.path
    }

    private static func avatarDirectory() throws -> URL {
        let voiceProfileDocumentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let voiceProfileAvatarURL = voiceProfileDocumentsURL.appendingPathComponent("HiViviAvatars", isDirectory: true)

        if !FileManager.default.fileExists(atPath: voiceProfileAvatarURL.path) {
            try FileManager.default.createDirectory(
                at: voiceProfileAvatarURL,
                withIntermediateDirectories: true
            )
        }

        return voiceProfileAvatarURL
    }
}

private struct VoiceProfileAvatarChoicePanel: View {
    let avatarNames: [String]
    let selectedAvatarName: String
    let onSelect: (String) -> Void

    private let profileBloomAvatarColumns = [
        GridItem(.fixed(46), spacing: 12),
        GridItem(.fixed(46), spacing: 12),
        GridItem(.fixed(46), spacing: 12),
        GridItem(.fixed(46), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: profileBloomAvatarColumns, spacing: 12) {
            ForEach(avatarNames, id: \.self) { sonicAvatarName in
                Button {
                    onSelect(sonicAvatarName)
                } label: {
                    VoiceImageSourceView(
                        voiceImageAddress: sonicAvatarName,
                        contentMode: .fill
                    )
                    .frame(width: 46, height: 46)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                selectedAvatarName == sonicAvatarName ? VoiceEchoStyleKit.voiceNeonGreen : Color.white.opacity(0.32),
                                lineWidth: selectedAvatarName == sonicAvatarName ? 3 : 1
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(14)
        .background(VoiceEchoStyleKit.voiceShadowPanel)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 14, x: 0, y: 8)
    }
}

private struct VoiceProfileFieldTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(VoiceWhisperFontKit.bold(24))
            .foregroundColor(.white)
    }
}

private struct VoiceProfileInputCapsule: View {
    let placeholder: String
    @Binding var text: String
    let focusedField: FocusState<VoiceProfileField?>.Binding
    let field: VoiceProfileField
    let fillColor: Color
    let textColor: Color
    let isFocused: Bool

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(textColor.opacity(0.9)))
            .font(VoiceWhisperFontKit.regular(17))
            .foregroundColor(textColor)
            .tint(textColor)
            .focused(focusedField, equals: field)
            .padding(.horizontal, 16)
            .frame(width: 354, height: 61)
            .background(fillColor)
            .overlay(
                Capsule()
                    .stroke(isFocused ? VoiceEchoStyleKit.voiceNeonGreen : Color.clear, lineWidth: 2)
            )
            .clipShape(Capsule())
    }
}

private struct VoiceProfilePickerCapsule: View {
    let value: String
    let fillColor: Color
    let textColor: Color
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(value)
                    .font(VoiceWhisperFontKit.regular(17))
                    .foregroundColor(textColor)

                Spacer()

                Image(systemName: "triangle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(VoiceEchoStyleKit.voiceNeonGreen)
                    .rotationEffect(.degrees(isExpanded ? 0 : 180))
            }
            .padding(.horizontal, 16)
            .frame(width: 354, height: 61)
            .background(fillColor)
            .overlay(
                Capsule()
                    .stroke(isExpanded ? VoiceEchoStyleKit.voiceNeonGreen : Color.clear, lineWidth: 2)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct VoiceProfileChoiceList: View {
    let values: [String]
    let selectedValue: String
    let fillColor: Color
    let textColor: Color
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(values, id: \.self) { voiceChoiceValue in
                Button {
                    onSelect(voiceChoiceValue)
                } label: {
                    HStack {
                        Text(voiceChoiceValue)
                            .font(VoiceWhisperFontKit.regular(15))
                            .foregroundColor(textColor)

                        Spacer()

                        if selectedValue == voiceChoiceValue {
                            Circle()
                                .fill(VoiceEchoStyleKit.voiceNeonGreen)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.horizontal, 18)
                    .frame(width: 354, height: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 354, height: CGFloat(values.count) * 36)
        .background(fillColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 8)
    }
}

private struct VoiceProfileDatePickerPanel: View {
    @Binding var selectedDate: Date
    let fillColor: Color
    let textColor: Color

    var body: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            in: ...Date(),
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .accentColor(VoiceEchoStyleKit.prismTrailPulsePurple)
        .colorScheme(.light)
        .frame(width: 330, height: 300)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(fillColor)
        .foregroundColor(textColor)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 8)
    }
}

private struct VoiceProfileGenderButton: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 41, height: 41)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color(red: 0.97, green: 0.43, blue: 0.76) : Color.clear, lineWidth: 3)
                    )

                Text(title)
                    .font(VoiceWhisperFontKit.regular(13))
                    .foregroundColor(.white)
            }
            .frame(width: 72)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Voice Profile - Edit") {
    let _ = VoiceWhisperFontKit.registerFonts()
    VoiceProfileEditPage()
}

#Preview("Voice Profile - Register") {
    let _ = VoiceWhisperFontKit.registerFonts()
    VoiceProfileEditPage(
        registerEmail: "voice@example.com",
        registerPassword: "secret"
    )
}
