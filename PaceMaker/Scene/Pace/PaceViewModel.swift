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
        let pacePerKms      : Observable<[Double]>
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
    private var oneKMPaces = [Double]()
    private var bufferLocations = [CLLocation]()
    
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
        let totalPacePerKms = BehaviorRelay<[Double]>(value: [Double]())

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
            .filter { $1  != .stationary }
            .map { $0.0 }
        
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
            }
            .map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.timeCount += 1
                return self.timeCount
            }.observeOn(MainScheduler.instance)
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
        
        //pace ??????: ?????? ??????(seconds) / ?????? ??????(km)
        let pace = runningTimer
            .withLatestFrom(Observable.combineLatest(self.locations, self.totalDistance, updateLocation) { ($0,$1,$2) }) { ($0, $1.0, $1.1, $1.2) }
            .do(onNext: { [weak self] (_, _, _, newLocation) in
                self?.bufferLocations.append(newLocation)
            })
            .filter { $0.0 % 3 == 0 }
            .map { [weak self] (seconds, oldLocations, totalDistance, newLocation) -> String in
                guard let self = self,
                      let last = oldLocations.last,
                      self.timeCount > 0,
                      totalDistance > 0.0,
                      let firstLocation = self.bufferLocations.first,
                      let lastLocation = self.bufferLocations.last else { return "0:00" }
                let time = lastLocation.timestamp.timeIntervalSince(firstLocation.timestamp)
                let distance = lastLocation.distance(from: firstLocation)
                let total = totalDistance.toKiloMeter()

                self.bufferLocations.removeAll()
                
                var pace = 0.0
                if distance > 0.0 {
                    pace = time / (distance/1000)
                }
                
                print("pace: \(pace)")
                if total.truncatingRemainder(dividingBy: 1.0) == 0 {
                    let count = total / 1
                    if Int(count) != totalPacePerKms.value.count {
                        let averagePace = self.oneKMPaces.reduce(0.0) { return $0 + $1 / Double(self.oneKMPaces.count) }
                        
                        self.oneKMPaces.removeAll()
                        var val = totalPacePerKms.value
                        val.append(averagePace)
                        totalPacePerKms.accept(val)
                    }
                }
                
                self.oneKMPaces.append(pace)
                return Int(pace).toSeconds()
            }
        
        return Output(activity: self.activityState.asObservable().share(),
                      distance: self.totalDistance.debug("totalDistance").map{ $0.toKiloMeter() }.map{ "\($0)" }.asObservable(),
                      doNotWalking: doNotWalking,
                      isCurrentRunning: isCurrentRunning,
                      runningTimer: runningTimer.map { $0.toMinutes() },
                      walkingTimer: walkingTimer.map { $0.toMinutes() },
                      pace: pace.map { String($0) }.share(),
                      pacePerKms: totalPacePerKms.asObservable().debug("jhh totalPacePerKms"))
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
