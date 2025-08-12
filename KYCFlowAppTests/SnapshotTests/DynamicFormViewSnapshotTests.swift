import XCTest
import SnapshotTesting
import SwiftUI
@testable import KYCFlowApp

final class DynamicFormViewSnapshotTests: BaseSnapshotTest {
    @MainActor
    func testDynamicFormViewWithFields() {
        let viewModel = DynamicFormViewModel()
        viewModel.configuration = KYCConfiguration(
            country: "US",
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
                )
            ]
        )
        
        // Initialize form state
        viewModel.formState = [
            "first_name": FormFieldState(value: "John", error: nil, isLoading: false, isReadOnly: false),
            "last_name": FormFieldState(value: "", error: nil, isLoading: false, isReadOnly: false),
            "birth_date": FormFieldState(value: "", error: nil, isLoading: false, isReadOnly: false)
        ]
        
        let view = DynamicFormView(viewModel: viewModel, country: "US")
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testDynamicFormViewLoading() {
        let viewModel = DynamicFormViewModel()
        viewModel.isLoading = true
        
        let view = DynamicFormView(viewModel: viewModel, country: "NL")
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testDynamicFormViewEmpty() {
        let viewModel = DynamicFormViewModel()
        viewModel.configuration = nil
        viewModel.isLoading = false
        
        let view = DynamicFormView(viewModel: viewModel, country: "US")
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testDynamicFormViewWithErrors() {
        let viewModel = DynamicFormViewModel()
        viewModel.configuration = KYCConfiguration(
            country: "US",
            dataSources: [],
            fields: [
                FormField(
                    id: "email",
                    label: "Email",
                    type: .text,
                    required: true,
                    validation: nil,
                    dataSource: nil
                ),
                FormField(
                    id: "age",
                    label: "Age",
                    type: .number,
                    required: true,
                    validation: nil,
                    dataSource: nil
                )
            ]
        )
        
        viewModel.formState = [
            "email": FormFieldState(
                value: "invalid",
                error: "Please enter a valid email",
                isLoading: false,
                isReadOnly: false
            ),
            "age": FormFieldState(value: "17", error: "Must be at least 18", isLoading: false, isReadOnly: false)
        ]
        
        let view = DynamicFormView(viewModel: viewModel, country: "US")
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    // swiftlint:disable:next function_body_length
    func testDynamicFormViewWithMultipleErrors() {
        let viewModel = DynamicFormViewModel()
        viewModel.configuration = KYCConfiguration(
            country: "US",
            dataSources: [],
            fields: [
                FormField(
                    id: "username",
                    label: "Username",
                    type: .text,
                    required: true,
                    validation: [
                        ValidationRule(type: .minLength, value: "3", message: "Username must be at least 3 characters"),
                        ValidationRule(
                            type: .maxLength,
                            value: "20",
                            message: "Username must be at most 20 characters"
                        ),
                        ValidationRule(
                            type: .regex,
                            value: "^[a-zA-Z0-9]+$",
                            message: "Username must contain only letters and numbers"
                        )
                    ],
                    dataSource: nil
                ),
                FormField(
                    id: "password",
                    label: "Password",
                    type: .text,
                    required: true,
                    validation: [
                        ValidationRule(type: .minLength, value: "8", message: "Password must be at least 8 characters"),
                        ValidationRule(
                            type: .regex,
                            value: ".*[A-Z].*",
                            message: "Password must contain at least one uppercase letter"
                        ),
                        ValidationRule(
                            type: .regex,
                            value: ".*[0-9].*",
                            message: "Password must contain at least one number"
                        )
                    ],
                    dataSource: nil
                ),
                FormField(
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
            ]
        )
        
        viewModel.formState = [
            "username": FormFieldState(
                value: "ab!",
                error: "Username must be at least 3 characters\nUsername must contain only letters and numbers",
                isLoading: false,
                isReadOnly: false
            ),
            "password": FormFieldState(
                value: "pass",
                error: """
                    Password must be at least 8 characters
                    Password must contain at least one uppercase letter
                    Password must contain at least one number
                    """,
                isLoading: false,
                isReadOnly: false
            ),
            "age": FormFieldState(
                value: "150",
                error: "Must be at most 100 years old",
                isLoading: false,
                isReadOnly: false
            )
        ]
        
        let view = DynamicFormView(viewModel: viewModel, country: "US")
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    // swiftlint:disable:next function_body_length
    func testDynamicFormViewNLWithReadOnly() {
        let viewModel = DynamicFormViewModel()
        viewModel.configuration = KYCConfiguration(
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
                    validation: nil,
                    dataSource: nil
                )
            ]
        )
        
        viewModel.formState = [
            "first_name": FormFieldState(value: "Jan", error: nil, isLoading: false, isReadOnly: true),
            "last_name": FormFieldState(value: "van der Berg", error: nil, isLoading: false, isReadOnly: true),
            "birth_date": FormFieldState(value: "1985-03-15", error: nil, isLoading: false, isReadOnly: true),
            "bsn": FormFieldState(value: "", error: nil, isLoading: false, isReadOnly: false)
        ]
        
        let view = DynamicFormView(viewModel: viewModel, country: "NL")
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
}
