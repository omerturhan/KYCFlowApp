import XCTest
@testable import KYCFlowApp

final class UserProfileTests: BaseTestCase {
    
    func testUserProfileInitialization() {
        let profile = UserProfile(
            firstName: "Jan",
            lastName: "van der Berg",
            birthDate: "1985-03-15"
        )
        
        XCTAssertEqual(profile.firstName, "Jan")
        XCTAssertEqual(profile.lastName, "van der Berg")
        XCTAssertEqual(profile.birthDate, "1985-03-15")
        XCTAssertNil(profile.bsn)
    }
    
    func testUserProfileWithBSN() {
        let profile = UserProfile(
            firstName: "Emma",
            lastName: "de Vries",
            birthDate: "1990-07-22",
            bsn: "123456789"
        )
        
        XCTAssertEqual(profile.firstName, "Emma")
        XCTAssertEqual(profile.lastName, "de Vries")
        XCTAssertEqual(profile.birthDate, "1990-07-22")
        XCTAssertEqual(profile.bsn, "123456789")
    }
    
    func testUserProfileCodable() throws {
        let profile = UserProfile(
            firstName: "John",
            lastName: "Doe",
            birthDate: "1980-01-01",
            bsn: "987654321"
        )
        
        let encoded = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: encoded)
        
        XCTAssertEqual(profile, decoded)
    }
    
    func testUserProfileDecodingFromJSON() throws {
        let json = """
        {
            "first_name": "Alice",
            "last_name": "Johnson",
            "birth_date": "1995-05-10"
        }
        """
        
        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to create data from JSON string")
            return
        }
        let profile = try JSONDecoder().decode(UserProfile.self, from: data)
        
        XCTAssertEqual(profile.firstName, "Alice")
        XCTAssertEqual(profile.lastName, "Johnson")
        XCTAssertEqual(profile.birthDate, "1995-05-10")
        XCTAssertNil(profile.bsn)
    }
    
    func testUserProfileEncodingToJSON() throws {
        let profile = UserProfile(
            firstName: "Bob",
            lastName: "Smith",
            birthDate: "1988-12-25",
            bsn: "111222333"
        )
        
        let encoded = try JSONEncoder().encode(profile)
        guard let json = try JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            XCTFail("Failed to decode JSON object")
            return
        }
        
        XCTAssertEqual(json["first_name"] as? String, "Bob")
        XCTAssertEqual(json["last_name"] as? String, "Smith")
        XCTAssertEqual(json["birth_date"] as? String, "1988-12-25")
        XCTAssertEqual(json["bsn"] as? String, "111222333")
    }
    
    func testUserProfileEquality() {
        let profile1 = UserProfile(
            firstName: "Jan",
            lastName: "van der Berg",
            birthDate: "1985-03-15"
        )
        
        let profile2 = UserProfile(
            firstName: "Jan",
            lastName: "van der Berg",
            birthDate: "1985-03-15"
        )
        
        let profile3 = UserProfile(
            firstName: "Emma",
            lastName: "de Vries",
            birthDate: "1990-07-22"
        )
        
        XCTAssertEqual(profile1, profile2)
        XCTAssertNotEqual(profile1, profile3)
    }
}