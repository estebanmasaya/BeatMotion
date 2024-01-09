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
    
    mutating func setNextTrack(trackId: String){
        nextTrackId = trackId;
    }
    
    
    
    
}
