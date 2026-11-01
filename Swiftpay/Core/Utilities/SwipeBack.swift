import SwiftUI
import UIKit

extension View {
    func allowsSwipeBack() -> some View {
        background {
            SwipeBackEnabler()
        }
    }
}

private struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            enableSwipe()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            enableSwipe()
        }

        private func enableSwipe() {
            guard let navigationController else { return }
            SwipeBack.install(on: navigationController)
        }
    }
}

private enum SwipeBack {
    private static var delegateKey: UInt8 = 0

    static func install(on navigationController: UINavigationController) {
        let delegate = storedDelegate(for: navigationController)
        guard let gesture = navigationController.interactivePopGestureRecognizer else { return }
        gesture.isEnabled = true
        gesture.delegate = delegate
    }

    private static func storedDelegate(for navigationController: UINavigationController) -> Delegate {
        if let delegate = objc_getAssociatedObject(navigationController, &delegateKey) as? Delegate {
            return delegate
        }
        let delegate = Delegate(navigationController: navigationController)
        objc_setAssociatedObject(
            navigationController,
            &delegateKey,
            delegate,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        return delegate
    }

    private final class Delegate: NSObject, UIGestureRecognizerDelegate {
        weak var navigationController: UINavigationController?

        init(navigationController: UINavigationController) {
            self.navigationController = navigationController
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let navigationController else { return false }
            return navigationController.viewControllers.count > 1
        }
    }
}
