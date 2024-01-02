//
//  SPTConfiguration.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation

class SPTManager{
    
    let SpotifyClientID = "a8344015f4a04364bb7832db7499ae3d"
    let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!

    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    
    
    lazy var appRemote: SPTAppRemote = {
      let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
      appRemote.connectionParameters.accessToken = self.accessToken
      appRemote.delegate = self
      return appRemote
    }()

}


