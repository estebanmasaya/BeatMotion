//
//  BeatMotionApp.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2023-12-20.
//

import SwiftUI

@main
struct BeatMotionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ViewModelBM()).onOpenURL { url in
                print("Si se trigguea!")
                if url.scheme == "beat-motion-app-login" && url.host == "callback" {
                    // Handle the redirect URL here
                    print("Received callback: \(url)")

                    // Perform actions based on the URL
                    // For example, navigate to a specific view or trigger some logic
                }
            }
        }
    }
}
