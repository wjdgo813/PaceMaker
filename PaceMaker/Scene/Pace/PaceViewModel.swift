//
//  PaceViewModel.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/09.
//

import UIKit
import CoreMotion
import CoreLocation

import RxSwift
import RxCocoa

class PaceViewModel {
    struct Input {
        let tracking: Observable<Void>
        let runningTimer: Observable<Bool>
    }
    
    struct Output {
        let activity: Observable<ActivityState>
        let distance: Observable<Double>
        let runningTimer   : Observable<Int>
        let walkingTimer   : Observable<Int>
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = kCLDistanceFilterNone
        return manager
    }()
    
    private let motionManager   = CMMotionActivityManager()
    private var timeCount = 0
    private var walkingTime = 0
    private let locations = BehaviorRelay<[CLLocation]>(value: [])
    private let totalDistance = BehaviorRelay<Double>(value: 0.0)
    private let activityState = BehaviorRelay<ActivityState>(value: .stationary)
    private let isRunning = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    init() {
        self.setLocationManager()
    }
    
    func transform(input: Input) -> Output {

        self.locationManager.rx
            .updateLocations
            .withLatestFrom(self.locations) { ($0,$1) }
            .delay(.microseconds(500), scheduler: MainScheduler.instance)
            .map { (newLocation, oldLocations) -> [CLLocation] in
                var locations = oldLocations
                locations.append(newLocation)
                return locations
            }
            .bind(to: self.locations)
            .disposed(by: self.disposeBag)
        
        let distance = self.locationManager.rx
            .updateLocations
            .withLatestFrom(self.locations) { ($0,$1) }
            .map { (newLocation, oldLocations) -> Double in
                guard let last = oldLocations.last else { return 0.0 }
                return last.distance(from: newLocation)
            }
        
        distance
            .withLatestFrom(self.totalDistance) { ($0,$1) }
            .map { (distance, total) in
                return total + distance
            }
            .bind(to: self.totalDistance)
            .disposed(by: self.disposeBag)
        
        input.tracking
            .flatMap { [weak self] _ -> Observable<ActivityState> in
                guard let self = self else { return .empty() }
                return self.startTrackingActivityType().unwrap()
            }.bind(to: self.activityState)
            .disposed(by: disposeBag)
        
        self.activityState.map { state -> Bool in
            if state == .running {
                return true
            } else {
                return false
            }
        }.bind(to: self.isRunning)
        .disposed(by: self.disposeBag)
        
        let runningTimer = input.runningTimer
            .withLatestFrom(self.isRunning) { ($0,$1) }
            .flatMapLatest { isPause, isRunning in
                 isPause && isRunning ? Observable<Int>
                    .interval(.seconds(1), scheduler: MainScheduler.instance).map { _ in true } : .empty()
            }.map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.timeCount += 1
                return self.timeCount
            }
        
        let walkingTimer = input.runningTimer
            .withLatestFrom(self.isRunning){($0,$1)}
            .flatMapLatest { (isPause,isRunning) in
                isPause && isRunning == false ? Observable<Int>
                    .interval(.seconds(1), scheduler: MainScheduler.instance).map { _ in true } : .empty()
            }.map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.walkingTime += 1
                return self.walkingTime
            }
          
        return Output(activity: self.activityState.asObservable(),
                      distance: self.totalDistance.asObservable(),
                      runningTimer: runningTimer,
                      walkingTimer: walkingTimer)
    }
}

extension PaceViewModel {
    private func setLocationManager() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    private func startTrackingActivityType() -> Observable<ActivityState?> {
        return Observable<ActivityState?>.create { (observer) -> Disposable in
            guard CMMotionActivityManager.isActivityAvailable() else { return Disposables.create() }
            self.motionManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
                guard let activity = activity else {
                    return
                }
                
                DispatchQueue.main.async {
                    if activity.walking {
                        observer.onNext(.walking)
                        observer.onCompleted()
                    } else if activity.stationary {
                        observer.onNext(.stationary)
                        observer.onCompleted()
                    } else if activity.running || activity.automotive {
                        observer.onNext(.running)
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}


//MARK: Calculator Pace
extension PaceViewModel {
    private func paceInSeconds (minutes:Double, seconds: Double, distance: Double) -> Double {
        return ((minutes*60) + seconds) / distance
    }
}
