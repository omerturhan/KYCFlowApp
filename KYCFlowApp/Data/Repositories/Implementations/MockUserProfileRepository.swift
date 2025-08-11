import Foundation

open class MockUserProfileRepository: UserProfileRepository {
    private let simulatedDelay: TimeInterval
    
    public init(simulatedDelay: TimeInterval = 0.5) {
        self.simulatedDelay = simulatedDelay
    }
    
    open func fetchUserProfile(country: String) async throws -> [String: Any] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        switch country.uppercased() {
            case "NL":
                // Return mocked Dutch user profile
                return [
                    "first_name": "Jan",
                    "last_name": "van der Berg",
                    "birth_date": "1985-03-15"
                ]
            case "US":
                // US doesn't use API for profile, but we can return empty or mock data for testing
                return [:]
            case "DE":
                // DE doesn't use API for profile, but we can return empty or mock data for testing
                return [:]
            default:
                throw RepositoryError.invalidCountry("No user profile available for country: \(country)")
        }
    }
}
