import SwiftUI

struct DynamicFormView: View {
    @ObservedObject var viewModel: DynamicFormViewModel
    let country: String
    let onSubmit: ([String: Any]) -> Void
    
    @State private var isSubmitting = false
    @FocusState private var focusedField: String?
    
    init(viewModel: DynamicFormViewModel, country: String, onSubmit: @escaping ([String: Any]) -> Void = { _ in }) {
        self.viewModel = viewModel
        self.country = country
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.configuration == nil {
                loadingView
            } else if let config = viewModel.configuration {
                formContent(config: config)
            } else {
                emptyStateView
            }
        }
        .navigationTitle(countryName(for: country))
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.loadForm(for: country)
        }
    }
}

// MARK: - View Components

private extension DynamicFormView {
    
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading form configuration...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No form configuration found")
                .font(.headline)
            Text("Please try selecting a different country")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    func formContent(config: KYCConfiguration) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Form header
                formHeader(config: config)
                
                // Form fields
                VStack(spacing: 16) {
                    ForEach(config.fields, id: \.id) { field in
                        FormFieldView(
                            field: field,
                            fieldState: Binding(
                                get: {
                                    viewModel.formState[field.id] ?? FormFieldState()
                                },
                                set: { newState in
                                    viewModel.formState[field.id] = newState
                                    viewModel.updateFieldValue(field.id, value: newState.value)
                                }
                            )
                        )
                        .focused($focusedField, equals: field.id)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                
                // Form footer with validation status
                formFooter
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    func formHeader(config: KYCConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Please complete all required fields")
                .font(.headline)
            
            if let dataSources = config.dataSources.first(where: { $0.type == .api }) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Some fields are pre-filled from your profile")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var formFooter: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Validating...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: submitForm) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Submit Form")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isSubmitting)
            
            if let errorCount = errorCount, errorCount > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("\(errorCount) field\(errorCount == 1 ? "" : "s") need\(errorCount == 1 ? "s" : "") attention")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

// MARK: - Actions

private extension DynamicFormView {
    
    func submitForm() {
        focusedField = nil
        isSubmitting = true
        
        // Simulate async submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Submit form and get the result
            let submittedData = viewModel.submitForm()
            isSubmitting = false
            
            // Only navigate if validation passed and we have data
            if !submittedData.isEmpty {
                onSubmit(submittedData)
            }
            // If submittedData is empty, validation errors are already shown by submitForm()
        }
    }
}

// MARK: - Helper Methods

private extension DynamicFormView {
    
    func countryName(for code: String) -> String {
        switch code.uppercased() {
        case "NL":
            return "Netherlands KYC"
        case "US":
            return "USA KYC"
        case "DE":
            return "Germany KYC"
        default:
            return code + " KYC"
        }
    }
    
    var errorCount: Int? {
        let errors = viewModel.formState.values.filter { $0.hasError }.count
        return errors > 0 ? errors : nil
    }
}

// MARK: - Preview Provider

struct DynamicFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal form
            DynamicFormView(
                viewModel: {
                    let vm = DynamicFormViewModel()
                    return vm
                }(),
                country: "US"
            )
            .previewDisplayName("US Form")
            
            // Loading state
            DynamicFormView(
                viewModel: {
                    let vm = DynamicFormViewModel()
                    vm.isLoading = true
                    return vm
                }(),
                country: "NL"
            )
            .previewDisplayName("Loading")
        }
    }
}