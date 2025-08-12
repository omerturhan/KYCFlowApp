import SwiftUI

struct CountrySelectionView: View {
    @StateObject private var viewModel: CountrySelectionViewModel
    let onCountrySelected: (String) -> Void

    init(
        viewModel: CountrySelectionViewModel? = nil,
        onCountrySelected: @escaping (String) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel ?? CountrySelectionViewModel())
        self.onCountrySelected = onCountrySelected
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else {
                    countryList
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task {
            await viewModel.loadCountries()
        }
    }
}

// MARK: - View Components

private extension CountrySelectionView {
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading countries...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder var countryList: some View {
        if viewModel.availableCountries.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.availableCountries, id: \.self) { country in
                        countryRow(for: country)
                    }
                }
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(12)
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Countries Available")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Please check your internet connection or try again later.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
    }

    @ViewBuilder
    func countryRow(for country: String) -> some View {
        Button {
            onCountrySelected(country)
        } label: {
            HStack {
                // Country flag emoji
                Text(countryFlag(for: country))
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(countryName(for: country))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(countryDescription(for: country))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.body)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())

        if country != viewModel.availableCountries.last {
            Divider()
                .padding(.leading, 60)
        }
    }
}

// MARK: - Helper Methods

private extension CountrySelectionView {
    func countryFlag(for code: String) -> String {
        switch code.uppercased() {
            case "NL":
                return "🇳🇱"
            case "US":
                return "🇺🇸"
            case "DE":
                return "🇩🇪"
            default:
            return "🏳️"
        }
    }

    func countryName(for code: String) -> String {
        switch code.uppercased() {
            case "NL":
                return "Netherlands"
            case "US":
                return "United States"
            case "DE":
                return "Germany"
            default:
            return code
        }
    }

    func countryDescription(for code: String) -> String {
        switch code.uppercased() {
            case "NL":
                return "Personal data fetched from API"
            case "US":
                return "Standard KYC form"
            case "DE":
                return "EU compliant form"
            default:
            return "Custom configuration"
        }
    }
}

// MARK: - Preview Provider

struct CountrySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal state with countries
            CountrySelectionView { country in
                _ = country
            }
            .previewDisplayName("With Countries")

            // Loading state
            CountrySelectionView(
                viewModel: {
                    let vm = CountrySelectionViewModel()
                    vm.isLoading = true
                    return vm
                }()
            ) { _ in
            }
            .previewDisplayName("Loading")

            // Error state
            CountrySelectionView(
                viewModel: {
                    let vm = CountrySelectionViewModel()
                    vm.errorMessage = "Failed to load countries"
                    return vm
                }()
            ) { _ in
            }
            .previewDisplayName("Error")
        }
    }
}
