import Foundation

struct Format: Codable {
    var ldpVc: LDPFormat?
    
    enum CodingKeys: String, CodingKey {
        case ldpVc
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ldpVc = try container.decodeIfPresent(LDPFormat.self, forKey: .ldpVc)
        
        try validate()
    }
    
    func validate() throws {
        if let ldpVc = ldpVc {
            try ldpVc.validate()
        }
    }
}
