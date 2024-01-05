//
//  SpotifyAuth.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation
import CryptoKit
import CommonCrypto



class SpotifyAuth{
    
    
    static func getLoginURL(codeChallenge: String) -> URLRequest?{
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyConstants.authorizationEndpoint
        components.path = "/authorize"
        
        components.queryItems = SpotifyConstants.authParams.map({URLQueryItem(name: $0, value: $1)})
        //components.queryItems?.append(URLQueryItem(name: "code_challenge", value: codeChallenge))
        guard let url = components.url else {return nil}
        print(url)
        print(URLRequest(url: url))
        return URLRequest(url: url)
    }
    
    
    static func generateCodeChallenge() -> String{
        let codeVerifier = SpotifyAuth.generateRandomString(length: 64)
        let hashed = SpotifyAuth.sha256(plain: codeVerifier)
        let codeChallenge = SpotifyAuth.base64encode(input: hashed)
        print("codeChallenge: \(codeChallenge)")
        return codeChallenge
    }
    
    
    static func generateRandomString(length: Int) -> String {
        let possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        var randomString = ""

        for _ in 0..<length {
            let randomIndex = Int(arc4random_uniform(UInt32(possible.count)))
            randomString.append(possible[possible.index(possible.startIndex, offsetBy: randomIndex)])
        }

        return randomString
    }
    
    static func sha256(plain: String) -> Data {
        if let data = plain.data(using: .utf8) {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
            }
            return Data(digest)
        }
        return Data()
    }
    
    static func base64encode(input: Data) -> String {
        let base64String = input.base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
        return base64String
    }
    
    
    
    
    
    
}
