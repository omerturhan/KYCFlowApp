import Foundation

struct KYCConfiguration: Codable, Equatable {
    let country: String
    let dataSources: [DataSource]
    let fields: [FormField]

    init(
        country: String,
        dataSources: [DataSource] = [],
        fields: [FormField] = []
    ) {
        self.country = country
        self.dataSources = dataSources
        self.fields = fields
    }
}
