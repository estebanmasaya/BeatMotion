//
//  ViewModelBM.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation

class ViewModelBM: ObservableObject, WorkoutManagerDelegate, ModelBMDelegate{
    @Published var theModel: ModelBM
    @Published var loginURL: URLRequest?
    @Published var userAgreed = false
    private var tokenString = ""
    private var workoutManager = WorkoutManager()
    @Published var codeVerifier : String?
    @Published var hashed : Data?
    @Published var codeChallenge : String?
    private var timer: Timer?
    
    var isPlaying: Bool{
        theModel.isPlaying
    }
    @Published var sliderValue: Double = 90
    
    var bpm: Int{
        theModel.bpm
    }

    var message: String{
        theModel.message
    }
    
    var nextTrackId: String{
        theModel.nextTrackId
    }
    
    var currentlyPlayingTrack: SpotifyApi.Currently{
        theModel.currentlyPlayingTrack
        
    }
        
    init() {
        theModel = ModelBM()
        workoutManager.delegate = self
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
    
    func fetchCurrentlyPlayingTrackWithTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            DispatchQueue.main.async {
                Task {
                    do {
                        let currentlyPlaying = try await SpotifyApi.getCurrentlyPlayingTrack(tokenString: self.tokenString)
                        self.theModel.setCurrentlyPlayingTrack(track: currentlyPlaying)
                        
                        if self.calculateRemainingTime()<3000{
                            do {
                                let songs = try await SpotifyApi.getRecommendations(tokenString: self.tokenString, bpm: self.bpm)
                                //print(songs)
                            } catch {
                                print("Error fetching recommendations: \(error)")
                            }
                        }
                        
                        
                    } catch {
                        print("Error fetching currentlyPlayingTrack: \(error)")
                    }
                }
            }
        }
    }

    func calculateRemainingTime() -> Int {
        return theModel.currentlyPlayingTrack.item.duration_ms - theModel.currentlyPlayingTrack.progress_ms
        
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        
    }
    
    func millisecondsToMinutesSeconds(milliseconds: Int) -> String {
            let totalSeconds = milliseconds / 1000
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return "\(minutes):\(String(format: "%02d", seconds))"
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
                sleep(2)
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
    
    func endWorkout() {
        workoutManager.endWorkout()
    }
    
    func startWorkout() {
        workoutManager.startWorkout()
    }
    
    func notifyToFetchNewRecomendation() {
        Task {
            await fetchRecommendations()
        }
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false){ timer in
            DispatchQueue.main.async {
                print("Erase")
                self.theModel.setMessage(message: "")
            }
            
        }
    }
    
    func setBpm(_ value: Double) {
        theModel.updateBPM(to: Int(value))
    }
}
