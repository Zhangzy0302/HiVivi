import SwiftUI

struct VoiceNativeSwipeBackEnabler: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let voiceNavigationController = uiViewController.voiceNearestNavigationController else {
                return
            }

            voiceNavigationController.interactivePopGestureRecognizer?.isEnabled = true
            context.coordinator.voiceNavigationController = voiceNavigationController
            voiceNavigationController.interactivePopGestureRecognizer?.delegate = context.coordinator
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var voiceNavigationController: UINavigationController?

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let voiceNavigationController = voiceNavigationController ?? gestureRecognizer.view?.voiceNearestNavigationController else {
                return false
            }

            return voiceNavigationController.viewControllers.count > 1
        }
    }
}

private struct VoiceNativeSwipeBackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(VoiceNativeSwipeBackEnabler().frame(width: 0, height: 0))
    }
}

extension View {
    func voiceNativeSwipeBackEnabled() -> some View {
        modifier(VoiceNativeSwipeBackModifier())
    }

    func voiceEdgeSwipeBack(onBack: @escaping () -> Void) -> some View {
        modifier(VoiceEdgeSwipeBackModifier(onBack: onBack))
    }
}

private struct VoiceEdgeSwipeBackModifier: ViewModifier {
    let onBack: () -> Void

    @State private var voiceEdgeDidTriggerBack = false

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { voiceDragValue in
                        guard !voiceEdgeDidTriggerBack else {
                            return
                        }

                        let voiceStartsAtLeadingEdge = voiceDragValue.startLocation.x <= 28
                        let voiceMovesRight = voiceDragValue.translation.width > 72
                        let voiceMostlyHorizontal = abs(voiceDragValue.translation.height) < 42
                        guard voiceStartsAtLeadingEdge, voiceMovesRight, voiceMostlyHorizontal else {
                            return
                        }

                        voiceEdgeDidTriggerBack = true
                        onBack()
                    }
                    .onEnded { _ in
                        voiceEdgeDidTriggerBack = false
                    }
            )
    }
}

private extension UIViewController {
    var voiceNearestNavigationController: UINavigationController? {
        if let navigationController {
            return navigationController
        }

        var voiceParent = parent
        while let voiceCurrentParent = voiceParent {
            if let voiceNavigationController = voiceCurrentParent as? UINavigationController {
                return voiceNavigationController
            }
            voiceParent = voiceCurrentParent.parent
        }

        return view.voiceNearestNavigationController
    }
}

private extension UIView {
    var voiceNearestNavigationController: UINavigationController? {
        for voiceView in sequence(first: self, next: { $0.superview }) {
            if let voiceNavigationController = voiceView.next as? UINavigationController {
                return voiceNavigationController
            }

            if let voiceViewController = voiceView.next as? UIViewController,
               let voiceNavigationController = voiceViewController.navigationController {
                return voiceNavigationController
            }
        }

        return nil
    }
}
