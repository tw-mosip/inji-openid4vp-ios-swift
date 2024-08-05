struct DescriptorMap: Encodable{
    var id: String
    var format: String
    var path: String
}

struct PresentationSubmission: Encodable{
    let id: String = uuid.presentationSubmissionId
    let definition_id: String
    let descriptor_map: [DescriptorMap]
}
