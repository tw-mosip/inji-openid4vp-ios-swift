# INJI-OpenID4Vp-ios-swift
- Implementation of OpenID4VP protocols in Swift.

## Features
- Process the Authorization Request of the verifier received from the Wallet.
- Validate and return the valid Presentation Definition or scope to the wallet.
- Receives the list of verifiable credentials from the wallet.
- Constructs the verifiable presentation and send it to wallet for proof generation.
- Receives the signed Verifiable presentation and sends a POST request to the URL specified in the verifier request.

## Installation
- In your swift application go to file > add package dependency > add the  https://github.com/mosip/inji-openid4vp-ios-swift.git in git search bar> add package
- Import the library and use

## APIs

### authenticateVerifier
 - Receives a base64 Encoded request of the verifier and returns a valid Presentation Definition or Scope as response.
This function takes an encoded authorization request and a JSON array of trusted verifiers.
 - Returns the Authentication response which contain either validated Presentation Definition or Scope based on the request given.



```
    let response = try authenticateVerifier(encodedAuthorizationRequest: String, trustedVerifierJSON: [Verifier])
```

###### Parameters

| Name                         | Type       | Description                                                 | Sample                                              |
|------------------------------|------------|-------------------------------------------------------------|-----------------------------------------------------|
| encodedAuthorizationRequest | String     | Base64 Encoded authorization request.                       | `"T1BFTklENFZQOi8vYXV0"`                            |
| trustedVerifierJSON          | [Verifier] | Array of verifiers to verify the client id of the verifier. | `Verifier(clientId: String, redirectUri: [String])` |


###### Exceptions

1. DecodingException is thrown when there is and issue while decoding the Authorization Request
2. InvalidQueryParams exception is thrown if
    - query params are not present in the Request
    - there is a issue while extracting the params
    - both presentation_definition & scope are present in Request
    - neither presentation_definition nor scope present in Request
3. InvalidInput exception is thrown if any of required params value is empty
4. InvalidVerifierClientID exception is thrown if the received request client_iD & response_uri are not matching with any of the trusted verifiers

This method will also notify the Verifier about the error by sending it to the response_uri endpoint over http post request. If response_uri is invalid and validation failed then Verifier won't be able to know about it.


### constructVerifiablePresentation
- This function takes a map of credentials and returns a verifiable presentation as a String for signing.
- Returns Json string back with verifiable presentation created using the credentials received without proof field.

```
    let response = try openID4VP.constructVerifiablePresentation(credentialsMap: [String: [String]])
```

###### Parameters

| Name                | Type             | Description                                                                                              | Sample                                            |
|---------------------|------------------|----------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| credentialsMap      | [String: [String]] | Contains the input descriptor id as key and corresponding matching Verifiable Credentials as array of string. | `["bank_input":["VC1","VC2"]]`                            |


###### Exceptions

1. JsonEncodingException is thrown if there is any issue while serializing the Verifiable Presentation token without proof.

### shareVerifiablePresentation
- This function takes VPResponseMetadata type which contains the proof details which is used to construct the verifiable presentation with proof to send it to verifier as POST request.
- Returns the response with a success message back to the wallet.

```
    let response = try await openID4VP.shareVerifiablePresentation(vpResponseMetadata: VPResponseMetadata)
```

###### Parameters

| Name                | Type             | Description                                                                                               | Sample                                            |
|---------------------|------------------|-----------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| vpResponseMetadata      |  | Contains a VPResponseMetadata which has proof details such as  jws, signatureAlgorithm, publicKey, domain | `VPResponseMetadata(jws: "jws", signatureAlgorithm: "signatureAlgoType", publicKey: "publicKey", domain: "domain")`                            |


###### Exceptions

1. JsonEncodingException is thrown if there is any issue while serializing the Verifiable Presentation token or Presentation Submission class instance
2. InterruptedIOException is thrown if the connection is timed out when network call is made.
3. NetworkRequestFailed exception is thrown when there is any other exception occurred when sending the response over http post request.

This method will also notify the Verifier about the error by sending it to the response_uri endpoint over http post request. If response_uri is invalid and validation failed then Verifier won't be able to know about it.