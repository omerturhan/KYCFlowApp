import Foundation

protocol KYCConfigurationRepository {
    func loadConfiguration(for country: String) async throws -> KYCConfiguration
    func getAllAvailableCountries() async throws -> [String]
}
