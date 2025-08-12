//
//  ContentView.swift
//  KYCFlowApp
//
//  Created by Ömer Turhan on 10.08.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.diContainer) private var diContainer
    @State private var navigationPath = NavigationPath()
    @State private var selectedCountry: String?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CountrySelectionView(
                viewModel: diContainer.makeCountrySelectionViewModel()
            ) { country in
                selectedCountry = country
                navigationPath.append(NavigationDestination.form(country: country))
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .form(let country):
                    DynamicFormView(
                        viewModel: diContainer.makeKYCFormViewModel(),
                        country: country
                    ) { data in
                        navigationPath.append(NavigationDestination.result(data: data))
                    }
                    
                case .result(let data):
                    SubmissionResultView(submittedData: data) {
                        navigationPath = NavigationPath()
                        selectedCountry = nil
                    }
                }
            }
        }
    }
}

// MARK: - Navigation Destination

enum NavigationDestination: Hashable {
    case form(country: String)
    case result(data: [String: Any])
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .form(let country):
            hasher.combine("form")
            hasher.combine(country)
        case .result(let data):
            hasher.combine("result")
            // Create a unique identifier for this specific result
            // Using object identity or a UUID would be better but we need deterministic hashing
            // Hash based on string representation of the data
            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .sortedKeys),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                hasher.combine(jsonString)
            } else {
                // Fallback: combine keys and values
                for key in data.keys.sorted() {
                    hasher.combine(key)
                    hasher.combine("\(data[key] ?? "")")
                }
            }
        }
    }
    
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.form(let c1), .form(let c2)):
            return c1 == c2
        case (.result(let d1), .result(let d2)):
            return NSDictionary(dictionary: d1).isEqual(to: d2)
        default:
            return false
        }
    }
}

// MARK: - Preview

#Preview("Normal Flow") {
    ContentView()
        .injectDIContainer()
}

#Preview("With Mock Data") {
    let container = DIContainer()
    container.configure(for: .development)
    
    return ContentView()
        .injectDIContainer(container)
}
