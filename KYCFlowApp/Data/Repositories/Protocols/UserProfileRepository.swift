import Foundation

protocol UserProfileRepository {
    func fetchUserProfile(country: String) async throws -> [String: Any]
}
