import Foundation

enum RepositoryError: Error {
    case fileNotFound(String)
    case decodingError(String)
    case invalidCountry(String)
}

final class LocalKYCConfigurationRepository: KYCConfigurationRepository {
    private let bundle: Bundle
    private let yamlParser: YamlParsing

    init(bundle: Bundle = .main, yamlParser: YamlParsing = YamlParser()) {
        self.bundle = bundle
        self.yamlParser = yamlParser
    }

    func loadConfiguration(for country: String) async throws -> KYCConfiguration {
        let fileName = country.lowercased()

        guard let url = bundle.url(forResource: fileName, withExtension: "yaml") else {
            throw RepositoryError.fileNotFound("Configuration file not found for country: \(country)")
        }

        do {
            let yamlString = try yamlParser.loadYaml(from: url)
            let configuration = try yamlParser.decode(KYCConfiguration.self, from: yamlString)
            return configuration
        } catch {
            throw RepositoryError.decodingError("Failed to decode configuration for country \(country): \(error)")
        }
    }

    func getAllAvailableCountries() async throws -> [String] {
        // For now, return hardcoded list since we know which configurations exist
        // In a real app, this could be dynamic based on bundle resources
        ["DE", "NL", "US"]
    }
}
