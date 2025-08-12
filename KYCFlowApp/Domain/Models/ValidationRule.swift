import Foundation

enum ValidationType: String, Codable {
    case required
    case regex
    case minLength
    case maxLength
    case minValue
    case maxValue
}

struct ValidationRule: Codable, Equatable {
    let type: ValidationType
    let value: String?
    let message: String?

    init(type: ValidationType, value: String? = nil, message: String? = nil) {
        self.type = type
        self.value = value
        self.message = message
    }
}

struct ValidationResult: Equatable {
    let isValid: Bool
    let errorMessages: [String]

    static var valid: ValidationResult {
        ValidationResult(isValid: true, errorMessages: [])
    }

    static func invalid(_ message: String) -> ValidationResult {
        ValidationResult(isValid: false, errorMessages: [message])
    }

    static func invalid(_ messages: [String]) -> ValidationResult {
        ValidationResult(isValid: false, errorMessages: messages)
    }

    var errorMessage: String? {
        errorMessages.first
    }

    var allErrorMessages: String? {
        errorMessages.isEmpty ? nil : errorMessages.joined(separator: "\n")
    }
}
