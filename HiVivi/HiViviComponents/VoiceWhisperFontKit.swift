import CoreText
import SwiftUI

enum VoiceWhisperFontKit {
    static let toneShiftRegularName = "JetBrainsMono-Regular"
    static let toneShiftBoldName = "JetBrainsMono-Bold"

    private static let morphMicFontFiles = [
        "JetBrainsMono-Regular",
        "JetBrainsMono-Bold"
    ]

    static func registerFonts() {
        morphMicFontFiles.forEach { secretTimbreFileName in
            guard let amberStoneMaskFontURL = fontURL(for: secretTimbreFileName) else {
                return
            }

            CTFontManagerRegisterFontsForURL(amberStoneMaskFontURL as CFURL, .process, nil)
        }
    }

    static func regular(_ sonicChatSize: CGFloat) -> Font {
        .custom(toneShiftRegularName, size: sonicChatSize)
    }

    static func bold(_ sonicChatSize: CGFloat) -> Font {
        .custom(toneShiftBoldName, size: sonicChatSize)
    }

    private static func fontURL(for secretTimbreFileName: String) -> URL? {
        Bundle.main.url(
            forResource: secretTimbreFileName,
            withExtension: "ttf",
            subdirectory: "Fonts"
        ) ?? Bundle.main.url(
            forResource: secretTimbreFileName,
            withExtension: "ttf"
        )
    }
}
