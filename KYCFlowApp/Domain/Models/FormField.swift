import Foundation

enum FieldType: String, Codable {
    case text
    case number
    case date
}

struct FormField: Codable, Equatable {
    let id: String
    let label: String
    let type: FieldType
    let required: Bool
    let validation: [ValidationRule]? // swiftlint:disable:this discouraged_optional_collection
    let dataSource: String?
    let readOnly: Bool
    
    init(
        id: String,
        label: String,
        type: FieldType,
        required: Bool = false,
        validation: [ValidationRule]? = nil, // swiftlint:disable:this discouraged_optional_collection
        dataSource: String? = nil,
        readOnly: Bool = false
    ) {
        self.id = id
        self.label = label
        self.type = type
        self.required = required
        self.validation = validation
        self.dataSource = dataSource
        self.readOnly = readOnly
    }
    
    enum CodingKeys: String, CodingKey {
        case id, label, type, required, validation, dataSource, readOnly
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.label = try container.decode(String.self, forKey: .label)
        self.type = try container.decode(FieldType.self, forKey: .type)
        self.required = try container.decode(Bool.self, forKey: .required)
        
        // Handle validation as either array or single object with flexible properties
        if let validationContainer = try? container.nestedContainer(keyedBy: ValidationCodingKeys.self, forKey: .validation) {
            var rules: [ValidationRule] = []
            let globalMessage = try? validationContainer.decode(String.self, forKey: .message)
            
            // Helper function to decode validation with value and optional message
            func decodeValidation(for key: ValidationCodingKeys, type: ValidationType) {
                // Try to decode as object with value and message
                if let validationObject = try? validationContainer.nestedContainer(keyedBy: ValidationObjectKeys.self, forKey: key) {
                    let value: String?
                    if type == .minLength || type == .maxLength || type == .minValue || type == .maxValue {
                        value = (try? validationObject.decode(Int.self, forKey: .value)).map { String($0) }
                    } else {
                        value = try? validationObject.decode(String.self, forKey: .value)
                    }
                    let message = try? validationObject.decode(String.self, forKey: .message)
                    if let value = value {
                        rules.append(ValidationRule(type: type, value: value, message: message ?? globalMessage))
                    }
                } 
                // Try to decode as simple value (backward compatibility)
                else if type == .regex {
                    if let value = try? validationContainer.decode(String.self, forKey: key) {
                        rules.append(ValidationRule(type: type, value: value, message: globalMessage))
                    }
                } else if type == .minLength || type == .maxLength || type == .minValue || type == .maxValue {
                    if let value = try? validationContainer.decode(Int.self, forKey: key) {
                        rules.append(ValidationRule(type: type, value: String(value), message: globalMessage))
                    }
                }
            }
            
            // Check for each validation type
            decodeValidation(for: .regex, type: .regex)
            decodeValidation(for: .minLength, type: .minLength)
            decodeValidation(for: .maxLength, type: .maxLength)
            decodeValidation(for: .minValue, type: .minValue)
            decodeValidation(for: .maxValue, type: .maxValue)
            
            self.validation = rules.isEmpty ? nil : rules
        } else {
            // Try to decode as array of ValidationRule objects
            self.validation = try container.decodeIfPresent([ValidationRule].self, forKey: .validation)
        }
        
        self.dataSource = try container.decodeIfPresent(String.self, forKey: .dataSource)
        self.readOnly = try container.decodeIfPresent(Bool.self, forKey: .readOnly) ?? false
    }
    
    private enum ValidationCodingKeys: String, CodingKey {
        case regex, minLength, maxLength, minValue, maxValue, message
    }
    
    private enum ValidationObjectKeys: String, CodingKey {
        case value, message
    }
}
