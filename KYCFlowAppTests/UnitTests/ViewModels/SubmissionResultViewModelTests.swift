import XCTest
@testable import KYCFlowApp

@MainActor
final class SubmissionResultViewModelTests: BaseTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var sut: SubmissionResultViewModel!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given
        let data = ["key": "value"]
        
        // When
        sut = SubmissionResultViewModel(submittedData: data)
        
        // Then
        XCTAssertFalse(sut.isCopied)
        XCTAssertNil(sut.shareError)
        XCTAssertTrue(sut.hasData)
        XCTAssertEqual(sut.dataCount, 1)
    }
    
    func testInitializationWithEmptyData() {
        // Given
        let data: [String: Any] = [:]
        
        // When
        sut = SubmissionResultViewModel(submittedData: data)
        
        // Then
        XCTAssertFalse(sut.hasData)
        XCTAssertEqual(sut.dataCount, 0)
    }
    
    // MARK: - JSON Formatting Tests
    
    func testFormattedJSONWithValidData() {
        // Given
        let data: [String: Any] = [
            "name": "John Doe",
            "age": 30,
            "email": "john@example.com"
        ]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let json = sut.formattedJSON
        
        // Then
        XCTAssertTrue(json.contains("\"name\" : \"John Doe\""))
        XCTAssertTrue(json.contains("\"age\" : 30"))
        XCTAssertTrue(json.contains("\"email\" : \"john@example.com\""))
    }
    
    func testFormattedJSONWithComplexData() {
        // Given
        let data: [String: Any] = [
            "user": [
                "firstName": "Jane",
                "lastName": "Smith"
            ],
            "settings": [
                "notifications": true,
                "theme": "dark"
            ]
        ]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let json = sut.formattedJSON
        
        // Then
        XCTAssertFalse(json.isEmpty)
        XCTAssertTrue(json.contains("firstName"))
        XCTAssertTrue(json.contains("Jane"))
    }
    
    // MARK: - Copy to Clipboard Tests
    
    func testCopyToClipboardResetsAfterDelay() async throws {
        // Given
        let data = ["test": "value"]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        sut.copyToClipboard()
        XCTAssertTrue(sut.isCopied)
        
        // Wait for reset
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
        
        // Then
        XCTAssertFalse(sut.isCopied)
    }
    
    func testMultipleCopyOperationsCancelsPrevious() async throws {
        // Given
        let data = ["test": "value"]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When - First copy
        sut.copyToClipboard()
        XCTAssertTrue(sut.isCopied)
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Second copy (should cancel first reset)
        sut.copyToClipboard()
        XCTAssertTrue(sut.isCopied)
        
        // Wait for what would have been the first reset
        try await Task.sleep(nanoseconds: 1_600_000_000) // 1.6 seconds
        
        // Should still be copied (first reset was cancelled)
        XCTAssertTrue(sut.isCopied)
        
        // Wait for second reset
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 more second
        
        // Then
        XCTAssertFalse(sut.isCopied)
    }
    
    // MARK: - Get Submitted Value Tests
    
    func testGetSubmittedValueWithString() {
        // Given
        let data = ["name": "John"]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let value = sut.getSubmittedValue(for: "name")
        
        // Then
        XCTAssertEqual(value, "John")
    }
    
    func testGetSubmittedValueWithNumber() {
        // Given
        let data: [String: Any] = ["age": NSNumber(value: 25)]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let value = sut.getSubmittedValue(for: "age")
        
        // Then
        XCTAssertEqual(value, "25")
    }
    
    func testGetSubmittedValueWithDate() {
        // Given
        let date = Date(timeIntervalSince1970: 0) // Jan 1, 1970
        let data: [String: Any] = ["birthDate": date]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let value = sut.getSubmittedValue(for: "birthDate")
        
        // Then
        XCTAssertNotNil(value)
        // Date formatting depends on locale, so just check it's not empty
        XCTAssertFalse(value?.isEmpty ?? true)
    }
    
    func testGetSubmittedValueWithMissingKey() {
        // Given
        let data = ["name": "John"]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let value = sut.getSubmittedValue(for: "missingKey")
        
        // Then
        XCTAssertNil(value)
    }
    
    func testGetSubmittedValueWithCustomObject() {
        // Given
        let data: [String: Any] = ["custom": ["nested": "value"]]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let value = sut.getSubmittedValue(for: "custom")
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertTrue(value?.contains("nested") ?? false)
    }
    
    // MARK: - Sorted Keys Tests
    
    func testSortedDataKeys() {
        // Given
        let data: [String: Any] = [
            "zebra": "value",
            "apple": "value",
            "banana": "value"
        ]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        let keys = sut.sortedDataKeys
        
        // Then
        XCTAssertEqual(keys, ["apple", "banana", "zebra"])
    }
    
    func testSortedDataKeysWithEmptyData() {
        // Given
        sut = SubmissionResultViewModel(submittedData: [:])
        
        // When
        let keys = sut.sortedDataKeys
        
        // Then
        XCTAssertTrue(keys.isEmpty)
    }
    
    // MARK: - Share Data Tests
    
    func testShareDataWithNoWindow() {
        // Given
        let data = ["test": "value"]
        sut = SubmissionResultViewModel(submittedData: data)
        
        // When
        // In test environment, there might not be a window scene
        sut.shareData()
        
        // Then
        // Should handle gracefully (set error or do nothing)
        // This test mainly ensures no crash occurs
        XCTAssertTrue(true) // Test passes if no crash
    }
}
