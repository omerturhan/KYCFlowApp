import Foundation

final class MockYamlParser: YamlParsing {
    var decodeCallCount = 0
    var encodeCallCount = 0
    var loadYamlFromURLCallCount = 0
    var loadYamlFromDataCallCount = 0
    
    var decodeResult: Any?
    var encodeResult: String = ""
    var loadYamlResult: String = ""
    var shouldThrowError = false
    var errorToThrow: Error = YamlParserError.decodingFailed("Mock error")
    
    func decode<T: Decodable>(_ type: T.Type, from yamlString: String) throws -> T {
        decodeCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        if let result = decodeResult as? T {
            return result
        }
        
        throw YamlParserError.decodingFailed("Mock decode not configured for type \(type)")
    }
    
    func encode<T: Encodable>(_ value: T) throws -> String {
        encodeCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return encodeResult
    }
    
    func loadYaml(from url: URL) throws -> String {
        loadYamlFromURLCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return loadYamlResult
    }
    
    func loadYaml(from data: Data) throws -> String {
        loadYamlFromDataCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return loadYamlResult
    }
}
