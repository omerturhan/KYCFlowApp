import XCTest
@testable import KYCFlowApp

final class LocalKYCConfigurationRepositoryTests: BaseTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var sut: LocalKYCConfigurationRepository!
    
    override func setUp() {
        super.setUp()
        sut = LocalKYCConfigurationRepository(bundle: .main)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testRepositoryExists() {
        XCTAssertNotNil(sut)
    }
    
    func testGetAllAvailableCountries() async throws {
        let countries = try await sut.getAllAvailableCountries()
        
        // Should return hardcoded list
        XCTAssertEqual(countries.count, 3)
        XCTAssertTrue(countries.contains("NL"))
        XCTAssertTrue(countries.contains("US"))
        XCTAssertTrue(countries.contains("DE"))
    }
    
    func testLoadConfigurationForInvalidCountry() async {
        do {
            _ = try await sut.loadConfiguration(for: "INVALID")
            XCTFail("Should have thrown an error for invalid country")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }
}
