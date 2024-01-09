//
//  ModelBM.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-02.
//

import Foundation

struct ModelBM{
    private (set) var bpm = 90
    
    mutating func updateBPM(to newValue: Int) {
        bpm = newValue
    }
    
}
