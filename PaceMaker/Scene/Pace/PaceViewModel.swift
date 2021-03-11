//
//  PaceViewModel.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/09.
//

import UIKit
import CoreMotion

import RxSwift
import RxCocoa

class PaceViewModel {
    struct Input {
        let tracking: Observable<Void>
        let runningTimer: Observable<Bool>
    }
    
    struct Output {
        let activity: Observable<ActivityState>
        let timer   : Observable<Int>
    }
    
    private let manager   = CMMotionActivityManager()
    private var timeCount = 0
    private let activityState = BehaviorRelay<ActivityState>(value: .stationary)
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.tracking
            .flatMap { [weak self] _ -> Observable<ActivityState> in
                guard let self = self else { return .empty() }
                return self.startTrackingActivityType().unwrap()
            }.bind(to: self.activityState)
            .disposed(by: disposeBag)
        
        let timer = input.runningTimer
            .flatMapLatest { isRunning in
                isRunning ? Observable<Int>
                    .interval(.seconds(1), scheduler: MainScheduler.instance).map { _ in true } : .empty()
            }.map { [weak self] countable -> Int in
                guard let self = self else { return 0 }
                self.timeCount += 1
                return self.timeCount
            }
          
        return Output(activity: self.activityState.asObservable(),
                      timer: timer)
    }
}

extension PaceViewModel {
    private func startTrackingActivityType() -> Observable<ActivityState?> {
        return Observable<ActivityState?>.create { (observer) -> Disposable in
            guard CMMotionActivityManager.isActivityAvailable() else { return Disposables.create() }
            self.manager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
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
