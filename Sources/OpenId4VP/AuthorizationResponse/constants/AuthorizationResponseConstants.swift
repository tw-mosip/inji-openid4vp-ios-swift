import Foundation

struct uuid{
    static let vpToken = UUID().uuidString.lowercased()
    static let presentationSubmissionId = UUID().uuidString.lowercased()
}

struct format{
    static let ldp_vc = "ldp_vc"
}

struct ProofPurpose{
    static let vpProofPurpose = "authentication"
}
