import SwiftUI
import UIKit

struct HarborMintReportReasonPage: View {
    let onBack: () -> Void
    let onFinish: (String) -> Void

    @State private var harborMintReportReasonText = ""
    @State private var harborMintReportReasonFocused = false

    private let harborMintReportWidth: CGFloat = 390
    private let harborMintReportPanelColor = VoiceEchoStyleKit.voiceMossPanel
    private let harborMintReportPlaceholder = "Please describe what you want to\nreport."

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }
                .contentShape(Rectangle())
                .onTapGesture {
                    harborMintReportReasonFocused = false
                }

            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image("HIVV_back_btn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .frame(width: 58, height: 58)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 18)

                Text("Feedback issues")
                    .font(VoiceWhisperFontKit.bold(17))
                    .foregroundColor(.white)
                    .padding(.top, 6)

                ZStack(alignment: .topLeading) {
                    HarborMintReportReasonTextView(
                        text: $harborMintReportReasonText,
                        isFocused: $harborMintReportReasonFocused,
                        textColor: UIColor.white.withAlphaComponent(0.88)
                    )
                    .padding(20)

                    if harborMintReportReasonText.isEmpty {
                        Text(harborMintReportPlaceholder)
                            .font(VoiceWhisperFontKit.regular(15))
                            .foregroundColor(.white.opacity(0.62))
                            .lineSpacing(3)
                            .padding(.leading, 18)
                            .padding(.top, 19)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 312)
                .background(harborMintReportPanelColor)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.top, 36)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
                .onTapGesture {
                    harborMintReportReasonFocused = true
                }

                Spacer()

                Button(action: harborMintReportFinishTapped) {
                    Text("Finish")
                        .font(VoiceWhisperFontKit.bold(18))
                        .foregroundColor(.black)
                        .frame(width: 238, height: 55)
                        .background(VoiceEchoStyleKit.toneActionGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 78)
            }
            .frame(width: harborMintReportWidth)
        }
        .ignoresSafeArea(edges: .bottom)
        .voiceEdgeSwipeBack(onBack: onBack)
    }

    private func harborMintReportFinishTapped() {
        harborMintReportReasonFocused = false
        onFinish(harborMintReportReasonText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

private struct HarborMintReportReasonTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    let textColor: UIColor

    private var harborMintReportFont: UIFont {
        UIFont(name: VoiceWhisperFontKit.toneShiftRegularName, size: 15) ?? .systemFont(ofSize: 15)
    }

    func makeUIView(context: Context) -> UITextView {
        let harborMintTextView = UITextView()
        harborMintTextView.delegate = context.coordinator
        harborMintTextView.backgroundColor = .clear
        harborMintTextView.isOpaque = false
        harborMintTextView.textColor = textColor
        harborMintTextView.tintColor = textColor
        harborMintTextView.font = harborMintReportFont
        harborMintTextView.textContainerInset = .zero
        harborMintTextView.textContainer.lineFragmentPadding = 0
        harborMintTextView.keyboardDismissMode = .interactive
        return harborMintTextView
    }

    func updateUIView(_ harborMintTextView: UITextView, context: Context) {
        context.coordinator.parent = self

        if harborMintTextView.text != text {
            harborMintTextView.text = text
        }

        harborMintTextView.backgroundColor = .clear
        harborMintTextView.textColor = textColor
        harborMintTextView.tintColor = textColor
        harborMintTextView.font = harborMintReportFont

        if isFocused, !harborMintTextView.isFirstResponder {
            harborMintTextView.becomeFirstResponder()
        } else if !isFocused, harborMintTextView.isFirstResponder {
            harborMintTextView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: HarborMintReportReasonTextView

        init(parent: HarborMintReportReasonTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }
    }
}

#Preview("HarborMint Report Reason") {
    let _ = VoiceWhisperFontKit.registerFonts()
    HarborMintReportReasonPage(
        onBack: {},
        onFinish: { _ in }
    )
}
