import XCTest
@testable import KYCFlowApp

final class CountrySelectionViewModelTests: BaseTestCase {
    
    var sut: CountrySelectionViewModel!
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
        XCTAssertNil(sut.selectedCountry)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.hasSelection)
        XCTAssertFalse(sut.canProceed)
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
    
    @MainActor
    func testSelectValidCountry() async {
        // Given
        mockRepository.availableCountries = ["US", "NL", "DE"]
        await sut.loadCountries()
        
        // When
        sut.selectCountry("NL")
        
        // Then
        XCTAssertEqual(sut.selectedCountry, "NL")
        XCTAssertTrue(sut.hasSelection)
        XCTAssertTrue(sut.canProceed)
        XCTAssertNil(sut.errorMessage)
    }
    
    @MainActor
    func testSelectInvalidCountry() async {
        // Given
        mockRepository.availableCountries = ["US", "NL", "DE"]
        await sut.loadCountries()
        
        // When
        sut.selectCountry("FR")
        
        // Then
        XCTAssertNil(sut.selectedCountry)
        XCTAssertFalse(sut.hasSelection)
        XCTAssertFalse(sut.canProceed)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    @MainActor
    func testClearSelection() {
        // Given
        sut.selectedCountry = "NL"
        sut.errorMessage = "Some error"
        
        // When
        sut.clearSelection()
        
        // Then
        XCTAssertNil(sut.selectedCountry)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.hasSelection)
        XCTAssertFalse(sut.canProceed)
    }
    
    @MainActor
    func testCannotProceedWhileLoading() {
        // Given
        sut.selectedCountry = "NL"
        sut.isLoading = true
        
        // Then
        XCTAssertTrue(sut.hasSelection)
        XCTAssertFalse(sut.canProceed) // Cannot proceed while loading
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
