//
//  SwiftpayApp.swift
//  Swiftpay
//
//  Created by Punna Sai Teja Shashank on 29/10/26.
//

import SwiftUI

@main
struct SwiftpayApp: App {
    @State private var container = DependencyContainer()
    @StateObject private var networkMonitor = NetworkMonitor()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            SplashView()
                .dismissKeyboardOnTap()
                .environmentObject(networkMonitor)
                .environment(\.userDetails, container.userDetails)
                .environment(\.createTransactionUseCase, container.createTransaction)
                .environmentObject(container.transactions)
                .task {
                    await container.userDetails.load()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        networkMonitor.refresh()
                    }
                }
        }
    }
}