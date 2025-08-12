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
        """
        
        let config = try sut.decode(KYCConfiguration.self, from: yamlString)
        
        XCTAssertEqual(config.country, "TEST")
        XCTAssertTrue(config.dataSources.isEmpty)
        XCTAssertEqual(config.fields.count, 1)
        XCTAssertEqual(config.fields.first?.id, "test_field")
        XCTAssertFalse(config.fields.first?.readOnly ?? true, "readOnly should default to false when not present")
    }
    
    func testDecodeKYCConfigurationWithExplicitReadOnly() throws {
        let yamlString = """
        country: TEST
        dataSources: []
        fields:
          - id: test_field
            label: Test Field
            type: text
            required: true
            readOnly: true
        """
        
        let config = try sut.decode(KYCConfiguration.self, from: yamlString)
        
        XCTAssertEqual(config.fields.first?.readOnly, true)
    }
    
    func testLoadYamlFromData() throws {
        let yamlString = "key: value"
        guard let data = yamlString.data(using: .utf8) else {
            XCTFail("Failed to create data from string")
            return
        }
        
        let loaded = try sut.loadYaml(from: data)
        
        XCTAssertEqual(loaded, yamlString)
    }
    
    func testLoadYamlFromInvalidData() {
        let data = Data([0xFF, 0xFE, 0xFD]) // Invalid UTF-8
        
        XCTAssertThrows {
            _ = try sut.loadYaml(from: data)
        }
    }
    
    func testDecodeKYCConfigurationWithSimpleValidation() throws {
        let yamlString = """
        country: NL
        dataSources: []
        fields:
          - id: bsn
            label: BSN
            type: text
            required: true
            validation:
              regex: '^\\d{9}$'
              message: 'BSN must be 9 digits'
        """
        
        let config = try sut.decode(KYCConfiguration.self, from: yamlString)
        
        XCTAssertEqual(config.fields.count, 1)
        XCTAssertEqual(config.fields.first?.id, "bsn")
        XCTAssertNotNil(config.fields.first?.validation)
        XCTAssertEqual(config.fields.first?.validation?.count, 1)
        XCTAssertEqual(config.fields.first?.validation?.first?.type, .regex)
        XCTAssertEqual(config.fields.first?.validation?.first?.value, "^\\d{9}$")
        XCTAssertEqual(config.fields.first?.validation?.first?.message, "BSN must be 9 digits")
    }
    
    func testDecodeKYCConfigurationWithMinLengthValidation() throws {
        let yamlString = """
        country: US
        dataSources: []
        fields:
          - id: first_name
            label: First Name
            type: text
            required: true
            validation:
              minLength: 2
              message: 'Name must be at least 2 characters'
        """
        
        let config = try sut.decode(KYCConfiguration.self, from: yamlString)
        
        XCTAssertEqual(config.fields.first?.validation?.count, 1)
        XCTAssertEqual(config.fields.first?.validation?.first?.type, .minLength)
        XCTAssertEqual(config.fields.first?.validation?.first?.value, "2")
        XCTAssertEqual(config.fields.first?.validation?.first?.message, "Name must be at least 2 characters")
    }
    
    func testDecodeKYCConfigurationWithMinAndMaxLength() throws {
        let yamlString = """
        country: US
        dataSources: []
        fields:
          - id: first_name
            label: First Name
            type: text
            required: true
            validation:
              minLength: 2
              maxLength: 50
              message: 'Name must be between 2 and 50 characters'
        """
        
        let config = try sut.decode(KYCConfiguration.self, from: yamlString)
        
        XCTAssertEqual(config.fields.first?.validation?.count, 2)
        
        let validationRules = config.fields.first?.validation ?? []
        let minLengthRule = validationRules.first { $0.type == .minLength }
        let maxLengthRule = validationRules.first { $0.type == .maxLength }
        
        XCTAssertNotNil(minLengthRule)
        XCTAssertEqual(minLengthRule?.value, "2")
        XCTAssertEqual(minLengthRule?.message, "Name must be between 2 and 50 characters")
        
        XCTAssertNotNil(maxLengthRule)
        XCTAssertEqual(maxLengthRule?.value, "50")
        XCTAssertEqual(maxLengthRule?.message, "Name must be between 2 and 50 characters")
    }
    
    func testDecodeKYCConfigurationWithIndividualMessages() throws {
        let yamlString = """
        country: US
        dataSources: []
        fields:
          - id: first_name
            label: First Name
            type: text
            required: true
            validation:
              minLength:
                value: 2
                message: 'First name must be at least 2 characters'
              maxLength:
                value: 50
                message: 'First name cannot exceed 50 characters'
        """
        
        let config = try sut.decode(KYCConfiguration.self, from: yamlString)
        
        XCTAssertEqual(config.fields.first?.validation?.count, 2)
        
        let validationRules = config.fields.first?.validation ?? []
        let minLengthRule = validationRules.first { $0.type == .minLength }
        let maxLengthRule = validationRules.first { $0.type == .maxLength }
        
        XCTAssertNotNil(minLengthRule)
        XCTAssertEqual(minLengthRule?.value, "2")
        XCTAssertEqual(minLengthRule?.message, "First name must be at least 2 characters")
        
        XCTAssertNotNil(maxLengthRule)
        XCTAssertEqual(maxLengthRule?.value, "50")
        XCTAssertEqual(maxLengthRule?.message, "First name cannot exceed 50 characters")
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
