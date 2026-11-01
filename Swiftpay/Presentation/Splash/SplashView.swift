import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()

            Image("LaunchLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityLabel("SwiftPay")
        }
    }
}

struct SplashView: View {
    @State private var showMain = false

    var body: some View {
        Group {
            if showMain {
                MainTabView()
            } else {
                SplashScreen()
            }
        }
        .onAppear {
            showMain = true
        }
    }
}

#Preview {
    SplashScreen()
}
