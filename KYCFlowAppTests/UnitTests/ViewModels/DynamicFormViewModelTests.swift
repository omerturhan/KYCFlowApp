import XCTest
@testable import KYCFlowApp

@MainActor
// swiftlint:disable file_length type_body_length function_body_length
final class DynamicFormViewModelTests: BaseTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var sut: DynamicFormViewModel!
    // swiftlint:disable:next implicitly_unwrapped_optional
    var mockConfigRepository: MockKYCConfigurationRepository!
    // swiftlint:disable:next implicitly_unwrapped_optional
    var mockUserRepository: TestableMockUserProfileRepository!
    // swiftlint:disable:next implicitly_unwrapped_optional
    var mockValidationService: MockValidationService!
    
    override func setUp() {
        super.setUp()
        mockConfigRepository = MockKYCConfigurationRepository()
        mockUserRepository = TestableMockUserProfileRepository()
        mockValidationService = MockValidationService()
        
        sut = DynamicFormViewModel(
            configurationRepository: mockConfigRepository,
            userProfileRepository: mockUserRepository,
            validationService: mockValidationService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockConfigRepository = nil
        mockUserRepository = nil
        mockValidationService = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(sut.formState.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.configuration)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isSubmitted)
        XCTAssertTrue(sut.submittedData.isEmpty)
        XCTAssertFalse(sut.canSubmit)
        XCTAssertFalse(sut.hasConfiguration)
    }
    
    // MARK: - Form Loading Tests
    
    func testLoadFormSuccess() async {
        // Given
        let config = createTestConfiguration(country: "NL")
        mockConfigRepository.configurations["NL"] = config
        
        // When
        await sut.loadForm(for: "NL")
        
        // Then
        XCTAssertNotNil(sut.configuration)
        XCTAssertEqual(sut.configuration?.country, "NL")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        
        // Verify form state initialized for all fields
        XCTAssertEqual(sut.formState.count, 4)
        XCTAssertNotNil(sut.formState["first_name"])
        XCTAssertNotNil(sut.formState["last_name"])
        XCTAssertNotNil(sut.formState["birth_date"])
        XCTAssertNotNil(sut.formState["bsn"])
    }
    
    func testLoadFormWithDataSourcesNL() async {
        // Given
        let config = createNLConfigurationWithDataSources()
        mockConfigRepository.configurations["NL"] = config
        mockUserRepository.mockData = [
            "first_name": "Jan",
            "last_name": "van der Berg",
            "birth_date": "1985-03-15"
        ]
        
        // When
        await sut.loadForm(for: "NL")
        
        // Then
        XCTAssertEqual(sut.formState["first_name"]?.value as? String, "Jan")
        XCTAssertEqual(sut.formState["last_name"]?.value as? String, "van der Berg")
        XCTAssertEqual(sut.formState["birth_date"]?.value as? String, "1985-03-15")
        XCTAssertTrue(sut.formState["first_name"]?.isReadOnly ?? false)
        XCTAssertTrue(sut.formState["last_name"]?.isReadOnly ?? false)
        XCTAssertTrue(sut.formState["birth_date"]?.isReadOnly ?? false)
        XCTAssertFalse(sut.formState["bsn"]?.isReadOnly ?? true)
    }
    
    func testLoadFormFailure() async {
        // Given
        mockConfigRepository.shouldThrowError = true
        
        // When
        await sut.loadForm(for: "NL")
        
        // Then
        XCTAssertNil(sut.configuration)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("Failed to load form") ?? false)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadFormWithDataSourceFailure() async {
        // Given
        let config = createNLConfigurationWithDataSources()
        mockConfigRepository.configurations["NL"] = config
        mockUserRepository.shouldThrowError = true
        
        // When
        await sut.loadForm(for: "NL")
        
        // Then
        XCTAssertNotNil(sut.configuration)
        // Fields should have errors
        XCTAssertNotNil(sut.formState["first_name"]?.error)
        XCTAssertNotNil(sut.formState["last_name"]?.error)
        XCTAssertNotNil(sut.formState["birth_date"]?.error)
        // BSN should not have error (no data source)
        XCTAssertNil(sut.formState["bsn"]?.error)
    }
    
    // MARK: - Field Update Tests
    
    func testUpdateFieldValue() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        
        // When
        sut.updateFieldValue("first_name", value: "John")
        
        // Then
        XCTAssertEqual(sut.formState["first_name"]?.value as? String, "John")
        XCTAssertNil(sut.formState["first_name"]?.error)
        // Validation should NOT be called during input
        XCTAssertFalse(mockValidationService.validateFieldCalled)
    }
    
    func testUpdateFieldValueClearsExistingError() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        
        // Set an error initially
        sut.formState["first_name"]?.error = "Previous error"
        
        // When
        sut.updateFieldValue("first_name", value: "New Value")
        
        // Then
        XCTAssertEqual(sut.formState["first_name"]?.value as? String, "New Value")
        // Error should be cleared when user types
        XCTAssertNil(sut.formState["first_name"]?.error)
    }
    
    // MARK: - Validation Tests
    
    func testValidateAllFieldsSuccess() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        mockValidationService.validationResult = ValidationResult(isValid: true, errorMessages: [])
        
        // Populate all fields
        sut.formState["first_name"]?.value = "John"
        sut.formState["last_name"]?.value = "Doe"
        sut.formState["birth_date"]?.value = "1990-01-01"
        sut.formState["bsn"]?.value = "123456789"
        
        // When
        let isValid = sut.validateAllFields()
        
        // Then
        XCTAssertTrue(isValid)
        XCTAssertNil(sut.formState["first_name"]?.error)
        XCTAssertNil(sut.formState["last_name"]?.error)
        XCTAssertNil(sut.formState["birth_date"]?.error)
        XCTAssertNil(sut.formState["bsn"]?.error)
    }
    
    func testValidateAllFieldsFailure() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        
        mockValidationService.shouldFailForFields = ["first_name", "bsn"]
        
        // When
        let isValid = sut.validateAllFields()
        
        // Then
        XCTAssertFalse(isValid)
        XCTAssertNotNil(sut.formState["first_name"]?.error)
        XCTAssertNotNil(sut.formState["bsn"]?.error)
    }
    
    // MARK: - Form Submission Tests
    
    func testSubmitFormSuccess() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        mockValidationService.validationResult = ValidationResult(isValid: true, errorMessages: [])
        
        // Populate all fields
        sut.formState["first_name"]?.value = "John"
        sut.formState["last_name"]?.value = "Doe"
        sut.formState["birth_date"]?.value = "1990-01-01"
        sut.formState["bsn"]?.value = "123456789"
        
        // When
        let result = sut.submitForm()
        
        // Then
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result["first_name"] as? String, "John")
        XCTAssertEqual(result["last_name"] as? String, "Doe")
        XCTAssertEqual(result["birth_date"] as? String, "1990-01-01")
        XCTAssertEqual(result["bsn"] as? String, "123456789")
        XCTAssertTrue(sut.isSubmitted)
        XCTAssertEqual(sut.submittedData["first_name"] as? String, "John")
    }
    
    func testSubmitFormWithValidationFailure() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        mockValidationService.validationResult = ValidationResult(
            isValid: false,
            errorMessages: ["Validation failed"]
        )
        
        // When
        let result = sut.submitForm()
        
        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertFalse(sut.isSubmitted)
        XCTAssertEqual(sut.errorMessage, "Please fix all errors before submitting")
        // Validation should be called during submission
        XCTAssertTrue(mockValidationService.validateFieldCalled)
    }
    
    func testValidationOnlyOccursOnSubmission() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        
        // When typing in fields (before submission)
        sut.updateFieldValue("first_name", value: "")
        sut.updateFieldValue("last_name", value: "")
        
        // Then - no validation errors should appear
        XCTAssertNil(sut.formState["first_name"]?.error)
        XCTAssertNil(sut.formState["last_name"]?.error)
        XCTAssertFalse(mockValidationService.validateFieldCalled)
        
        // When submitting with invalid data
        mockValidationService.validationResult = ValidationResult(
            isValid: false,
            errorMessages: ["Field is required"]
        )
        _ = sut.submitForm()
        
        // Then - validation errors should now appear
        XCTAssertNotNil(sut.formState["first_name"]?.error)
        XCTAssertNotNil(sut.formState["last_name"]?.error)
        XCTAssertTrue(mockValidationService.validateFieldCalled)
    }
    
    // MARK: - Reset Form Tests
    
    func testResetForm() async {
        // Given
        let config = createTestConfiguration()
        mockConfigRepository.configurations["US"] = config
        await sut.loadForm(for: "US")
        sut.formState["first_name"]?.value = "John"
        sut.errorMessage = "Some error"
        sut.isSubmitted = true
        sut.submittedData = ["test": "data"]
        
        // When
        sut.resetForm()
        
        // Then
        XCTAssertTrue(sut.formState.isEmpty)
        XCTAssertNil(sut.configuration)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isSubmitted)
        XCTAssertTrue(sut.submittedData.isEmpty)
    }
    
    // MARK: - Test Helpers
    
    private func createTestConfiguration(country: String = "US") -> KYCConfiguration {
        KYCConfiguration(
            country: country,
            dataSources: [],
            fields: [
                FormField(
                    id: "first_name",
                    label: "First Name",
                    type: .text,
                    required: true,
                    validation: nil,
                    dataSource: nil
                ),
                FormField(
                    id: "last_name",
                    label: "Last Name",
                    type: .text,
                    required: true,
                    validation: nil,
                    dataSource: nil
                ),
                FormField(
                    id: "birth_date",
                    label: "Birth Date",
                    type: .date,
                    required: true,
                    validation: nil,
                    dataSource: nil
                ),
                FormField(
                    id: "bsn",
                    label: "BSN",
                    type: .text,
                    required: false,
                    validation: nil,
                    dataSource: nil
                )
            ]
        )
    }
    
    private func createNLConfigurationWithDataSources() -> KYCConfiguration {
        KYCConfiguration(
            country: "NL",
            dataSources: [
                DataSource(
                    id: "user_profile",
                    type: .api,
                    endpoint: "/api/nl-user-profile",
                    fields: ["first_name", "last_name", "birth_date"]
                )
            ],
            fields: [
                FormField(
                    id: "first_name",
                    label: "First Name",
                    type: .text,
                    required: true,
                    validation: nil,
                    dataSource: "user_profile",
                    readOnly: true
                ),
                FormField(
                    id: "last_name",
                    label: "Last Name",
                    type: .text,
                    required: true,
                    validation: nil,
                    dataSource: "user_profile",
                    readOnly: true
                ),
                FormField(
                    id: "birth_date",
                    label: "Birth Date",
                    type: .date,
                    required: true,
                    validation: nil,
                    dataSource: "user_profile",
                    readOnly: true
                ),
                FormField(
                    id: "bsn",
                    label: "BSN",
                    type: .text,
                    required: true,
                    validation: [
                        ValidationRule(
                            type: .regex,
                            value: "^\\d{9}$",
                            message: "BSN must be 9 digits"
                        )
                    ],
                    dataSource: nil
                )
            ]
        )
    }
}

