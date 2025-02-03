struct DescriptorMap: Encodable{
    let id: String
    let format: FormatType
    let path: String
//    TODO: path_nested is not optional
    let path_nested: String?
}

struct PresentationSubmission: Encodable{
    let id: String = UUIDGenerator.generateUUID()
    let definition_id: String
    let descriptor_map: [DescriptorMap]
}
