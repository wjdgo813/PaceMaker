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
        let tracking: Observable<Int>
        let runningTimer: Observable<Bool>
    }
    
    struct Output {
        let activity: Observable<ActivityState>
        let distance: Observable<Double>
        let doNotWalking   : Observable<Void>
        let runningTimer   : Observable<Int>
        let walkingTimer   : Observable<Int>
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.activityType = .fitness
        manager.distanceFilter = kCLDistanceFilterNone
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    private var timeCount   = 0
    private var walkingTime = 0
    private var limitedWalkingTime = 0
    
    private let motionManager = CMMotionActivityManager()
    private let locations     = BehaviorRelay<[CLLocation]>(value: [])
    private let totalDistance = BehaviorRelay<Double>(value: 0.0)
    private let activityState = BehaviorRelay<ActivityState>(value: .stationary)
    private let isRunning     = BehaviorRelay<Bool>(value: true)
    private let disposeBag    = DisposeBag()
    
    init() {
        self.setLocationManager()
    }
    
    func transform(input: Input) -> Output {

        self.locationManager.rx
            .updateLocations
            .withLatestFrom(self.locations) { ($0,$1) }
            .delay(.microseconds(300), scheduler: MainScheduler.instance)
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
                return self.startTrackingActivityType().unwrap().debug("jhh startTrackingActivityType")
            }.bind(to: self.activityState)
            .disposed(by: disposeBag)
        
        self.activityState
            .debug("jhh activityState")
            .map { state -> Bool in
                if state == .running {
                    return true
                } else {
                    return false
                }
            }.bind(to: self.isRunning)
            .disposed(by: self.disposeBag)
        
        let runningTimer = input.runningTimer
            .flatMapLatest { isPlaying in
                isPlaying ? Observable<Int>
                    .interval(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background)).map { _ in true } : .empty()
            }.observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .debug("jhh runningTimer").map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.timeCount += 1
                return self.timeCount
            }
        
        let walkingTimer = input.runningTimer
            .flatMap { isPlaying in self.isRunning.map { (isPlaying,$0) } }
            .flatMapLatest { (isPlaying,isRunning) in
                (isPlaying == true && isRunning == false) ? Observable<Int>
                    .interval(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background)).map { _ in true } : .empty()
            }.map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.walkingTime += 1
                return self.walkingTime
            }
        
        let doNotWalking = self.isRunning
            .flatMapLatest { isWalking in
                isWalking == false ? Observable<Int>
                    .interval(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background)) : .empty()
            }
            .withLatestFrom(input.tracking) {($0,$1)}
            .filter { currentWalkingTime, limitedWalkingTime in
                currentWalkingTime > (limitedWalkingTime * 60)
            }
            .mapToVoid()
        
        return Output(activity: self.activityState.asObservable().share(),
                      distance: self.totalDistance.asObservable(),
                      doNotWalking: doNotWalking,
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
                    } else if activity.stationary {
                        observer.onNext(.stationary)
                    } else if activity.running || activity.automotive {
                        observer.onNext(.running)
                    }
                }
            }
            
            return Disposables.create()
        }.share()
    }
}


//MARK: Calculator Pace
extension PaceViewModel {
    private func paceInSeconds (minutes:Double, seconds: Double, distance: Double) -> Double {
        return ((minutes*60) + seconds) / distance
    }
}
