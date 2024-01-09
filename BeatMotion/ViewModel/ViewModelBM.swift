//
//  ViewModelBM.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation

class ViewModelBM: ObservableObject, WorkoutManagerDelegate{
    @Published private var theModel: ModelBM
    @Published var loginURL: URLRequest?
    @Published var userAgreed = false
    private var tokenString = ""
    private var workoutManager = WorkoutManager()
    
    init() {
        theModel = ModelBM()
        workoutManager.delegate = self
        workoutManager.startWorkout()
    }
  
    @Published var codeVerifier : String?
    @Published var hashed : Data?
    @Published var codeChallenge : String?
    var bpm: Int{
        theModel.bpm
    }
    
    func updateLoginUrl(){
        codeChallenge = SpotifyAuth.generateCodeChallenge()
        loginURL = SpotifyAuth.getLoginURL(codeChallenge: codeChallenge!)
    }
    
    func extractTokenfronUrl(urlString: String){
        let range = urlString.range(of: "https://www.google.com/#access_token=")
        guard let index = range?.upperBound else {return}
        tokenString = String(urlString[index...])
        if !tokenString.isEmpty{
            let range = tokenString.range(of: "token_type=Bearer")
            guard let index = range?.lowerBound else {return}
            tokenString = String(tokenString[..<index])
            print(tokenString)
        }
        
        
    }
    
    func chooseNextTrack() async {
        do {
            let trackUrl = try await SpotifyApi.getRecommendations(tokenString: tokenString, bpm: bpm)
            do{
                try await SpotifyApi.addItemToPlaybackQueue(tokenString: tokenString, trackUrl: trackUrl)
                print("PLAY!")
            } catch{
                print("Playback not working")
            }
        } catch {
            print("Error fetching recommendations: \(error)")
        }
    }
    
    func fetchRecommendations() async {
        do {
            let songs = try await SpotifyApi.getRecommendations(tokenString: tokenString, bpm: bpm)
            print(songs)
        } catch {
            print("Error fetching recommendations: \(error)")
        }
    }
    
    func startPlayback() async {
        workoutManager.startWorkout()
        do{
            try await SpotifyApi.startPlayback(tokenString: tokenString)
            print("PLAY!")
        } catch{
            print("Playback not working")
        }  
    }

    func addItemToPlaybackQueue(trackUrl: String) async {
        do{
            try await SpotifyApi.addItemToPlaybackQueue(tokenString: tokenString, trackUrl: trackUrl)
            print("PLAY!")
        } catch{
            print("Playback not working")
        }
    }
    
    func didUpdateStepsPerMinute(_ stepsPerMinute: Double) {
        print("stepsPerMinute + \(stepsPerMinute)")
        DispatchQueue.main.async {
            self.theModel.updateBPM(to: Int(stepsPerMinute))
        }
    }
    
}
