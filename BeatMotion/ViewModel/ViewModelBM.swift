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
    
    var isPlaying: Bool{
        theModel.isPlaying
    }
    
    var bpm: Int{
        theModel.bpm
    }    
    
    var nextTrackId: String{
        theModel.nextTrackId
    }
    
    var currentlyPlayingTrack: SpotifyApi.Currently{
        theModel.currentlyPlayingTrack
    }
    
    func updateLoginUrl(){
        codeChallenge = SpotifyAuth.generateCodeChallenge()
        loginURL = SpotifyAuth.getLoginURL(codeChallenge: codeChallenge!)
    }
    
    
    func extractTokenfronUrl(urlString: String){
        print("stringurl: \(urlString)")
        let range = urlString.range(of: "https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_CMYK_Green.png#access_token=")
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

    func fetchCurrentlyPlayingTrack() async {
        do {
            let currentlyPlaying = try await SpotifyApi.getCurrentlyPlayingTrack(tokenString: tokenString)
            theModel.setCurrentlyPlayingTrack(track: currentlyPlaying)
        } catch {
            print("Error fetching currentlyPlayingTrack: \(error)")
        }
    }

    func startPlayback() async {
        workoutManager.startWorkout()
        do{
            try await theModel.setIsPlaying(SpotifyApi.getCurrentlyPlayingTrack(tokenString: tokenString).is_playing)
        } catch{
            print("Not able to start Playback")
        }
        
        do{
                
                try await SpotifyApi.startPlayback(tokenString: tokenString, deviceId: "", isPlaying: isPlaying)
            theModel.togglePlay()
            print("PLAY!")
        } catch{
            print("Playback not working")
        }
    }
    
    func forwardPlayback() async {
        do {
            let trackUrl = try await SpotifyApi.getRecommendations(tokenString: tokenString, bpm: bpm)
            try await SpotifyApi.addItemToPlaybackQueue(tokenString: tokenString, trackUrl: trackUrl)
            print("PLAY!")

            // Use withThrowingTaskGroup to await the completion of all asynchronous operations
            try await withThrowingTaskGroup(of: Void.self) { group in

                // Forward playback
                try await group.addTask {
                    try await SpotifyApi.forward(tokenString: self.tokenString)
                    print("Forward!")
                }

                // Fetch currently playing track after forward playback is complete
                try await group.addTask {
                    do {
                        let currentlyPlaying = try await SpotifyApi.getCurrentlyPlayingTrack(tokenString: self.tokenString)
                        self.theModel.setCurrentlyPlayingTrack(track: currentlyPlaying)
                    } catch {
                        print("Error fetching currentlyPlayingTrack: \(error)")
                    }
                }

                // Wait for both tasks to complete
                for try await _ in group { }

            }
        } catch {
            print("Error in forwardPlayback: \(error)")
        }
    }

    
    func startPlaybackInFirstAvailableDevice() async {
        workoutManager.startWorkout()
        do{
            try await theModel.setIsPlaying(SpotifyApi.getCurrentlyPlayingTrack(tokenString: tokenString).is_playing)
        } catch{
            print("Not able to start Playback")
        }
        do {
            guard let deviceId = try await SpotifyApi.getDevices(tokenString: tokenString).devices.first?.id else { return}
            
            do{
                try await SpotifyApi.startPlayback(tokenString: tokenString, deviceId: deviceId, isPlaying: isPlaying)
                theModel.togglePlay()
                print("PLAY!")
            } catch{
                print("Playback not working")
            }
            
            
        } catch {
            print("Error fetching Devices: \(error)")
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
