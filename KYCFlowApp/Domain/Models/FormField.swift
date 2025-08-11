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
}
