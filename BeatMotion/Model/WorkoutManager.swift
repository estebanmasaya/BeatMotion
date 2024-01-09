//
//  WOrkoutManager.swift
//  BeatMotion
//
//  Created by Niklas Roslund on 2024-01-07.
//

import Foundation
import CoreMotion

protocol WorkoutManagerDelegate: AnyObject {
    func didUpdateStepsPerMinute(_ stepsPerMinute: Double)
}

class WorkoutManager {
    weak var delegate: WorkoutManagerDelegate?
    private let pedometer = CMPedometer()

    func startWorkout() {
        // Check if step counting is available
        
        if CMPedometer.isStepCountingAvailable() {
            print("Starting pedometer updates...")
            // Start receiving updates
            pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
                if let error = error {
                    print("Pedometer error: \(error.localizedDescription)")
                    return
                }
                if let data = pedometerData {
                    // Calculate steps per minute
                    let steps = data.numberOfSteps.doubleValue
                    let duration = data.endDate.timeIntervalSince(data.startDate) / 60 // Duration in minutes
                    let stepsPerMinute = duration > 0 ? steps / duration : 0
                    print("Steps: \(steps), Duration: \(duration) minutes, Steps per minute: \(stepsPerMinute)")
                    
                    
                    self?.delegate?.didUpdateStepsPerMinute(stepsPerMinute)
                    
                }
            }
        } else {
            print("Step counting not available")
        }
    }

    func endWorkout() {
        // Stop pedometer updates
        pedometer.stopUpdates()
    }
}