// MARK: - Mock Validation Service

final class MockValidationService: ValidationServiceProtocol {
    var validationResult = ValidationResult(isValid: true, errorMessages: [])
    var validateFieldCalled = false
    var shouldFailForFields: Set<String> = []
    
    func validate(value: Any?, rule: ValidationRule) -> ValidationResult {
        validationResult
    }
    
    func validateField(_ field: FormField, value: Any?) -> ValidationResult {
        validateFieldCalled = true
        
        if shouldFailForFields.contains(field.id) {
            return ValidationResult(
                isValid: false,
                errorMessages: ["Validation failed for \(field.id)"]
            )
        }
        
        return validationResult
    }
    
    func validateAllRules(value: Any?, rules: [ValidationRule]) -> ValidationResult {
        validationResult
    }
}

// MARK: - Test Mock User Profile Repository

final class TestableMockUserProfileRepository: MockUserProfileRepository {
    var mockData: [String: Any] = [:]
    var shouldThrowError = false
    
    override func fetchUserProfile(endpoint: String, fields: [String]) async throws -> [String: Any] {
        if shouldThrowError {
            throw RepositoryError.apiError("Test error")
        }
        
        // Return custom mock data if set, otherwise use parent implementation
        if !mockData.isEmpty {
            // Filter mock data to only include requested fields
            var filteredData: [String: Any] = [:]
            for field in fields {
                if let value = mockData[field] {
                    filteredData[field] = value
                }
            }
            return filteredData
        }
        
        return try await super.fetchUserProfile(endpoint: endpoint, fields: fields)
    }
}
