//
//  KYCFlowAppApp.swift
//  KYCFlowApp
//
//  Created by Ömer Turhan on 10.08.2025.
//

import SwiftUI

@main
struct KYCFlowAppApp: App {
    let diContainer: DIContainer
    
    init() {
        // Initialize DI Container
        diContainer = DIContainer.shared
        
        // Configure for appropriate environment
        #if DEBUG
        diContainer.configure(for: .development)
        #else
        diContainer.configure(for: .production)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .injectDIContainer(diContainer)
        }
    }
}
