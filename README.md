# INJI-OpenID4Vp-ios-swift
- Implementation of OpenID4VP protocols in Swift.

## Features
- Process the Authorization Request of the verifier received from the Wallet.
- Validate and return the valid Presentation Definition or scope to the wallet.
- Receives the list of verifiable credentials from the wallet.
- Constructs the verifiable presentation and send it to wallet for proof generation.
- Receives the signed Verifiable presentation and sends a POST request to the URL specified in the verifier request.

## Installation
- Clone the repo
- In your swift application go to file > add package dependency > add the  https://github.com/mosip/inji-openid4vp-ios-swift.git in git search bar> add package
- Import the library and use

## APIs

### authenticateVerifier
 - Receives a base64 Encoded request of the verifier and returns a valid Presentation Definition or Scope as response.
This function takes an encoded authentication request and a JSON array of trusted verifiers.
 - Returns the Authentication response which contain either validated Presentation Definition or Scope based on the request given.



```
    let response = try authenticateVerifier(encodedAuthenticationRequest: String, trustedVerifierJSON: [Verifier])
```

###### Parameters

| Name                         | Type       | Description                                                 | Sample                                              |
|------------------------------|------------|-------------------------------------------------------------|-----------------------------------------------------|
| encodedAuthenticationRequest | String     | Base64 Encoded authorization request.                       | `"T1BFTklENFZQOi8vYXV0"`                            |
| trustedVerifierJSON          | [Verifier] | Array of verifiers to verify the client id of the verifier. | `Verifier(clientId: String, redirectUri: [String])` |


###### Exceptions

1. AuthorizationRequestException is thrown when the request contains missing or invalid inputs.
2. VerifierVerificationException is thrown when the verifier is not a trusted one or if it is invalid.


### constructVerifiablePresentation
- This function takes a map of credentials and returns a verifiable presentation as a String for signing.
- Returns Json string back with verifiable presentation created using the credentials received without proof field.

```
    let response = try openId4Vp.constructVerifiablePresentation(credentialsMap: [String: [String]])
```

###### Parameters

| Name                | Type             | Description                                                                                              | Sample                                            |
|---------------------|------------------|----------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| credentialsMap      | [String: [String]] | Contains the input descriptor id as key and corresponding matching Verifiable Credentials as array of string. | `["bank_input":["VC1","VC2"]]`                            |


###### Exceptions

1. AuthorizationResponseException is thrown when the verifiable presentation creation failed.

### shareVerifiablePresentation
- This function takes VPResponseMetadata type which contains the proof details which is used to construct the verifiable presentation with proof to send it to verifier as POST request.
- Returns the response with a success message back to the wallet.

```
    let response = try await openId4Vp.shareVerifiablePresentation(vpResponseMetadata: VPResponseMetadata)
```

###### Parameters

| Name                | Type             | Description                                                                                               | Sample                                            |
|---------------------|------------------|-----------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| vpResponseMetadata      |  | Contains a VPResponseMetadata which has proof details such as  jws, signatureAlgorithm, publicKey, domain | `VPResponseMetadata(jws: "jws", signatureAlgorithm: "signatureAlgoType", publicKey: "publicKey", domain: "domain")`                            |


###### Exceptions

1. AuthorizationResponseException is thrown when the verifiable presentation with proof creation is failed.
2. NetworkRequestException is thrown when the POST request to verifier failed.