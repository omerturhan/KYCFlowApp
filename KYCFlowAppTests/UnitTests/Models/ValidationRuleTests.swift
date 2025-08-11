import XCTest
@testable import KYCFlowApp

final class ValidationRuleTests: BaseTestCase {
    func testValidationRuleInitialization() {
        let rule = ValidationRule(type: .required)
        XCTAssertEqual(rule.type, .required)
        XCTAssertNil(rule.value)
        XCTAssertNil(rule.message)
    }

    func testValidationRuleWithValue() {
        let rule = ValidationRule(type: .regex, value: "^[0-9]+$", message: "Must be numeric")
        XCTAssertEqual(rule.type, .regex)
        XCTAssertEqual(rule.value, "^[0-9]+$")
        XCTAssertEqual(rule.message, "Must be numeric")
    }

    func testValidationTypeCodable() throws {
        let types: [ValidationType] = [.required, .regex, .minLength, .maxLength, .minValue, .maxValue]

        for type in types {
            let encoded = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(ValidationType.self, from: encoded)
            XCTAssertEqual(type, decoded)
        }
    }

    func testValidationRuleCodable() throws {
        let rule = ValidationRule(type: .minLength, value: "5", message: "Too short")

        let encoded = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(ValidationRule.self, from: encoded)

        XCTAssertEqual(rule, decoded)
    }

    func testValidationRuleEquality() {
        let rule1 = ValidationRule(type: .required)
        let rule2 = ValidationRule(type: .required)
        let rule3 = ValidationRule(type: .regex, value: ".*")

        XCTAssertEqual(rule1, rule2)
        XCTAssertNotEqual(rule1, rule3)
    }

    func testValidationResultValid() {
        let result = ValidationResult.valid
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.errorMessage)
    }

    func testValidationResultInvalid() {
        let result = ValidationResult.invalid("Field is required")
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorMessage, "Field is required")
    }
}
