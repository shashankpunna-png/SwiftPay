import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
    }
}

#Preview {
    HomeView()
}
