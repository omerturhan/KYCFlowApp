import Foundation

enum DataSourceType: String, Codable {
    case api
    case manual
}

struct DataSource: Codable, Equatable {
    let id: String
    let type: DataSourceType
    let endpoint: String?
    let fields: [String]

    init(
        id: String,
        type: DataSourceType,
        endpoint: String? = nil,
        fields: [String] = []
    ) {
        self.id = id
        self.type = type
        self.endpoint = endpoint
        self.fields = fields
    }
}
