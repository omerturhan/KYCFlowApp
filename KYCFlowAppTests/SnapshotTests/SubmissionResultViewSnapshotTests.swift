import XCTest
import SnapshotTesting
import SwiftUI
@testable import KYCFlowApp

final class SubmissionResultViewSnapshotTests: BaseSnapshotTest {
    @MainActor
    func testSubmissionResultViewWithData() {
        let view = SubmissionResultView(
            viewModel: SubmissionResultViewModel(
                submittedData: [
                    "first_name": "John",
                    "last_name": "Doe",
                    "birth_date": "1990-01-15",
                    "email": "john.doe@example.com",
                    "phone": "+1234567890",
                    "address": "123 Main St, New York, NY 10001",
                    "country": "US"
                ]
            )
        )
        .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testSubmissionResultViewMinimalData() {
        let view = SubmissionResultView(
            viewModel: SubmissionResultViewModel(
                submittedData: [
                    "name": "Test User",
                    "id": "12345"
                ]
            )
        )
        .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testSubmissionResultViewEmptyData() {
        let view = SubmissionResultView(
            viewModel: SubmissionResultViewModel(submittedData: [:])
        )
        .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testSubmissionResultViewLongData() {
        let view = SubmissionResultView(
            viewModel: SubmissionResultViewModel(
                submittedData: [
                "first_name": "John",
                "middle_name": "Michael",
                "last_name": "Doe",
                "birth_date": "1990-01-15",
                "email": "john.doe@example.com",
                "secondary_email": "jdoe@company.com",
                "phone": "+1234567890",
                "mobile": "+9876543210",
                "address_line_1": "123 Main Street",
                "address_line_2": "Apartment 4B",
                "city": "New York",
                "state": "NY",
                "postal_code": "10001",
                "country": "United States",
                "nationality": "American",
                "occupation": "Software Engineer",
                "company": "Tech Corp",
                "annual_income": "100000",
                "tax_id": "XXX-XX-1234",
                "id_type": "passport",
                "id_number": "P123456789"
                ]
            )
        )
        .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
}
