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
            "email": FormFieldState(value: "invalid", error: "Please enter a valid email", isLoading: false, isReadOnly: false),
            "age": FormFieldState(value: "17", error: "Must be at least 18", isLoading: false, isReadOnly: false)
        ]
        
        let view = DynamicFormView(viewModel: viewModel, country: "US")
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
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
