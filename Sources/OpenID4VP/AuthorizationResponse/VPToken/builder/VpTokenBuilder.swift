import Foundation

protocol VpTokenBuilder {
    func build() throws -> CredentialFormatSpecificVPToken
}
