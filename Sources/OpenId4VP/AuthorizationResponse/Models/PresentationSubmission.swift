struct DescriptorMap: Encodable{
    var id: String
    var format: Format
    var path: String
}

struct PresentationSubmission: Encodable{
    let id: String = UUIDGenerator.generateUUID()
    let definition_id: String
    let descriptor_map: [DescriptorMap]
}
