import SwiftUI

struct QuiescentMorrowBPackageRoot: View {
    @StateObject private var quiescentMorrowCoordinator = SableCipherInitViewModel()
    @StateObject private var quiescentMorrowLocationManager = ZephyrRuneLocationManager.shared
    @State private var quiescentMorrowLoginInProgress = false
    @State private var quiescentMorrowHasAPackageSession = SilverGardenSessionLoginStore.hasCurrentUser

    var body: some View {
        NavigationView {
            AmberStoneMaskGuideAuthPage()
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var quiescentMorrowContent: some View {
        if quiescentMorrowHasAPackageSession {
            NavigationView {
                VoiceRippleMainNavPage(
                    onLogOut: {
                        quiescentMorrowHasAPackageSession = false
                        quiescentMorrowCoordinator.sableCipherStatus = .sableCipherA
                    }
                )
                .navigationBarHidden(true)
                .voiceNativeSwipeBackEnabled()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            switch quiescentMorrowCoordinator.sableCipherStatus {
            case .sableCipherLoading:
                QuiescentMorrowLoadingView()
            case .sableCipherA:
                NavigationView {
                    AmberStoneMaskGuideAuthPage()
                        .navigationBarHidden(true)
                        .voiceNativeSwipeBackEnabled()
                }
                .navigationViewStyle(StackNavigationViewStyle())
            case .sableCipherB:
                quiescentMorrowBPackageDestination
            }
        }
    }

    @ViewBuilder
    private var quiescentMorrowBPackageDestination: some View {
        if case let .sableCipherAgreement(sableCipherURL: quiescentMorrowAddress)? =
            quiescentMorrowCoordinator.sableCipherNextRoute {
            ObsidianSereinProtectedWebPage(
                obsidianSereinAddress: quiescentMorrowAddress,
                obsidianSereinCloseAction: quiescentMorrowCloseBPackage
            )
        } else {
            QuiescentMorrowQuickLoginView(
                quiescentMorrowIsLoading: quiescentMorrowLoginInProgress,
                quiescentMorrowLoginAction: quiescentMorrowQuickLogin,
                quiescentMorrowCloseAction: quiescentMorrowCloseBPackage
            )
        }
    }

    private func quiescentMorrowQuickLogin() {
        guard quiescentMorrowLoginInProgress == false else { return }
        quiescentMorrowLoginInProgress = true
        Task {
            let quiescentMorrowRoute = await SableCipherInitUtils.shared.sableCipherGoLogin()
            await MainActor.run {
                quiescentMorrowLoginInProgress = false
                if let quiescentMorrowRoute {
                    quiescentMorrowCoordinator.sableCipherNextRoute = quiescentMorrowRoute
                }
            }
        }
    }

    private func quiescentMorrowCloseBPackage() {
        NacreWispBInfoStore.shared.nacreWispClearSession()
        quiescentMorrowCoordinator.sableCipherNextRoute = nil
        quiescentMorrowCoordinator.sableCipherStatus = .sableCipherA
    }
}

private struct QuiescentMorrowLoadingView: View {
    var body: some View {
        GeometryReader { quiescentMorrowProxy in
            Image("HIVV_launch_page")
                .resizable()
                .scaledToFill()
                .frame(width: quiescentMorrowProxy.size.width, height: quiescentMorrowProxy.size.height)
                .clipped()
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image("HIVV_app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .padding(.bottom, 12)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.05)
                    .frame(width: 24, height: 24)
                Text("Loading...")
                    .font(VoiceWhisperFontKit.regular(12))
                    .foregroundColor(.white.opacity(0.72))
            }
            .frame(width: 150, height: 190)
            .position(
                x: quiescentMorrowProxy.size.width / 2,
                y: quiescentMorrowProxy.size.height * 0.58
            )
        }
        .ignoresSafeArea()
    }
}

private struct QuiescentMorrowQuickLoginView: View {
    let quiescentMorrowIsLoading: Bool
    let quiescentMorrowLoginAction: () -> Void
    let quiescentMorrowCloseAction: () -> Void

    var body: some View {
        ZStack {
            Image("HIVV_main_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.16))

            VStack(spacing: 20) {
                Spacer()
                Image("HIVV_app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 106, height: 106)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                Text("HiVivi")
                    .font(VoiceWhisperFontKit.bold(25))
                    .foregroundColor(.white)
                Button(action: quiescentMorrowLoginAction) {
                    Group {
                        if quiescentMorrowIsLoading {
                            ProgressView().tint(.black)
                        } else {
                            Text("Quick Login")
                                .font(VoiceWhisperFontKit.bold(16))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.54, green: 1, blue: 0.43))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(quiescentMorrowIsLoading)
                .padding(.horizontal, 54)
                Button("Return to HiVivi", action: quiescentMorrowCloseAction)
                    .font(VoiceWhisperFontKit.regular(14))
                    .foregroundColor(.white.opacity(0.78))
                    .buttonStyle(.plain)
                Spacer()
            }
            .padding(.vertical, 70)
        }
    }
}
