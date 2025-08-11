import Foundation

struct UserProfile: Codable, Equatable {
    let firstName: String
    let lastName: String
    let birthDate: String
    let bsn: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case bsn
    }
    
    init(
        firstName: String,
        lastName: String,
        birthDate: String,
        bsn: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.bsn = bsn
    }
}