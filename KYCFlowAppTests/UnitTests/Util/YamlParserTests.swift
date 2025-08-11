import XCTest
@testable import KYCFlowApp

final class YamlParserTests: BaseTestCase {
    
    var sut: YamlParser!
    
    override func setUp() {
        super.setUp()
        sut = YamlParser()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    struct TestModel: Codable, Equatable {
        let name: String
        let age: Int
        let isActive: Bool
    }
    
    func testDecodeValidYaml() throws {
        let yamlString = """
        name: John Doe
        age: 30
        isActive: true
        """
        
        let model = try sut.decode(TestModel.self, from: yamlString)
        
        XCTAssertEqual(model.name, "John Doe")
        XCTAssertEqual(model.age, 30)
        XCTAssertTrue(model.isActive)
    }
    
    func testEncodeToYaml() throws {
        let model = TestModel(name: "Jane Smith", age: 25, isActive: false)
        
        let yamlString = try sut.encode(model)
        
        XCTAssertTrue(yamlString.contains("Jane Smith"))
        XCTAssertTrue(yamlString.contains("25"))
        XCTAssertTrue(yamlString.contains("false"))
    }
    
    func testRoundTrip() throws {
        let original = TestModel(name: "Bob", age: 40, isActive: true)
        
        let yamlString = try sut.encode(original)
        let decoded = try sut.decode(TestModel.self, from: yamlString)
        
        XCTAssertEqual(original, decoded)
    }
    
    func testDecodeInvalidYaml() {
        let invalidYaml = "this is: - not valid yaml: {["
        
        XCTAssertThrows {
            _ = try sut.decode(TestModel.self, from: invalidYaml)
        }
    }
    
    func testDecodeKYCConfiguration() throws {
        let yamlString = """
        country: TEST
        dataSources: []
        fields:
          - id: test_field
            label: Test Field
            type: text
            required: true
            readOnly: false
        """
        
        let config = try sut.decode(KYCConfiguration.self, from: yamlString)
        
        XCTAssertEqual(config.country, "TEST")
        XCTAssertTrue(config.dataSources.isEmpty)
        XCTAssertEqual(config.fields.count, 1)
        XCTAssertEqual(config.fields.first?.id, "test_field")
    }
    
    func testLoadYamlFromData() throws {
        let yamlString = "key: value"
        let data = yamlString.data(using: .utf8)!
        
        let loaded = try sut.loadYaml(from: data)
        
        XCTAssertEqual(loaded, yamlString)
    }
    
    func testLoadYamlFromInvalidData() {
        let data = Data([0xFF, 0xFE, 0xFD]) // Invalid UTF-8
        
        XCTAssertThrows {
            _ = try sut.loadYaml(from: data)
        }
    }
    
    func testDecodeArrayYaml() throws {
        let yamlString = """
        - name: Item1
          age: 10
          isActive: true
        - name: Item2
          age: 20
          isActive: false
        """
        
        let items = try sut.decode([TestModel].self, from: yamlString)
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].name, "Item1")
        XCTAssertEqual(items[1].name, "Item2")
    }
}

// Helper for testing throws
extension XCTestCase {
    func XCTAssertThrows(_ expression: () throws -> Void, file: StaticString = #file, line: UInt = #line) {
        do {
            try expression()
            XCTFail("Expected expression to throw", file: file, line: line)
        } catch {
            // Expected
        }
    }
}