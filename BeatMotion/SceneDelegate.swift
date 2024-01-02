//
//  SceneDelegate.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation
import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
      print("connected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
      print("disconnected")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
      print("failed")
    }
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
      print("player state changed")
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let parameters = SPTManager.shared.appRemote.authorizationParameters(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Show the error
        }
    }


    
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        print("SceneDelegate is connected!")
    }
    
    

    func sceneDidDisconnect(_ scene: UIScene) {
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
      
    }

    func sceneWillResignActive(_ scene: UIScene) {
      
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
      
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
      
    }
    
    
    
    
}


