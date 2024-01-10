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
            
            // Define the update interval (e.g., every 10 seconds)
            let updateInterval = 10.0 // seconds

            // Store the last update time and step count
            var lastUpdateTime = Date()
            var lastStepCount = 0.0

            // Start receiving updates
            pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
                if let error = error {
                    print("Pedometer error: \(error.localizedDescription)")
                    return
                }

                if let data = pedometerData {
                    let now = Date()
                    let steps = data.numberOfSteps.doubleValue
                    let duration = now.timeIntervalSince(lastUpdateTime) / 60 // Duration in minutes

                    // Calculate steps since last update
                    let stepsSinceLastUpdate = steps - lastStepCount

                    // Update steps per minute based on recent activity
                    let stepsPerMinute = duration > 0 ? stepsSinceLastUpdate / duration : 0

                    //print("Recent Steps: \(stepsSinceLastUpdate), Recent Duration: \(duration) minutes, Recent Steps per minute: \(stepsPerMinute)")

                    // Update last update time and step count
                    lastUpdateTime = now
                    lastStepCount = steps

                    self?.delegate?.didUpdateStepsPerMinute(stepsPerMinute)
                }
            }
        } else {
            print("Step counting not available")
        }
    }

    func endWorkout() {
        print("stopping pedometer updates")
        // Stop pedometer updates
        pedometer.stopUpdates()
    }
}
