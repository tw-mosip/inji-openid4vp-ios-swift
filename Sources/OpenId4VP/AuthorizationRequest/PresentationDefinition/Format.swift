import Foundation

struct Format: Codable {
    var jwt: JWTFormat?
    var jwt_vc: JWTFormat?
    var jwt_vp: JWTFormat?
    var ldp_vc: LDPFormat?
    var ldp_vp: LDPFormat?
    var missingFields: [String]?
    
    enum CodingKeys: String, CodingKey {
        case jwt
        case jwt_vc
        case jwt_vp
        case ldp_vc
        case ldp_vp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var missingFields: [String] = []
        
        if let jwt = try container.decodeIfPresent(JWTFormat.self, forKey: .jwt) {
            self.jwt = jwt
            if let jwtMissingFields = jwt.missingFields {
                missingFields.append(contentsOf: jwtMissingFields.map { "JWT: \($0)" })
            }
        } else {
            self.jwt = nil
        }
        
        if let jwt_vc = try container.decodeIfPresent(JWTFormat.self, forKey: .jwt_vc) {
            self.jwt_vc = jwt_vc
            if let jwtVcMissingFields = jwt_vc.missingFields {
                missingFields.append(contentsOf: jwtVcMissingFields.map { "JWT VC: \($0)" })
            }
        } else {
            self.jwt_vc = nil
        }
        
        if let jwt_vp = try container.decodeIfPresent(JWTFormat.self, forKey: .jwt_vp) {
            self.jwt_vp = jwt_vp
            if let jwtVpMissingFields = jwt_vp.missingFields {
                missingFields.append(contentsOf: jwtVpMissingFields.map { "JWT VP: \($0)" })
            }
        } else {
            self.jwt_vp = nil
        }
        
        if let ldp_vc = try container.decodeIfPresent(LDPFormat.self, forKey: .ldp_vc) {
            self.ldp_vc = ldp_vc
            if let ldpVcMissingFields = ldp_vc.missingFields {
                missingFields.append(contentsOf: ldpVcMissingFields.map { "LDP VC: \($0)" })
            }
        } else {
            self.ldp_vc = nil
        }
        
        if let ldp_vp = try container.decodeIfPresent(LDPFormat.self, forKey: .ldp_vp) {
            self.ldp_vp = ldp_vp
            if let ldpVpMissingFields = ldp_vp.missingFields {
                missingFields.append(contentsOf: ldpVpMissingFields.map { "LDP VP: \($0)" })
            }
        } else {
            self.ldp_vp = nil
        }
        
        self.missingFields = missingFields
    }
    
    func validate() -> [String] {
        var errors: [String] = []
        
        if let jwt = jwt {
            let jwtErrors = jwt.validate()
            if !jwtErrors.isEmpty {
                errors.append(contentsOf: jwtErrors.map { "JWT: \($0)" })
            }
        }
        
        if let jwt_vc = jwt_vc {
            let jwtVcErrors = jwt_vc.validate()
            if !jwtVcErrors.isEmpty {
                errors.append(contentsOf: jwtVcErrors.map { "JWT_VC: \($0)" })
            }
        }
        
        if let jwt_vp = jwt_vp {
            let jwtVpErrors = jwt_vp.validate()
            if !jwtVpErrors.isEmpty {
                errors.append(contentsOf: jwtVpErrors.map { "JWT_VP: \($0)" })
            }
        }
        
        if let ldp_vc = ldp_vc {
            let ldpVcErrors = ldp_vc.validate()
            if !ldpVcErrors.isEmpty {
                errors.append(contentsOf: ldpVcErrors.map { "LDP_VC: \($0)" })
            }
        }
        
        if let ldp_vp = ldp_vp {
            let ldpVpErrors = ldp_vp.validate()
            if !ldpVpErrors.isEmpty {
                errors.append(contentsOf: ldpVpErrors.map { "LDP_VP: \($0)" })
            }
        }
        
        if errors.isEmpty {
            errors.append("At least one format must be valid.")
        }
        
        return errors
    }
}
