//
//  PaceDataManager+Rx.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import RxSwift
import RxCocoa

extension PaceDataManager {
    
    func save(record: Record) -> Observable<Record> {
        return Observable.create { observer in
            PaceDataManager.shared.save(runDate: record.date,
                                        distance: record.distance,
                                        duration: Int64(record.duration),
                                        walking: Int64(record.walking),
                                        pace: record.pace) { (finished) in
                observer.onNext(record)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func query(runDate: Date) -> Observable<[Pace]> {
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
