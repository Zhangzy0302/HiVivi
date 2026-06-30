import SwiftUI

struct VoiceImageSourceView: View {
    let voiceImageAddress: String
    var contentMode: ContentMode = .fit

    private var voiceResolvedImageAddress: String {
        voiceImageAddress.isEmpty ? VoiceEchoStyleKit.voiceDefaultAvatarName : voiceImageAddress
    }

    var body: some View {
        Group {
            if let voiceFileImage = VoiceImageSourceLoader.loadFileImage(from: voiceResolvedImageAddress) {
                Image(uiImage: voiceFileImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Image(voiceResolvedImageAddress)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            }
        }
    }
}

enum VoiceImageSourceLoader {
    static func loadFileImage(from voiceImageAddress: String) -> UIImage? {
        guard let voiceFilePath = voiceFilePath(from: voiceImageAddress) else {
            return nil
        }
        return UIImage(contentsOfFile: voiceFilePath)
    }

    private static func voiceFilePath(from voiceImageAddress: String) -> String? {
        if voiceImageAddress.hasPrefix("file://"),
           let voiceFileURL = URL(string: voiceImageAddress),
           voiceFileURL.isFileURL {
            return voiceFileURL.path
        }

        if voiceImageAddress.hasPrefix("/") {
            return voiceImageAddress
        }

        return nil
    }
}

#Preview("Voice Image Source - Asset") {
    VoiceImageSourceView(voiceImageAddress: VoiceEchoStyleKit.voiceDefaultAvatarName, contentMode: .fill)
        .frame(width: 90, height: 90)
        .clipShape(Circle())
}
