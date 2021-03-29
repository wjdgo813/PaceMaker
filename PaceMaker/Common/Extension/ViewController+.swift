//
//  ViewController+.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/09.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    ///Wrapper For DriverUtility
    public struct DriverUtility {
        public let base: UIViewController
    }
    
    ///Wrapper NameSpace Accessor
    public var driverUtility: DriverUtility {
        get { return DriverUtility(base: self) }
        set { }
    }
}

extension UIViewController.DriverUtility {
    public func signalViewWillAppear() -> Observable<Void> {
        return base.rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:))).take(until: base.rx.deallocated).map { _ in }
    }
    
    public func signalViewDidAppear() -> Observable<Void> {
        return base.rx.methodInvoked(#selector(UIViewController.viewDidAppear(_:))).take(until: base.rx.deallocated).map { _ in }
    }
    
    public func signalViewWillDisappear() -> Observable<Void> {
        return base.rx.methodInvoked(#selector(UIViewController.viewWillDisappear(_:))).take(until: base.rx.deallocated).map { _ in }
    }
    
    public func signalViewDidDisappear() -> Observable<Void> {
        return base.rx.methodInvoked(#selector(UIViewController.viewDidDisappear(_:))).take(until: base.rx.deallocated).map { _ in }
    }
    
    public func signalViewWillLayoutSubviews() -> Observable<Void> {
        return base.rx.methodInvoked(#selector(UIViewController.viewWillLayoutSubviews)).take(until: base.rx.deallocated).map { _ in }
    }
    
    public func signalViewDidLayoutSubviews() -> Observable<Void> {
        return base.rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews)).take(until: base.rx.deallocated).map { _ in }
    }
    
    public func setStatusBarColorBlack(black: Bool) {
        _ = signalViewWillAppear()            .do(onNext: { () in UIApplication.shared.setStatusBarStyle(black ? .default : .lightContent, animated: true) })
            .subscribe()
    }
    
    public func guardNoPresenter() -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            if let _ = self.base.presentedViewController {
                self.base.dismiss(animated: false, completion: {
                    observer.onNext(())
                })
            } else {
                observer.onNext(())
            }
            return Disposables.create()
            }.take(1)
    }
}

