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

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.userDetails, container.userDetails)
                .environmentObject(container.transactions)
                .task {
                    await container.userDetails.load()
                }
        }
    }
}
