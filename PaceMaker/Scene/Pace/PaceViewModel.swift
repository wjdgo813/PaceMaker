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
        let distance: Observable<String>
        let doNotWalking    : Observable<Void>
        let isCurrentRunning: Observable<Void>
        let runningTimer   : Observable<String>
        let walkingTimer   : Observable<String>
        let pace           : Observable<String>
        let pacePerKm      : Observable<Double>
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
    private var totalPace = [Double]()
    
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
        let pacePerKm = PublishRelay<Double>()

        let updateLocation = self.locationManager.rx
            .updateLocations
            .filter { $0.horizontalAccuracy < 40 }
        
        updateLocation
            .withLatestFrom(self.locations) { ($0,$1) }
            .delay(.microseconds(300), scheduler: MainScheduler.instance)
            .map { (newLocation, oldLocations) -> [CLLocation] in
                var locations = oldLocations
                locations.append(newLocation)
                return locations
            }
            .bind(to: self.locations)
            .disposed(by: self.disposeBag)
        
        let distance = updateLocation
            .withLatestFrom(self.locations) { ($0,$1) }
            .map { (newLocation, oldLocations) -> Double in
                guard let last = oldLocations.last else { return 0.0 }
                return last.distance(from: newLocation)
            }.withLatestFrom(self.activityState) { ($0,$1) }.debug("jhh")
//            .filter { $1  != .stationary }
            .map { $0.0 }
        
        //pace 공식: 전체 시간(seconds) / 전체 거리(km)
        let pace = updateLocation
            .withLatestFrom(self.totalDistance) { ($0,$1) }
            .map { [weak self] (newLocation, totalDistance) -> String in
                guard let self = self, self.timeCount > 0, totalDistance > 0.0 else { return "0:00" }
                let pace = Double(self.timeCount) / (totalDistance/1000)
                if (Double(totalDistance.toKiloMeter()) ?? 0.0).truncatingRemainder(dividingBy: 1.0) == 0 {
                    pacePerKm.accept(pace)
                }
                return Int(pace).toSeconds()
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
                return self.startTrackingActivityType().unwrap().debug("startTrackingActivityType")
            }.bind(to: self.activityState)
            .disposed(by: disposeBag)
        
        self.activityState
            .debug("activityState")
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
            }.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.timeCount += 1
                return self.timeCount
            }
            .debug("runningTimer").share()
        
        let walkingTimer = input.runningTimer
            .flatMap { [weak self] isPlaying -> Observable<(Bool,Bool)> in
                guard let self = self else { return .empty() }
                return self.isRunning.map { (isPlaying,$0) }
            }
            .flatMapLatest { (isPlaying,isRunning) in
                (isPlaying == true && isRunning == false) ? Observable<Int>
                    .interval(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background)).map { _ in true } : .empty()
            }.map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.walkingTime += 1
                return self.walkingTime
            }.share().debug("walkingTimer")
        
        let differWalkingTime = self.isRunning
            .distinctUntilChanged()
            .flatMap { isRunning in input.runningTimer.map { (isRunning,$0) } }
            .flatMapLatest { (isWalking, isPlaying) in
                (isPlaying == true && isWalking == false) ? Observable<Int>
                    .interval(.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background)) : .empty()
            }.debug("differ walkingTime")
            .withLatestFrom(input.tracking) {($0,$1)}.share()
            
        let doNotWalking = differWalkingTime.filter { currentWalkingTime, limitedWalkingTime in
            currentWalkingTime > (limitedWalkingTime * 60)
        }.mapToVoid()
        
        let isCurrentRunning = self.isRunning.filter { $0 }.mapToVoid()
        
        return Output(activity: self.activityState.asObservable().share(),
                      distance: self.totalDistance.map{ $0.toKiloMeter() }.asObservable(),
                      doNotWalking: doNotWalking,
                      isCurrentRunning: isCurrentRunning,
                      runningTimer: runningTimer.map { $0.toMinutes() },
                      walkingTimer: walkingTimer.map { $0.toMinutes() },
                      pace: pace.map { String($0) },
                      pacePerKm: pacePerKm.asObservable())
    }
}

extension PaceViewModel {
    private func setLocationManager() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    private func startTrackingActivityType() -> Observable<ActivityState?> {
        return Observable<ActivityState?>.create { [weak self] (observer) -> Disposable in
            guard CMMotionActivityManager.isActivityAvailable(), let self = self else { return Disposables.create() }
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
