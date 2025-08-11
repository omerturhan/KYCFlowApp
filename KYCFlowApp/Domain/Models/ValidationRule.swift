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
    let errorMessage: String?

    static var valid: ValidationResult {
        ValidationResult(isValid: true, errorMessage: nil)
    }

    static func invalid(_ message: String) -> ValidationResult {
        ValidationResult(isValid: false, errorMessage: message)
    }
}
