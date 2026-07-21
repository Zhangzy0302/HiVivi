import SwiftUI
import WebKit

struct NobleSpringSurfWebPage: View {
    let nobleSpringSurfWebAddress: String
    let onBack: () -> Void

    @State private var nobleSpringSurfShowsWebView = false
    @State private var nobleSpringSurfIsLoading = true
    @State private var nobleSpringSurfLoadError: String?
    @State private var nobleSpringSurfReloadID = UUID()

    private let nobleSpringSurfScreenWidth: CGFloat = 390

    var body: some View {
        Group {
            if nobleSpringSurfIsBPackageWeb {
                ObsidianSereinProtectedWebPage(
                    obsidianSereinAddress: nobleSpringSurfWebAddress,
                    obsidianSereinCloseAction: onBack
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            } else {
                ZStack(alignment: .top) {
                    GeometryReader { _ in
                        VoiceRippleMainBackdrop()
                    }

                    VStack(spacing: 0) {
                        NobleSpringSurfWebTopBar(onBack: onBack)

                        ZStack {
                            Color.white

                            if nobleSpringSurfShowsWebView {
                                NobleSpringSurfWebView(
                                    nobleSpringSurfWebAddress: nobleSpringSurfWebAddress,
                                    nobleSpringSurfLoadingStarted: nobleSpringSurfLoadingStarted,
                                    nobleSpringSurfLoadingFinished: nobleSpringSurfLoadingFinished,
                                    nobleSpringSurfLoadingFailed: nobleSpringSurfLoadingFailed
                                )
                                .id(nobleSpringSurfReloadID)
                            }

                            if nobleSpringSurfIsLoading {
                                NobleSpringSurfWebLoadingState()
                            }

                            if let nobleSpringSurfLoadError {
                                NobleSpringSurfWebErrorState(
                                    nobleSpringSurfMessage: nobleSpringSurfLoadError,
                                    nobleSpringSurfRetryAction: nobleSpringSurfRetry
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            NobleSpringSurfWebPreheater.warmUp()
            DispatchQueue.main.async {
                nobleSpringSurfShowsWebView = true
            }
        }
        .onChange(of: nobleSpringSurfWebAddress) { _ in
            nobleSpringSurfIsLoading = true
            nobleSpringSurfLoadError = nil
            nobleSpringSurfShowsWebView = false
            DispatchQueue.main.async {
                nobleSpringSurfShowsWebView = true
            }
        }
    }

    private var nobleSpringSurfIsBPackageWeb: Bool {
        guard let nobleSpringSurfURL = NobleSpringSurfURLResolver.resolve(nobleSpringSurfWebAddress),
              let nobleSpringSurfComponents = URLComponents(url: nobleSpringSurfURL, resolvingAgainstBaseURL: false) else {
            return false
        }

        let nobleSpringSurfQueryNames = Set(nobleSpringSurfComponents.queryItems?.map(\.name) ?? [])
        return nobleSpringSurfQueryNames.contains("openParams") || nobleSpringSurfQueryNames.contains("appId")
    }

    private func nobleSpringSurfLoadingStarted() {
        nobleSpringSurfLoadError = nil
        nobleSpringSurfIsLoading = true
    }

    private func nobleSpringSurfLoadingFinished() {
        nobleSpringSurfIsLoading = false
    }

    private func nobleSpringSurfLoadingFailed(_ nobleSpringSurfMessage: String) {
        nobleSpringSurfIsLoading = false
        nobleSpringSurfLoadError = nobleSpringSurfMessage
    }

    private func nobleSpringSurfRetry() {
        nobleSpringSurfLoadError = nil
        nobleSpringSurfIsLoading = true
        nobleSpringSurfReloadID = UUID()
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
    let nobleSpringSurfLoadingStarted: () -> Void
    let nobleSpringSurfLoadingFinished: () -> Void
    let nobleSpringSurfLoadingFailed: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let nobleSpringSurfConfiguration = NobleSpringSurfWebPreheater.nobleSpringSurfMakeConfiguration()
        let nobleSpringSurfView = WKWebView(frame: .zero, configuration: nobleSpringSurfConfiguration)
        nobleSpringSurfView.scrollView.backgroundColor = .clear
        nobleSpringSurfView.backgroundColor = .clear
        nobleSpringSurfView.isOpaque = false
        nobleSpringSurfView.navigationDelegate = context.coordinator
        nobleSpringSurfView.uiDelegate = context.coordinator
        nobleSpringSurfView.allowsBackForwardNavigationGestures = true
        nobleSpringSurfView.scrollView.contentInsetAdjustmentBehavior = .never
        nobleSpringSurfView.scrollView.contentInset = .zero
        nobleSpringSurfView.scrollView.scrollIndicatorInsets = .zero
        return nobleSpringSurfView
    }

    func updateUIView(_ nobleSpringSurfView: WKWebView, context: Context) {
        context.coordinator.parent = self

        guard let nobleSpringSurfURL = NobleSpringSurfURLResolver.resolve(nobleSpringSurfWebAddress) else {
            nobleSpringSurfView.loadHTMLString(NobleSpringSurfWebEmptyState.invalidAddressHTML, baseURL: nil)
            nobleSpringSurfLoadingFailed("Invalid web address")
            return
        }

        if nobleSpringSurfView.url != nobleSpringSurfURL {
            nobleSpringSurfView.load(URLRequest(url: nobleSpringSurfURL))
        }
    }

    static func dismantleUIView(_ nobleSpringSurfView: WKWebView, coordinator: Coordinator) {
        nobleSpringSurfView.navigationDelegate = nil
        nobleSpringSurfView.uiDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: NobleSpringSurfWebView

        init(parent: NobleSpringSurfWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.nobleSpringSurfLoadingStarted()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.nobleSpringSurfLoadingFinished()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.nobleSpringSurfLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.nobleSpringSurfLoadingFailed(error.localizedDescription)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let nobleSpringSurfURL = navigationAction.request.url,
                  let nobleSpringSurfScheme = nobleSpringSurfURL.scheme?.lowercased() else {
                decisionHandler(.cancel)
                return
            }

            if ["http", "https", "file", "about"].contains(nobleSpringSurfScheme) {
                decisionHandler(.allow)
                return
            }

            UIApplication.shared.open(nobleSpringSurfURL)
            decisionHandler(.cancel)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard let nobleSpringSurfURL = navigationAction.request.url else { return nil }
            webView.load(URLRequest(url: nobleSpringSurfURL))
            return nil
        }
    }
}

private struct NobleSpringSurfWebLoadingState: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: VoiceEchoStyleKit.prismTrailPulsePurple))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
    }
}

private struct NobleSpringSurfWebErrorState: View {
    let nobleSpringSurfMessage: String
    let nobleSpringSurfRetryAction: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(VoiceEchoStyleKit.prismTrailPulsePurple)

            Text("Load failed")
                .font(VoiceWhisperFontKit.bold(18))
                .foregroundColor(.black)

            Text(nobleSpringSurfMessage)
                .font(VoiceWhisperFontKit.regular(13))
                .foregroundColor(.black.opacity(0.62))
                .multilineTextAlignment(.center)

            Button("Retry", action: nobleSpringSurfRetryAction)
                .font(VoiceWhisperFontKit.bold(15))
                .foregroundColor(.white)
                .frame(width: 126, height: 44)
                .background(VoiceEchoStyleKit.prismTrailPulsePurple)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

private enum NobleSpringSurfURLResolver {
    static func resolve(_ nobleSpringSurfRawAddress: String) -> URL? {
        let nobleSpringSurfTrimmedAddress = nobleSpringSurfRawAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nobleSpringSurfTrimmedAddress.isEmpty == false else { return nil }

        if let nobleSpringSurfURL = URL(string: nobleSpringSurfTrimmedAddress),
           nobleSpringSurfURL.scheme?.isEmpty == false {
            return nobleSpringSurfURL
        }

        return URL(string: "https://\(nobleSpringSurfTrimmedAddress)")
    }
}

@MainActor
enum NobleSpringSurfWebPreheater {
    private static var nobleSpringSurfDidWarmUp = false
    private static var nobleSpringSurfWarmView: WKWebView?

    static func nobleSpringSurfMakeConfiguration() -> WKWebViewConfiguration {
        let nobleSpringSurfConfiguration = WKWebViewConfiguration()
        nobleSpringSurfConfiguration.websiteDataStore = .default()
        nobleSpringSurfConfiguration.suppressesIncrementalRendering = false
        return nobleSpringSurfConfiguration
    }

    static func nobleSpringSurfReleaseWarmView() {
        nobleSpringSurfWarmView = nil
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
