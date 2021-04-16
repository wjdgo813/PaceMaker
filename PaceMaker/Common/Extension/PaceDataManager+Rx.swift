//
//  PaceDataManager+Rx.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import RxSwift
import RxCocoa

extension PaceDataManager {
    
    func rxSave(record: Record) -> Observable<Record> {
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
    
    func rxQuery(yearMonth: String) -> Observable<[Pace]> {
        return Observable.create { observer in
            let paces = PaceDataManager.shared.query(yearMonth: yearMonth)
            observer.onNext(paces)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func rxQuery() -> Observable<[Pace]> {
        return Observable.create { observer in
            let paces = PaceDataManager.shared.query()
            observer.onNext(paces)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func rxDeletePace(id: Int64) -> Observable<Void> {
        return Observable.create { observer in
            PaceDataManager.shared.deletePace(id: id) { (finished) in
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
