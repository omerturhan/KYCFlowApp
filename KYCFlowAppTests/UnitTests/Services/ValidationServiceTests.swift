import XCTest
@testable import KYCFlowApp

final class ValidationServiceTests: BaseTestCase {
    
    var sut: ValidationService!
    
    override func setUp() {
        super.setUp()
        sut = ValidationService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Required Validation Tests
    
    func testValidateRequiredWithValue() {
        let rule = ValidationRule(type: .required)
        
        let result = sut.validate(value: "test", rule: rule)
        
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.errorMessage)
    }
    
    func testValidateRequiredWithEmptyString() {
        let rule = ValidationRule(type: .required, message: "Field is required")
        
        let result = sut.validate(value: "", rule: rule)
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Field is required")
    }
    
    func testValidateRequiredWithNil() {
        let rule = ValidationRule(type: .required)
        
        let result = sut.validate(value: nil, rule: rule)
        
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.errorMessage)
    }
    
    // MARK: - Regex Validation Tests
    
    func testValidateRegexWithValidPattern() {
        let rule = ValidationRule(type: .regex, value: "^\\d{9}$", message: "Must be 9 digits")
        
        let result = sut.validate(value: "123456789", rule: rule)
        
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateRegexWithInvalidPattern() {
        let rule = ValidationRule(type: .regex, value: "^\\d{9}$", message: "Must be 9 digits")
        
        let result = sut.validate(value: "12345", rule: rule)
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Must be 9 digits")
    }
    
    func testValidateRegexWithEmailPattern() {
        let rule = ValidationRule(type: .regex, value: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", message: "Invalid email")
        
        XCTAssertTrue(sut.validate(value: "TEST@EXAMPLE.COM", rule: rule).isValid)
        XCTAssertFalse(sut.validate(value: "invalid.email", rule: rule).isValid)
    }
    
    // MARK: - Min Length Validation Tests
    
    func testValidateMinLengthValid() {
        let rule = ValidationRule(type: .minLength, value: "5")
        
        let result = sut.validate(value: "hello world", rule: rule)
        
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateMinLengthInvalid() {
        let rule = ValidationRule(type: .minLength, value: "5", message: "Too short")
        
        let result = sut.validate(value: "hi", rule: rule)
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Too short")
    }
    
    // MARK: - Max Length Validation Tests
    
    func testValidateMaxLengthValid() {
        let rule = ValidationRule(type: .maxLength, value: "10")
        
        let result = sut.validate(value: "hello", rule: rule)
        
        XCTAssertTrue(result.isValid)
    }
    
    func testValidateMaxLengthInvalid() {
        let rule = ValidationRule(type: .maxLength, value: "5", message: "Too long")
        
        let result = sut.validate(value: "hello world", rule: rule)
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Too long")
    }
    
    // MARK: - Min Value Validation Tests
    
    func testValidateMinValueWithInteger() {
        let rule = ValidationRule(type: .minValue, value: "18")
        
        XCTAssertTrue(sut.validate(value: 18, rule: rule).isValid)
        XCTAssertTrue(sut.validate(value: 25, rule: rule).isValid)
        XCTAssertFalse(sut.validate(value: 17, rule: rule).isValid)
    }
    
    func testValidateMinValueWithDouble() {
        let rule = ValidationRule(type: .minValue, value: "10.5")
        
        XCTAssertTrue(sut.validate(value: 10.5, rule: rule).isValid)
        XCTAssertTrue(sut.validate(value: 15.0, rule: rule).isValid)
        XCTAssertFalse(sut.validate(value: 10.0, rule: rule).isValid)
    }
    
    // MARK: - Max Value Validation Tests
    
    func testValidateMaxValueWithInteger() {
        let rule = ValidationRule(type: .maxValue, value: "100")
        
        XCTAssertTrue(sut.validate(value: 100, rule: rule).isValid)
        XCTAssertTrue(sut.validate(value: 50, rule: rule).isValid)
        XCTAssertFalse(sut.validate(value: 101, rule: rule).isValid)
    }
    
    // MARK: - Field Validation Tests
    
    func testValidateFieldWithRequiredField() {
        let field = FormField(
            id: "test",
            label: "Test",
            type: .text,
            required: true
        )
        
        XCTAssertFalse(sut.validateField(field, value: "").isValid)
        XCTAssertTrue(sut.validateField(field, value: "value").isValid)
    }
    
    func testValidateFieldWithReadOnlyField() {
        let field = FormField(
            id: "test",
            label: "Test",
            type: .text,
            required: true,
            validation: [ValidationRule(type: .minLength, value: "10")],
            readOnly: true
        )
        
        // Read-only fields should still be validated for data integrity
        let emptyResult = sut.validateField(field, value: "")
        XCTAssertFalse(emptyResult.isValid) // Required validation should fail
        
        let shortResult = sut.validateField(field, value: "short")
        XCTAssertFalse(shortResult.isValid) // Min length validation should fail
        
        let validResult = sut.validateField(field, value: "valid value here")
        XCTAssertTrue(validResult.isValid) // Should pass all validations
    }
    
    func testValidateFieldWithMultipleRules() {
        let field = FormField(
            id: "password",
            label: "Password",
            type: .text,
            required: true,
            validation: [
                ValidationRule(type: .minLength, value: "8", message: "Too short"),
                ValidationRule(type: .maxLength, value: "20", message: "Too long")
            ]
        )
        
        XCTAssertFalse(sut.validateField(field, value: "").isValid) // Required fails
        XCTAssertFalse(sut.validateField(field, value: "short").isValid) // Min length fails
        XCTAssertFalse(sut.validateField(field, value: "this is a very long password that exceeds limit").isValid) // Max length fails
        XCTAssertTrue(sut.validateField(field, value: "validpass123").isValid) // All pass
    }
    
    // MARK: - Validate All Rules Tests
    
    func testValidateAllRulesWithMultipleRules() {
        let rules = [
            ValidationRule(type: .required),
            ValidationRule(type: .minLength, value: "5"),
            ValidationRule(type: .regex, value: "^[a-zA-Z]+$", message: "Letters only")
        ]
        
        XCTAssertFalse(sut.validateAllRules(value: "", rules: rules).isValid) // Required fails
        XCTAssertFalse(sut.validateAllRules(value: "abc", rules: rules).isValid) // Min length fails
        XCTAssertFalse(sut.validateAllRules(value: "abc123", rules: rules).isValid) // Regex fails
        XCTAssertTrue(sut.validateAllRules(value: "hello", rules: rules).isValid) // All pass
    }
    
    func testValidateAllRulesStopsOnFirstFailure() {
        let rules = [
            ValidationRule(type: .required, message: "Required"),
            ValidationRule(type: .minLength, value: "5", message: "Too short")
        ]
        
        let result = sut.validateAllRules(value: "", rules: rules)
        
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Required") // Should return first error
    }
}