//
//  PaceViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/08.
//

import UIKit
import CoreMotion
import CoreLocation

import RxSwift
import RxCocoa

enum ActivityState {
    case stationary
    case running
}

class PaceViewController: UIViewController {
    private let manager = CMMotionActivityManager()
    private let activityState = BehaviorRelay<ActivityState>(value: .stationary)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupUI() {
        
    }
    
    private func setBind() {
        
    }
}

/*
 private func startTrackingActivityType() {
     guard CMMotionActivityManager.isActivityAvailable() else { return }
     manager.startActivityUpdates(to: OperationQueue.main) {
         [weak self] (activity: CMMotionActivity?) in
         
         guard let activity = activity else { return }
         DispatchQueue.main.async {
             if activity.walking {
                 self?.state.text = "Walking"
             } else if activity.stationary {
                 self?.state.text = "Stationary"
             } else if activity.running {
                 self?.state.text = "Running"
             } else if activity.automotive {
                 self?.state.text = "Automotive"
             }
         }
     }
 }
 */
