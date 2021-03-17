//
//  CLLocationDelegateProxy.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/17.
//
import CoreLocation
import RxSwift
import RxCocoa

class RxCLLocationDelegateProxy:DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType {
    static func registerKnownImplementations() {
        self.register { manager -> RxCLLocationDelegateProxy in
            RxCLLocationDelegateProxy(parentObject: manager, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
        object.delegate = delegate
    }
}

extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationDelegateProxy.proxy(for: self.base)
    }
    
    var updateLocations: Observable<CLLocation> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))).map { $0.first! as! CLLocation }
    }
}

extension ObservableType where Element: CLLocation {
    func distance(from fLocation: Self.Element, to tLocation: Self.Element) -> Observable<CLLocationDistance>  {
        return Observable<CLLocationDistance>.create { observer -> Disposable in
            observer.onNext(tLocation.distance(from: fLocation))
            observer.onCompleted()
            return Disposables.create { }
        }
    }
}
