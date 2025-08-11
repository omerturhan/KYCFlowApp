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
            dataSource: nil,
            readOnly: false
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
        
        assertSnapshot(of: view, size: TestDevice.formFieldSize)
    }
    
    func testFormFieldViewTextWithError() {
        let field = FormField(
            id: "email",
            label: "Email",
            type: .text,
            required: true,
            validation: nil,
            dataSource: nil,
            readOnly: false
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
        
        assertSnapshot(of: view, size: TestDevice.formFieldWithErrorSize)
    }
    
    // MARK: - Number Field Tests
    
    func testFormFieldViewNumber() {
        let field = FormField(
            id: "age",
            label: "Age",
            type: .number,
            required: true,
            validation: nil,
            dataSource: nil,
            readOnly: false
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
        
        assertSnapshot(of: view, size: TestDevice.formFieldSize)
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
        
        assertSnapshot(of: view, size: TestDevice.formFieldSize)
    }
    
    // MARK: - Date Field Tests
    
    func testFormFieldViewDate() {
        let field = FormField(
            id: "birth_date",
            label: "Birth Date",
            type: .date,
            required: true,
            validation: nil,
            dataSource: nil,
            readOnly: false
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
        
        assertSnapshot(of: view, size: TestDevice.formFieldSize)
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
        
        assertSnapshot(of: view, size: TestDevice.formFieldSize)
    }
    
    // MARK: - Mixed States Tests
    
    func testFormFieldViewOptionalField() {
        let field = FormField(
            id: "middle_name",
            label: "Middle Name",
            type: .text,
            required: false,
            validation: nil,
            dataSource: nil,
            readOnly: false
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
        
        assertSnapshot(of: view, size: TestDevice.formFieldSize)
    }
}