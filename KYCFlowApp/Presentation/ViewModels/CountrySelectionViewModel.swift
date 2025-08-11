import Foundation
import SwiftUI

@MainActor
final class CountrySelectionViewModel: ObservableObject {
    @Published var availableCountries: [String] = []
    @Published var selectedCountry: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let configurationRepository: KYCConfigurationRepository
    
    init(configurationRepository: KYCConfigurationRepository = LocalKYCConfigurationRepository()) {
        self.configurationRepository = configurationRepository
    }
    
    func loadCountries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let countries = try await configurationRepository.getAllAvailableCountries()
            self.availableCountries = countries.sorted()
        } catch {
            self.errorMessage = "Failed to load countries: \(error.localizedDescription)"
            // Fallback to hardcoded list if loading fails
            self.availableCountries = ["DE", "NL", "US"]
        }
        
        isLoading = false
    }
    
    func selectCountry(_ country: String) {
        guard availableCountries.contains(country) else {
            errorMessage = "Invalid country selection"
            return
        }
        selectedCountry = country
    }
    
    func clearSelection() {
        selectedCountry = nil
        errorMessage = nil
    }
    
    var hasSelection: Bool {
        selectedCountry != nil
    }
    
    var canProceed: Bool {
        hasSelection && !isLoading
    }
}