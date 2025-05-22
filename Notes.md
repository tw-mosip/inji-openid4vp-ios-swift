#  Folder / renaming elevel level changes

1. verifier DTO moved to Authorizaton request folder
2. VPResponseMetadata renamed to VPTokenSigningResult
    -> input of vpResponseMetadata will be a map of format to VPTokenSigningResultOfFormat
    ref - https://mosip.atlassian.net/wiki/spaces/Inji/pages/1574371371/Draft+21+to+Draft+23+migration+changes#Changes-Summary-as-per-discussion
3. VPTokenForSigning renamed to UnsignedVPToken
    -> return of createUnsignedVPTokens will have map of format to unsignedVPTOkenOfFormat
    ref - https://mosip.atlassian.net/wiki/spaces/Inji/pages/1574371371/Draft+21+to+Draft+23+migration+changes#Changes-Summary-as-per-discussion
4. credentialsMap format
    prev [<input_decriptor_id>: [matchingCredentials]]
    curr [<input_decriptor_id>: [<format> : [matchingCredsOfFormat]]]

## Mdoc support

### Flow of communication between library and consumer for mdoc sharing

```mermaid
---
    title: Flow of communication between library and consumer for mdoc sharing
---
sequenceDiagram
    
    participant verifier as Verifier
    participant openid4vp as OpenID4VP Library
    participant wallet as Wallet
    actor holder as Wallet Holder
    note over verifier, wallet: 1. Wallet gets the Authorization request from the verifier and displays the credentials as per Authorization request
    holder ->> wallet: 2. Holder selects VC and gives consent
    wallet ->> openid4vp: 3. Wallet sends the selected credentials to OpenID4VP Library <br/> to construct the data required for signing that will be used in Authorization response <br/> Code: `constructUnsignedVPToken(verifiableCredentials : selectedVCs)`
    openid4vp -->> openid4vp: 4.1 For each and every mdoc credential<br/> 4.2 Construct the DeviceAuthenticationBytes <br/> 4.3 Construct the UnsignedVPToken
    rect rgba(0, 0, 255, .1)
        note over openid4vp: Technical details: CBOR decoding, destructuring COSE_Key format, CBOR encoding with & without tagging
    end
    openid4vp ->> wallet: 5. Return the constructed UnsignedVPTokens
    note right of openid4vp: returns -> Map<FormatType, UnsignedVPToken> <br/> Eg - {mso_mdoc: unsignedMdocVPToken, ...}, <br/> unsignedMdocVPToken = {docTypeToDeviceAuthenticationBytes: {docType: deviceAuthenticationBytesOfOneMdoc}}
    wallet -->> wallet: 5.1 iterate the map of unsignedVPTokens and get the mdocAuthentication algorithm which will be signing algo <br/> 5.2 sign the payload provided <br/> 5.3 construct the MdocVPResponseMetadata with signedData, docType and sign (name = docTypeToDeviceAuthentication) algo format {<docType> : DeviceAuthentication : {signature : "<signature>", algorithm: "<algorithm>"} }
    rect rgba(0, 0, 255, .1)
        note over openid4vp: Technical details: CBOR encoding, CBOR encoding with & without tagging, COSE-Sign1 creation
    end
    wallet ->> openid4vp: 6. Send VPResponseMetadata
    note left of wallet: returns -> Map<FormatType, VPResponseMetadata> <br/> Eg - {mso_mdoc: mdocVPResponseMetadata, ...}, <br/> mdocVPResponseMetadata = {docType: "..",signature: "..."}
    openid4vp -->> openid4vp: 6.1 iterate the map of VPResponseMetadata <br/> 6.2 For mdoc, take the signature and construct COSE_Sign1 structure <br/> 6.3 attach the COSE_Sign1 to the respective credential using docType <br/> create mdoc vp_token
    note over openid4vp: 6.4 construct the vp_token & presentation_submission for attaching in auth response
    note over verifier, wallet: 7. Send the Authorization response to Verifier and display result in wallet





```

