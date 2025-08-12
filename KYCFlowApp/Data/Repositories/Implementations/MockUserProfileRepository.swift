import Foundation

open class MockUserProfileRepository: UserProfileRepository {
    private let simulatedDelay: TimeInterval
    
    // Mock API response stored as JSON string
    private let mockAPIResponse = """
    {
        "first_name": "Jan",
        "last_name": "van der Berg",
        "birth_date": "1985-03-15"
    }
    """

    public init(simulatedDelay: TimeInterval = 0.5) {
        self.simulatedDelay = simulatedDelay
    }

    open func fetchUserProfile(endpoint: String, fields: [String]) async throws -> [String: Any] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        // Only handle the NL user profile endpoint
        guard endpoint == "/api/nl-user-profile" else {
            throw RepositoryError.apiError("Endpoint not found: \(endpoint)")
        }
        
        // Parse JSON string to Data
        guard let jsonData = mockAPIResponse.data(using: .utf8) else {
            throw RepositoryError.decodingError("Invalid JSON data")
        }
        
        // Parse JSON Data to Dictionary
        do {
            guard let fullResponse = try JSONSerialization.jsonObject(
                with: jsonData,
                options: []
            ) as? [String: Any] else {
                throw RepositoryError.decodingError("Invalid JSON structure")
            }
            
            // Filter response to only include requested fields
            var filteredResponse: [String: Any] = [:]
            for field in fields {
                if let value = fullResponse[field] {
                    filteredResponse[field] = value
                }
            }
            
            // Simulate API behavior: if requested field doesn't exist, return null
            for field in fields where filteredResponse[field] == nil {
                filteredResponse[field] = NSNull()
            }
            
            return filteredResponse
        } catch {
            throw RepositoryError.decodingError("Failed to parse JSON: \(error.localizedDescription)")
        }
    }
}
