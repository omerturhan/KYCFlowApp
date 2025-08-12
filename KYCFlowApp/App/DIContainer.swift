import Foundation
import SwiftUI

/// Dependency Injection Container
/// Manages all dependencies and provides them to ViewModels and Views
final class DIContainer: ObservableObject {
    // MARK: - Properties

    /// Shared instance for the application
    static let shared = DIContainer()

    // MARK: - Repositories

    private(set) lazy var kycConfigurationRepository: KYCConfigurationRepository = {
        LocalKYCConfigurationRepository()
    }()

    private(set) lazy var userProfileRepository: UserProfileRepository = {
        MockUserProfileRepository()
    }()

    // MARK: - Services

    private(set) lazy var validationService: ValidationService = {
        ValidationService()
    }()

    // MARK: - ViewModels

    @MainActor
    func makeCountrySelectionViewModel() -> CountrySelectionViewModel {
        CountrySelectionViewModel(configurationRepository: kycConfigurationRepository)
    }

    @MainActor
    func makeKYCFormViewModel() -> DynamicFormViewModel {
        DynamicFormViewModel(
            configurationRepository: kycConfigurationRepository,
            userProfileRepository: userProfileRepository,
            validationService: validationService
        )
    }
    
    @MainActor
    func makeSubmissionResultViewModel(submittedData: [String: Any]) -> SubmissionResultViewModel {
        SubmissionResultViewModel(submittedData: submittedData)
    }

    // MARK: - Environment Configuration

    enum Environment {
        case development
        case testing
        case production
    }

    private var environment: Environment = .development

    /// Configure the container for a specific environment
    func configure(for environment: Environment) {
        self.environment = environment

        switch environment {
            case .development:
                configureDevelopment()
            case .testing:
                configureTesting()
            case .production:
                configureProduction()
        }
    }

    // MARK: - Private Configuration Methods

    private func configureDevelopment() {
        // Development configuration
        // Uses mock user profile repository for NL
        // Uses local configuration files
    }

    private func configureTesting() {
        // Testing configuration
        // All repositories can be replaced with test doubles
    }

    private func configureProduction() {
        // Production configuration
        // Would use real API endpoints instead of mocks
        // For now, same as development since we're using mocks
    }

    // MARK: - Test Support

    /// Reset the container for testing purposes
    func reset() {
        // Force recreation of lazy properties
        // This is useful for testing to ensure clean state
    }

    /// Replace repository with a test double
    func setKYCConfigurationRepository(_ repository: KYCConfigurationRepository) {
        self.kycConfigurationRepository = repository
    }

    /// Replace repository with a test double
    func setUserProfileRepository(_ repository: UserProfileRepository) {
        self.userProfileRepository = repository
    }

    /// Replace service with a test double
    func setValidationService(_ service: ValidationService) {
        self.validationService = service
    }
}

// MARK: - SwiftUI Environment Support

struct DIContainerKey: EnvironmentKey {
    static let defaultValue = DIContainer.shared
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    func injectDIContainer(_ container: DIContainer = .shared) -> some View {
        self.environment(\.diContainer, container)
    }
}
