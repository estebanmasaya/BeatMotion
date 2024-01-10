//
//  ModelBM.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation

protocol ModelBMDelegate: AnyObject {
    func notifyToFetchNewRecomendation()
}

struct ModelBM{
    private(set) var bpm = 90
    private var recentBPMs: [Int] = []
    private let thresholdPercentage: Double = 10.0
    private let windowSize: Int = 10  // Size of the rolling window
    private (set) var nextTrackId : String = ""
    private (set) var message : String = ""

    private (set) var currentlyPlayingTrack: SpotifyApi.Currently = SpotifyApi.Currently()
    private (set) var isPlaying = false

    weak var delegate: ModelBMDelegate?
    
    var baselineBPM: Int {
        guard !recentBPMs.isEmpty else { return 90 }
        return recentBPMs.reduce(0, +) / recentBPMs.count
    }
    
    mutating func setMessage(message: String) {
        self.message = message
    }
    
    
    mutating func setNextTrack(trackId: String){
        nextTrackId = trackId;
    }
    
    mutating func updateBPM(to newValue: Int) {
        // Add new value and ensure the array size stays within the window size
        recentBPMs.append(newValue)
        if recentBPMs.count > windowSize {
            recentBPMs.removeFirst()
        }

        let changePercentage = calculateChangePercentage(from: baselineBPM, to: newValue)

        if changePercentage > thresholdPercentage {
            // Trigger your action here
            print("Change exceeds 10% threshold")
            message = "Running Faster? We choose the right track for you!"
            self.delegate?.notifyToFetchNewRecomendation()
        }

        bpm = baselineBPM
    }
    

    mutating func togglePlay(){
        isPlaying.toggle()
    }
    
    mutating func setIsPlaying(_ isIt: Bool){
        isPlaying = isIt
    }
    
    mutating func setCurrentlyPlayingTrack(track: SpotifyApi.Currently){
        currentlyPlayingTrack = track
    }
    
    private func calculateChangePercentage(from oldValue: Int, to newValue: Int) -> Double {
        if oldValue == 0 { return 100.0 } // Prevent division by zero
        let change = Double(abs(newValue - oldValue))
        return (change / Double(oldValue)) * 100.0
    }
}
