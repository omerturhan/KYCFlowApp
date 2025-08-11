import XCTest
@testable import KYCFlowApp

final class FormFieldTests: XCTestCase {
    func testFormFieldInitialization() {
        let field = FormField(
            id: "first_name",
            label: "First Name",
            type: .text
        )
        
        XCTAssertEqual(field.id, "first_name")
        XCTAssertEqual(field.label, "First Name")
        XCTAssertEqual(field.type, .text)
        XCTAssertFalse(field.required)
        XCTAssertTrue(field.validation.isEmpty)
        XCTAssertNil(field.dataSource)
        XCTAssertFalse(field.readOnly)
    }
    
    func testFormFieldWithAllProperties() {
        let validation = [
            ValidationRule(type: .required),
            ValidationRule(type: .minLength, value: "2", message: "Too short")
        ]
        
        let field = FormField(
            id: "birth_date",
            label: "Birth Date",
            type: .date,
            required: true,
            validation: validation,
            dataSource: "user_profile",
            readOnly: true
        )
        
        XCTAssertEqual(field.id, "birth_date")
        XCTAssertEqual(field.label, "Birth Date")
        XCTAssertEqual(field.type, .date)
        XCTAssertTrue(field.required)
        XCTAssertEqual(field.validation.count, 2)
        XCTAssertEqual(field.dataSource, "user_profile")
        XCTAssertTrue(field.readOnly)
    }
    
    func testFieldTypeCodable() throws {
        let types: [FieldType] = [.text, .number, .date]
        
        for type in types {
            let encoded = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(FieldType.self, from: encoded)
            XCTAssertEqual(type, decoded)
        }
    }
    
    func testFormFieldCodable() throws {
        let field = FormField(
            id: "age",
            label: "Age",
            type: .number,
            required: true,
            validation: [
                ValidationRule(type: .minValue, value: "18", message: "Must be 18 or older")
            ]
        )
        
        let encoded = try JSONEncoder().encode(field)
        let decoded = try JSONDecoder().decode(FormField.self, from: encoded)
        
        XCTAssertEqual(field, decoded)
    }
    
    func testFormFieldEquality() {
        let field1 = FormField(id: "field1", label: "Field 1", type: .text)
        let field2 = FormField(id: "field1", label: "Field 1", type: .text)
        let field3 = FormField(id: "field2", label: "Field 2", type: .number)
        
        XCTAssertEqual(field1, field2)
        XCTAssertNotEqual(field1, field3)
    }
    
    func testFormFieldWithDataSource() {
        let field = FormField(
            id: "first_name",
            label: "First Name",
            type: .text,
            dataSource: "user_profile",
            readOnly: true
        )
        
        XCTAssertEqual(field.dataSource, "user_profile")
        XCTAssertTrue(field.readOnly)
    }
}
