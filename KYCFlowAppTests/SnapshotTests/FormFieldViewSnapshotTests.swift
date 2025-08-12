import XCTest
import SnapshotTesting
import SwiftUI
@testable import KYCFlowApp

final class FormFieldViewSnapshotTests: BaseSnapshotTest {
    // MARK: - Text Field Tests
    
    func testFormFieldViewText() {
        let field = FormField(
            id: "first_name",
            label: "First Name",
            type: .text,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "John Doe",
                error: nil,
                isLoading: false,
                isReadOnly: false
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testFormFieldViewTextWithError() {
        let field = FormField(
            id: "email",
            label: "Email",
            type: .text,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "invalid",
                error: "Please enter a valid email",
                isLoading: false,
                isReadOnly: false
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldWithErrorSize)
    }
    
    // MARK: - Number Field Tests
    
    func testFormFieldViewNumber() {
        let field = FormField(
            id: "age",
            label: "Age",
            type: .number,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "25",
                error: nil,
                isLoading: false,
                isReadOnly: false
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testFormFieldViewNumberReadOnly() {
        let field = FormField(
            id: "employee_id",
            label: "Employee ID",
            type: .number,
            required: true,
            validation: nil,
            dataSource: "api",
            readOnly: true
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "123456",
                error: nil,
                isLoading: false,
                isReadOnly: true
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    // MARK: - Date Field Tests
    
    func testFormFieldViewDate() {
        let field = FormField(
            id: "birth_date",
            label: "Birth Date",
            type: .date,
            required: true,
            validation: nil,
            dataSource: nil
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "1990-01-15",
                error: nil,
                isLoading: false,
                isReadOnly: false
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    func testFormFieldViewDateLoading() {
        let field = FormField(
            id: "birth_date",
            label: "Birth Date",
            type: .date,
            required: true,
            validation: nil,
            dataSource: "api",
            readOnly: true
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "",
                error: nil,
                isLoading: true,
                isReadOnly: true
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    // MARK: - Mixed States Tests
    
    func testFormFieldViewOptionalField() {
        let field = FormField(
            id: "middle_name",
            label: "Middle Name",
            type: .text,
            required: false,
            validation: nil,
            dataSource: nil
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "",
                error: nil,
                isLoading: false,
                isReadOnly: false
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldSize)
    }
    
    // MARK: - Multiple Errors Tests
    
    func testFormFieldViewTextWithMultipleErrors() {
        let field = FormField(
            id: "username",
            label: "Username",
            type: .text,
            required: true,
            validation: [
                ValidationRule(type: .minLength, value: "3", message: "Username must be at least 3 characters"),
                ValidationRule(type: .maxLength, value: "20", message: "Username must be at most 20 characters"),
                ValidationRule(
                    type: .regex,
                    value: "^[a-zA-Z0-9]+$",
                    message: "Username must contain only letters and numbers"
                )
            ],
            dataSource: nil
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "ab",
                error: "Username must be at least 3 characters\nUsername must contain only letters and numbers",
                isLoading: false,
                isReadOnly: false
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldWithMultipleErrorsSize)
    }
    
    func testFormFieldViewNumberWithMultipleErrors() {
        let field = FormField(
            id: "age",
            label: "Age",
            type: .number,
            required: true,
            validation: [
                ValidationRule(type: .minValue, value: "18", message: "Must be at least 18 years old"),
                ValidationRule(type: .maxValue, value: "100", message: "Must be at most 100 years old")
            ],
            dataSource: nil
        )
        
        let view = FormFieldView(
            field: field,
            fieldState: .constant(FormFieldState(
                value: "10",
                error: "This field is required\nMust be at least 18 years old",
                isLoading: false,
                isReadOnly: false
            ))
        )
        .padding()
        
        assertSnapshot(of: view, size: Size.formFieldWithMultipleErrorsSize)
    }
}
