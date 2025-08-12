import XCTest
@testable import KYCFlowApp

final class DataSourceTests: BaseTestCase {
    func testDataSourceInitialization() {
        let dataSource = DataSource(
            id: "user_profile",
            type: .api
        )
        
        XCTAssertEqual(dataSource.id, "user_profile")
        XCTAssertEqual(dataSource.type, .api)
        XCTAssertNil(dataSource.endpoint)
        XCTAssertTrue(dataSource.fields.isEmpty)
    }
    
    func testDataSourceWithAllProperties() {
        let dataSource = DataSource(
            id: "user_profile",
            type: .api,
            endpoint: "/api/nl-user-profile",
            fields: ["first_name", "last_name", "birth_date"]
        )
        
        XCTAssertEqual(dataSource.id, "user_profile")
        XCTAssertEqual(dataSource.type, .api)
        XCTAssertEqual(dataSource.endpoint, "/api/nl-user-profile")
        XCTAssertEqual(dataSource.fields, ["first_name", "last_name", "birth_date"])
    }
    
    func testDataSourceTypeCodable() throws {
        let types: [DataSourceType] = [.api, .manual]
        
        for type in types {
            let encoded = try JSONEncoder().encode(type)
            let decoded = try JSONDecoder().decode(DataSourceType.self, from: encoded)
            XCTAssertEqual(type, decoded)
        }
    }
    
    func testDataSourceCodable() throws {
        let dataSource = DataSource(
            id: "test_source",
            type: .api,
            endpoint: "/api/test",
            fields: ["field1", "field2"]
        )
        
        let encoded = try JSONEncoder().encode(dataSource)
        let decoded = try JSONDecoder().decode(DataSource.self, from: encoded)
        
        XCTAssertEqual(dataSource, decoded)
    }
    
    func testDataSourceEquality() {
        let source1 = DataSource(id: "source1", type: .api)
        let source2 = DataSource(id: "source1", type: .api)
        let source3 = DataSource(id: "source2", type: .manual)
        
        XCTAssertEqual(source1, source2)
        XCTAssertNotEqual(source1, source3)
    }
    
    func testManualDataSource() {
        let dataSource = DataSource(
            id: "manual_entry",
            type: .manual,
            fields: ["bsn", "address"]
        )
        
        XCTAssertEqual(dataSource.type, .manual)
        XCTAssertNil(dataSource.endpoint)
        XCTAssertEqual(dataSource.fields.count, 2)
    }
}
