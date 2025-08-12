import XCTest
@testable import KYCFlowApp

final class KYCConfigurationTests: BaseTestCase {
    func testKYCConfigurationInitialization() {
        let config = KYCConfiguration(country: "NL")
        
        XCTAssertEqual(config.country, "NL")
        XCTAssertTrue(config.dataSources.isEmpty)
        XCTAssertTrue(config.fields.isEmpty)
    }
    
    func testKYCConfigurationWithDataSources() {
        let dataSources = [
            DataSource(
                id: "user_profile",
                type: .api,
                endpoint: "/api/nl-user-profile",
                fields: ["first_name", "last_name", "birth_date"]
            )
        ]
        
        let config = KYCConfiguration(
            country: "NL",
            dataSources: dataSources
        )
        
        XCTAssertEqual(config.country, "NL")
        XCTAssertEqual(config.dataSources.count, 1)
        XCTAssertEqual(config.dataSources.first?.id, "user_profile")
    }
    
    func testKYCConfigurationWithFields() {
        let fields = [
            FormField(
                id: "first_name",
                label: "First Name",
                type: .text,
                required: true,
                dataSource: "user_profile",
                readOnly: true
            ),
            FormField(
                id: "bsn",
                label: "BSN",
                type: .text,
                required: true,
                validation: [
                    ValidationRule(type: .regex, value: "^\\d{9}$", message: "BSN must be 9 digits")
                ]
            )
        ]
        
        let config = KYCConfiguration(
            country: "NL",
            fields: fields
        )
        
        XCTAssertEqual(config.fields.count, 2)
        XCTAssertEqual(config.fields.first?.id, "first_name")
        XCTAssertTrue(config.fields.first?.readOnly ?? false)
    }
    
    func testKYCConfigurationCodable() throws {
        let dataSource = DataSource(
            id: "user_profile",
            type: .api,
            endpoint: "/api/user",
            fields: ["name", "date"]
        )
        
        let field = FormField(
            id: "name",
            label: "Name",
            type: .text,
            required: true
        )
        
        let config = KYCConfiguration(
            country: "US",
            dataSources: [dataSource],
            fields: [field]
        )
        
        let encoded = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(KYCConfiguration.self, from: encoded)
        
        XCTAssertEqual(config, decoded)
    }
    
    // swiftlint:disable:next function_body_length
    func testKYCConfigurationCompleteExample() {
        let dataSources = [
            DataSource(
                id: "user_profile",
                type: .api,
                endpoint: "/api/nl-user-profile",
                fields: ["first_name", "last_name", "birth_date"]
            )
        ]
        
        let fields = [
            FormField(
                id: "first_name",
                label: "First Name",
                type: .text,
                required: true,
                dataSource: "user_profile",
                readOnly: true
            ),
            FormField(
                id: "last_name",
                label: "Last Name",
                type: .text,
                required: true,
                dataSource: "user_profile",
                readOnly: true
            ),
            FormField(
                id: "birth_date",
                label: "Birth Date",
                type: .date,
                required: true,
                dataSource: "user_profile",
                readOnly: true
            ),
            FormField(
                id: "bsn",
                label: "BSN",
                type: .text,
                required: true,
                validation: [
                    ValidationRule(type: .regex, value: "^\\d{9}$", message: "BSN must be 9 digits")
                ]
            )
        ]
        
        let config = KYCConfiguration(
            country: "NL",
            dataSources: dataSources,
            fields: fields
        )
        
        XCTAssertEqual(config.country, "NL")
        XCTAssertEqual(config.dataSources.count, 1)
        XCTAssertEqual(config.fields.count, 4)
        
        // Verify fields with dataSource are read-only
        let dataSourceFields = config.fields.filter { $0.dataSource != nil }
        XCTAssertEqual(dataSourceFields.count, 3)
        XCTAssertTrue(dataSourceFields.allSatisfy { $0.readOnly })
    }
    
    func testKYCConfigurationEquality() {
        let config1 = KYCConfiguration(country: "US")
        let config2 = KYCConfiguration(country: "US")
        let config3 = KYCConfiguration(country: "DE")
        
        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }
}
