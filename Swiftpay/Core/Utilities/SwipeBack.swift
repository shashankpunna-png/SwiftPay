import SwiftUI
import UIKit

extension View {
    func allowsSwipeBack(_ isEnabled: Bool = true) -> some View {
        background {
            SwipeBackEnabler(isEnabled: isEnabled)
        }
    }
}

private struct SwipeBackEnabler: UIViewControllerRepresentable {
    var isEnabled: Bool

    func makeUIViewController(context: Context) -> Controller {
        Controller(isEnabled: isEnabled)
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.isEnabled = isEnabled
        uiViewController.apply()
    }

    final class Controller: UIViewController {
        var isEnabled: Bool

        init(isEnabled: Bool) {
            self.isEnabled = isEnabled
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            nil
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            apply()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            apply()
        }

        func apply() {
            guard let navigationController else { return }
            SwipeBack.install(on: navigationController, isEnabled: isEnabled)
        }
    }
}

private enum SwipeBack {
    private static var delegateKey: UInt8 = 0

    static func install(on navigationController: UINavigationController, isEnabled: Bool) {
        let delegate = storedDelegate(for: navigationController)
        guard let gesture = navigationController.interactivePopGestureRecognizer else { return }
        gesture.isEnabled = isEnabled
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
