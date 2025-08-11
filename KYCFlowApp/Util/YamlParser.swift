import Foundation
import Yams

struct YamlParser: YamlParsing {
    func decode<T: Decodable>(_ type: T.Type, from yamlString: String) throws -> T {
        let decoder = YAMLDecoder()
        
        do {
            return try decoder.decode(type, from: yamlString)
        } catch {
            throw YamlParserError.decodingFailed("Failed to decode YAML: \(error.localizedDescription)")
        }
    }
    
    func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = YAMLEncoder()
        
        do {
            return try encoder.encode(value)
        } catch {
            throw YamlParserError.invalidYaml("Failed to encode to YAML: \(error.localizedDescription)")
        }
    }
    
    func loadYaml(from url: URL) throws -> String {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw YamlParserError.invalidYaml("Failed to load YAML from URL: \(error.localizedDescription)")
        }
    }
    
    func loadYaml(from data: Data) throws -> String {
        guard let yamlString = String(data: data, encoding: .utf8) else {
            throw YamlParserError.invalidYaml("Failed to convert data to string")
        }
        return yamlString
    }
}
