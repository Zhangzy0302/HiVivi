import SwiftUI
import WebKit

struct NobleSpringSurfWebPage: View {
    let nobleSpringSurfWebAddress: String
    let onBack: () -> Void

    @State private var nobleSpringSurfShowsWebView = false

    private let nobleSpringSurfScreenWidth: CGFloat = 390

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }

            VStack(spacing: 0) {
                NobleSpringSurfWebTopBar(onBack: onBack)

                ZStack {
                    Color.white

                    if nobleSpringSurfShowsWebView {
                        NobleSpringSurfWebView(nobleSpringSurfWebAddress: nobleSpringSurfWebAddress)
                    } else {
                        NobleSpringSurfWebLoadingState()
                    }
                }
                .frame(width: nobleSpringSurfScreenWidth)
                .frame(maxHeight: .infinity)
            }
            .frame(width: nobleSpringSurfScreenWidth)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            NobleSpringSurfWebPreheater.warmUp()
            DispatchQueue.main.async {
                nobleSpringSurfShowsWebView = true
            }
        }
        .onChange(of: nobleSpringSurfWebAddress) { _ in
            nobleSpringSurfShowsWebView = false
            DispatchQueue.main.async {
                nobleSpringSurfShowsWebView = true
            }
        }
    }
}

private struct NobleSpringSurfWebTopBar: View {
    let onBack: () -> Void

    var body: some View {
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
        .padding(.horizontal, 20)
        .frame(width: 390, height: 68, alignment: .topLeading)
    }
}

private struct NobleSpringSurfWebView: UIViewRepresentable {
    let nobleSpringSurfWebAddress: String

    func makeUIView(context: Context) -> WKWebView {
        let nobleSpringSurfConfiguration = NobleSpringSurfWebPreheater.nobleSpringSurfMakeConfiguration()
        let nobleSpringSurfView = WKWebView(frame: .zero, configuration: nobleSpringSurfConfiguration)
        nobleSpringSurfView.scrollView.backgroundColor = .white
        nobleSpringSurfView.backgroundColor = .white
        nobleSpringSurfView.isOpaque = true
        return nobleSpringSurfView
    }

    func updateUIView(_ nobleSpringSurfView: WKWebView, context: Context) {
        guard let nobleSpringSurfURL = nobleSpringSurfResolvedURL(from: nobleSpringSurfWebAddress) else {
            nobleSpringSurfView.loadHTMLString(NobleSpringSurfWebEmptyState.invalidAddressHTML, baseURL: nil)
            return
        }

        if nobleSpringSurfView.url != nobleSpringSurfURL {
            nobleSpringSurfView.load(URLRequest(url: nobleSpringSurfURL))
        }
    }

    private func nobleSpringSurfResolvedURL(from nobleSpringSurfRawAddress: String) -> URL? {
        let nobleSpringSurfTrimmedAddress = nobleSpringSurfRawAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nobleSpringSurfTrimmedAddress.isEmpty else { return nil }

        if let nobleSpringSurfURL = URL(string: nobleSpringSurfTrimmedAddress),
           nobleSpringSurfURL.scheme != nil {
            return nobleSpringSurfURL
        }

        return URL(string: "https://\(nobleSpringSurfTrimmedAddress)")
    }
}

private struct NobleSpringSurfWebLoadingState: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: VoiceEchoStyleKit.prismTrailPulsePurple))
    }
}

enum NobleSpringSurfWebPreheater {
    private static var nobleSpringSurfDidWarmUp = false
    private static var nobleSpringSurfWarmView: WKWebView?

    static func nobleSpringSurfMakeConfiguration() -> WKWebViewConfiguration {
        let nobleSpringSurfConfiguration = WKWebViewConfiguration()
        nobleSpringSurfConfiguration.suppressesIncrementalRendering = false
        return nobleSpringSurfConfiguration
    }

    static func warmUp() {
        guard !nobleSpringSurfDidWarmUp else {
            return
        }

        nobleSpringSurfDidWarmUp = true
        DispatchQueue.main.async {
            let nobleSpringSurfView = WKWebView(frame: .zero, configuration: nobleSpringSurfMakeConfiguration())
            nobleSpringSurfView.loadHTMLString("<html><body></body></html>", baseURL: nil)
            nobleSpringSurfWarmView = nobleSpringSurfView
        }
    }
}

private enum NobleSpringSurfWebEmptyState {
    static let invalidAddressHTML = """
    <!doctype html>
    <html>
    <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
    body {
        margin: 0;
        height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        color: #202024;
        background: #ffffff;
    }
    </style>
    </head>
    <body>Invalid web address</body>
    </html>
    """
}

#Preview("NobleSpring Surf - Web") {
    let _ = VoiceWhisperFontKit.registerFonts()
    NobleSpringSurfWebPage(
        nobleSpringSurfWebAddress: "https://www.apple.com",
        onBack: {}
    )
}
