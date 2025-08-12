import XCTest
@testable import KYCFlowApp

final class CountrySelectionViewModelTests: BaseTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var sut: CountrySelectionViewModel!
    // swiftlint:disable:next implicitly_unwrapped_optional
    var mockRepository: MockKYCConfigurationRepository!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockRepository = MockKYCConfigurationRepository()
        sut = CountrySelectionViewModel(configurationRepository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    @MainActor
    func testInitialState() {
        XCTAssertTrue(sut.availableCountries.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testLoadCountriesSuccess() async {
        // Given
        mockRepository.availableCountries = ["US", "NL", "DE"]
        
        // When
        await sut.loadCountries()
        
        // Then
        XCTAssertEqual(sut.availableCountries, ["DE", "NL", "US"]) // Should be sorted
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testLoadCountriesFailure() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await sut.loadCountries()
        
        // Then
        XCTAssertEqual(sut.availableCountries, ["DE", "NL", "US"]) // Fallback list
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }
}

// Mock repository for testing
final class MockKYCConfigurationRepository: KYCConfigurationRepository {
    var availableCountries = ["NL", "US", "DE"]
    var shouldThrowError = false
    var configurations: [String: KYCConfiguration] = [:]
    
    func getAllAvailableCountries() async throws -> [String] {
        if shouldThrowError {
            throw RepositoryError.fileNotFound("Test error")
        }
        return availableCountries
    }
    
    func loadConfiguration(for country: String) async throws -> KYCConfiguration {
        if shouldThrowError {
            throw RepositoryError.fileNotFound("Test error")
        }
        
        if let config = configurations[country] {
            return config
        }
        
        // Return a default configuration for testing
        return KYCConfiguration(country: country, dataSources: [], fields: [])
    }
}
