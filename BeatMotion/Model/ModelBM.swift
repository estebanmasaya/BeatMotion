//
//  ModelBM.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation

struct ModelBM{
    private (set) var bpm = 90
    private (set) var nextTrackId : String = ""
    private (set) var currentlyPlayingTrack: SpotifyApi.Currently = SpotifyApi.Currently()
    private (set) var isPlaying = false

    
    mutating func setNextTrack(trackId: String){
        nextTrackId = trackId;
    }
    
    mutating func updateBPM(to newValue: Int) {
        bpm = newValue
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
    
}
