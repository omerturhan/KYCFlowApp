import XCTest
import SnapshotTesting
import SwiftUI
@testable import KYCFlowApp

final class CountrySelectionViewSnapshotTests: BaseSnapshotTest {
    @MainActor
    func testCountrySelectionViewNormal() {
        let viewModel = CountrySelectionViewModel()
        viewModel.availableCountries = ["DE", "NL", "US"]
        
        let view = CountrySelectionView(viewModel: viewModel) { _ in }
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    
    @MainActor
    func testCountrySelectionViewLoading() {
        let viewModel = CountrySelectionViewModel()
        viewModel.isLoading = true
        
        let view = CountrySelectionView(viewModel: viewModel) { _ in }
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testCountrySelectionViewEmpty() {
        let viewModel = CountrySelectionViewModel()
        viewModel.availableCountries = []
        
        let view = CountrySelectionView(viewModel: viewModel) { _ in }
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
    
    @MainActor
    func testCountrySelectionViewSingleCountry() {
        let viewModel = CountrySelectionViewModel()
        viewModel.availableCountries = ["NL"]
        
        let view = CountrySelectionView(viewModel: viewModel) { _ in }
            .frame(width: 375, height: 812)
        
        assertSnapshot(of: view, size: CGSize(width: 375, height: 812))
    }
}
