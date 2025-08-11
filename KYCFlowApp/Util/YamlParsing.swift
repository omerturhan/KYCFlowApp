import Foundation

protocol YamlParsing {
    func decode<T: Decodable>(_ type: T.Type, from yamlString: String) throws -> T
    func encode<T: Encodable>(_ value: T) throws -> String
    func loadYaml(from url: URL) throws -> String
    func loadYaml(from data: Data) throws -> String
}

enum YamlParserError: Error {
    case invalidYaml(String)
    case decodingFailed(String)
}
