import Foundation
import SwiftUI

@MainActor
final class KYCFormViewModel: ObservableObject {
    @Published var formState: FormState = [:]
    @Published var isLoading = false
    @Published var configuration: KYCConfiguration?
    @Published var errorMessage: String?
    @Published var isSubmitted = false
    @Published var submittedData: [String: Any] = [:]
    
    private let configurationRepository: KYCConfigurationRepository
    private let userProfileRepository: UserProfileRepository
    private let validationService: ValidationServiceProtocol
    
    init(
        configurationRepository: KYCConfigurationRepository = LocalKYCConfigurationRepository(),
        userProfileRepository: UserProfileRepository = MockUserProfileRepository(),
        validationService: ValidationServiceProtocol = ValidationService()
    ) {
        self.configurationRepository = configurationRepository
        self.userProfileRepository = userProfileRepository
        self.validationService = validationService
    }
    
    // MARK: - Form Loading
    
    func loadForm(for country: String) async {
        isLoading = true
        errorMessage = nil
        formState = [:]
        
        do {
            // Load configuration
            let config = try await configurationRepository.loadConfiguration(for: country)
            self.configuration = config
            
            // Initialize form state for all fields
            initializeFormState(with: config)
            
            // Load data from data sources if any
            await loadDataFromSources(config: config)
        } catch {
            self.errorMessage = "Failed to load form: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func initializeFormState(with config: KYCConfiguration) {
        for field in config.fields {
            formState[field.id] = FormFieldState(
                value: nil,
                error: nil,
                isLoading: false,
                isReadOnly: field.readOnly
            )
        }
    }
    
    private func loadDataFromSources(config: KYCConfiguration) async {
        // Group fields by data source
        var fieldsByDataSource: [String: [FormField]] = [:]
        
        for field in config.fields {
            if let dataSourceId = field.dataSource {
                if fieldsByDataSource[dataSourceId] == nil {
                    fieldsByDataSource[dataSourceId] = []
                }
                fieldsByDataSource[dataSourceId]?.append(field)
            }
        }
        
        // Load data for each data source
        for (dataSourceId, fields) in fieldsByDataSource {
            // Set loading state for these fields
            for field in fields {
                formState.setLoading(for: field.id, isLoading: true)
            }
            
            // Find the data source configuration
            if let dataSource = config.dataSources.first(where: { $0.id == dataSourceId }) {
                await loadDataFromSource(dataSource, fields: fields, country: config.country)
            }
            
            // Clear loading state
            for field in fields {
                formState.setLoading(for: field.id, isLoading: false)
            }
        }
    }
    
    private func loadDataFromSource(_ dataSource: DataSource, fields: [FormField], country: String) async {
        guard dataSource.type == .api else { 
            return 
        }
        
        do {
            let profileData = try await userProfileRepository.fetchUserProfile(country: country)
            
            // Map the fetched data to form fields
            for field in fields {
                if let value = profileData[field.id] {
                    formState.updateValue(for: field.id, value: value)
                }
            }
        } catch {
            // Set error for all fields from this data source
            for field in fields {
                formState.setError(for: field.id, error: "Failed to load data")
            }
        }
    }
    
    // MARK: - Field Updates
    
    func updateFieldValue(_ fieldId: String, value: Any?) {
        formState.updateValue(for: fieldId, value: value)
        
        // Validate the field immediately
        if let field = configuration?.fields.first(where: { $0.id == fieldId }) {
            validateField(field)
        }
    }
    
    // MARK: - Validation
    
    func validateField(_ field: FormField) {
        let value = formState.getValue(for: field.id)
        let result = validationService.validateField(field, value: value)
        
        if result.isValid {
            formState.setError(for: field.id, error: nil)
        } else {
            formState.setError(for: field.id, error: result.errorMessage)
        }
    }
    
    func validateAllFields() -> Bool {
        guard let config = configuration else { 
            return false 
        }
        
        var isValid = true
        
        for field in config.fields {
            validateField(field)
            if formState[field.id]?.hasError == true {
                isValid = false
            }
        }
        
        return isValid
    }
    
    // MARK: - Form Submission
    
    func submitForm() -> [String: Any] {
        guard validateAllFields() else {
            errorMessage = "Please fix all errors before submitting"
            return [:]
        }
        
        var result: [String: Any] = [:]
        
        if let config = configuration {
            for field in config.fields {
                if let value = formState.getValue(for: field.id) {
                    result[field.id] = value
                }
            }
        }
        
        submittedData = result
        isSubmitted = true
        
        return result
    }
    
    // MARK: - Helper Methods
    
    func resetForm() {
        formState = [:]
        configuration = nil
        errorMessage = nil
        isSubmitted = false
        submittedData = [:]
    }
    
    var canSubmit: Bool {
        !isLoading && configuration != nil && formState.isValid()
    }
    
    var hasConfiguration: Bool {
        configuration != nil
    }
}