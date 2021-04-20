//
//  PaceViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/08.
//

import UIKit

import RxSwift
import RxCocoa
import CoreLocation

enum ActivityState: String {
    case stationary
    case walking
    case running
}

final class PaceViewController: UIViewController, Alertable {
    
    @IBOutlet private weak var walkingBackgroundImageView: UIImageView!
    @IBOutlet private weak var runningBackgroundImageView: UIImageView!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var paceLabel: UILabel!
    @IBOutlet private weak var walkingTimeLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var walkingTItleImageView: UIImageView!
    
    private let startRunning = BehaviorRelay<Bool>(value: true)
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let viewModel = PaceViewModel()
    private let disposeBag = DisposeBag()
    var limitedWalkingTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setBind()
        self.bindUI()
    }
}

extension PaceViewController {
    
    private func setupUI() { }
    private func setBind() {
        
        let output = self.viewModel.transform(input: PaceViewModel.Input(tracking: driverUtility.signalViewDidAppear().map{ [weak self] _ in self?.limitedWalkingTime ?? 0 },
                                                                         runningTimer: startRunning.asObservable()))
        
        output.activity
            .subscribe().disposed(by: self.disposeBag)
        
        output.runningTimer
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] timer in
                self?.durationLabel.text = timer
            }).disposed(by: self.disposeBag)
        
        output.walkingTimer
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] timer in
                self?.walkingTimeLabel.text = timer
            }).disposed(by: self.disposeBag)
        
        output.distance.subscribe(onNext: { [weak self] totalDistance in
            self?.distanceLabel.text = totalDistance
        }).disposed(by: self.disposeBag)
        
        output.pace
            .subscribe(onNext: { [weak self] pace in
                self?.paceLabel.text = pace
            }).disposed(by: self.disposeBag)
        
        output.doNotWalking
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.impactGenerator.impactOccurred()
                self?.toWalkingView()
        }).disposed(by: self.disposeBag)
        
        output.isCurrentRunning
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.toRunningView()
            }).disposed(by: self.disposeBag)
        
        self.pauseButton.rx.tap
            .flatMap { [weak self] _ -> Observable<Bool> in
                return self?.showStopAlert() ?? .empty()
            }
            .filter { $0 }
            .withLatestFrom(Observable.combineLatest(output.distance.debug("combine distance"),
                                                     output.runningTimer.debug("combine runningTimer"),
                                                     output.walkingTimer.debug("combine walkingTimer"),
                                                     output.pace.startWith("0:00").debug("combine pace")) { ($0, $1, $2, $3) })
            .map { distance, duration, walking, pace in
                return Record(date: Date(),
                              distance: Double(distance) ?? 0.0,
                              duration: Int(duration) ?? 0,
                              walking: Int(walking) ?? 0,
                              pace: pace)
            }
            .flatMap { record in
                return PaceDataManager.shared.rxSave(record: record)
            }
            .subscribe(onNext: { record in
                ContainerViewController.target?.execute(scene: .result(record))
            }).disposed(by: self.disposeBag)
    }
    
    private func bindUI() {
        
        self.pauseButton.rx.tap
            .withLatestFrom(startRunning)
            .map { !$0 }
            .bind(to: self.startRunning)
            .disposed(by: self.disposeBag)
    }
}

extension PaceViewController {
    private func toWalkingView() {
        guard self.walkingBackgroundImageView.isHidden else { return }
        self.walkingBackgroundImageView.isHidden = false
        self.walkingTItleImageView.isHidden = false
        self.walkingTItleImageView.alpha = 0.0
        self.runningBackgroundImageView.alpha = 1.0
        self.walkingBackgroundImageView.alpha = 0.0

        UIView.animate(withDuration: 0.3) {
            self.walkingTItleImageView.alpha = 1.0
            self.runningBackgroundImageView.alpha = 0.0
            self.walkingBackgroundImageView.alpha = 1.0
        } completion: {  _ in
            self.runningBackgroundImageView.isHidden = true
        }

    }
    
    private func toRunningView() {
        guard self.runningBackgroundImageView.isHidden else { return }
        self.runningBackgroundImageView.isHidden = false
        self.walkingTItleImageView.alpha = 1.0
        self.runningBackgroundImageView.alpha = 1.0
        self.runningBackgroundImageView.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.runningBackgroundImageView.alpha = 1.0
            self.walkingTItleImageView.alpha = 0.0
            self.walkingBackgroundImageView.alpha = 0.0
        } completion: {  _ in
            self.walkingBackgroundImageView.isHidden = true
            self.walkingTItleImageView.isHidden = true
        }
    }
    
    private func showStopAlert() -> Observable<Bool> {
        return Observable.create { observer in
            let keep = UIAlertAction(title: "Keep Running", style: .default) { _ in
                observer.onNext(false)
                observer.onCompleted()
            }
            
            let finish = UIAlertAction(title: "Stop Running", style: .default) { (action) in
                observer.onNext(true)
                observer.onCompleted()
            }

            self.showAlert(title: "잠시 정지하고 있어요", message: "달리기를 종료할까요?", actions: keep,finish)
            return Disposables.create()
        }
    }
}

extension PaceViewController: VCFactorable {
    public static var storyboardIdentifier = "Main"
    public static var vcIdentifier = "PaceViewController"
    public func bindData(value: Void) { }
}
