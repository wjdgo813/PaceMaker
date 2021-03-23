//
//  PaceDataManager+Rx.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import RxSwift
import RxCocoa

extension Reactive where Base: PaceDataManager {
    
    func save(runDate: Date,
              distance: Double,
              duration: Int64,
              walking: Int64,
              pace: String) -> Observable<Void> {
        return Observable.create { observer in
            PaceDataManager.shared.save(runDate: runDate,
                                        distance: distance,
                                        duration: duration,
                                        walking: walking,
                                        pace: pace) { (finished) in
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func query(_ runDate: Date) -> Observable<[Pace]> {
        return Observable.create { observer in
            let paces = PaceDataManager.shared.query(runDate)
            observer.onNext(paces)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func deletePace(id: Int64) -> Observable<Void> {
        return Observable.create { observer in
            PaceDataManager.shared.deletePace(id: id) { (finished) in
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
