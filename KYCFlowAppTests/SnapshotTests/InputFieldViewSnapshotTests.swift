import XCTest
import SnapshotTesting
import SwiftUI
@testable import KYCFlowApp

final class InputFieldViewSnapshotTests: BaseSnapshotTest {
    // MARK: - Text Field Tests
    
    func testTextFieldNormal() {
        let field = FormField(
            id: "first_name",
            label: "First Name",
            type: .text,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("John Doe"),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testTextFieldEmpty() {
        let field = FormField(
            id: "first_name",
            label: "First Name",
            type: .text,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant(""),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testTextFieldWithError() {
        let field = FormField(
            id: "email",
            label: "Email Address",
            type: .text,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("invalid-email"),
            error: "Please enter a valid email address",
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldWithErrorSize)
    }
    
    func testTextFieldReadOnly() {
        let field = FormField(
            id: "last_name",
            label: "Last Name",
            type: .text,
            required: true,
            validation: nil,
            dataSource: "user_profile",
            readOnly: true
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("van der Berg"),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    // MARK: - Number Field Tests
    
    func testNumberFieldNormal() {
        let field = FormField(
            id: "age",
            label: "Age",
            type: .number,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("25"),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testNumberFieldWithError() {
        let field = FormField(
            id: "income",
            label: "Annual Income",
            type: .number,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("1000"),
            error: "Income must be at least $10,000",
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldWithErrorSize)
    }
    
    func testNumberFieldReadOnly() {
        let field = FormField(
            id: "employee_id",
            label: "Employee ID",
            type: .number,
            required: true,
            validation: nil,
            dataSource: "api",
            readOnly: true
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("123456"),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    // MARK: - Date Field Tests
    
    func testDateFieldWithDate() {
        let field = FormField(
            id: "birth_date",
            label: "Birth Date",
            type: .date,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("1990-01-15"),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testDateFieldEmpty() {
        let field = FormField(
            id: "birth_date",
            label: "Birth Date",
            type: .date,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant(""),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testDateFieldReadOnly() {
        let field = FormField(
            id: "birth_date",
            label: "Birth Date",
            type: .date,
            required: true,
            validation: nil,
            dataSource: "user_profile",
            readOnly: true
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("1985-03-15"),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    // MARK: - Common State Tests
    
    func testFieldLoading() {
        let field = FormField(
            id: "username",
            label: "Username",
            type: .text,
            required: false,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant(""),
            error: nil,
            isLoading: true
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testOptionalField() {
        let field = FormField(
            id: "middle_name",
            label: "Middle Name",
            type: .text,
            required: false,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant(""),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testLongLabel() {
        let field = FormField(
            id: "address",
            label: "Residential Address (Including Street, City, State)",
            type: .text,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = InputFieldView(
            field: field,
            value: .constant("123 Main St, New York, NY"),
            error: nil,
            isLoading: false
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
}
