//
//  SpotifyConstants.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation

enum SpotifyConstants{
    static let apiHost = "api.spotify.com"
    static let clientId = "63e605058e294f4e86f97cf2b7664d4d"
    static let redirectUri = "https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_CMYK_Green.png"
    static let authorizationEndpoint = "accounts.spotify.com"
    static let tokenEndpoint = "https://accounts.spotify.com/api/token"
    static let scope = "user-modify-playback-state user-read-playback-state user-read-currently-playing"
    static let response_type = "token"
    static let codeChallengeMethod = "S256"
    
    static var authParams = [
        "response_type": response_type,
        "client_id" : clientId,
        "redirect_uri": redirectUri,
        "scope": scope,
        //"code_challenge_method": codeChallengeMethod,
    ]
    
}


