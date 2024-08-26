struct DescriptorMap: Encodable{
    let id: String
    let format: Format
    let path: String
}

struct PresentationSubmission: Encodable{
    let id: String = UUIDGenerator.generateUUID()
    let definition_id: String
    let descriptor_map: [DescriptorMap]
}
