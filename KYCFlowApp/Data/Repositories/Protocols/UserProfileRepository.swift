import Foundation

protocol UserProfileRepository {
    func fetchUserProfile(endpoint: String, fields: [String]) async throws -> [String: Any]
}
