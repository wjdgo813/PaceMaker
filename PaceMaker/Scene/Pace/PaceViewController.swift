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
    
    func isTurnOffGenerator(after: ActivityState) -> Bool {
        switch (self, after) {
        case (.stationary, .running),
             (.walking, .running):
            return true
        default:
            return false
        }
    }
}

final class PaceViewController: UIViewController, Alertable {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var paceLabel: UILabel!
    @IBOutlet private weak var walkingTimeLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    private let startRunning = BehaviorRelay<Bool>(value: true)
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let viewModel = PaceViewModel()
    private let disposeBag = DisposeBag()
    
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
        let output = self.viewModel.transform(input: PaceViewModel.Input(tracking:driverUtility.signalViewDidAppear(),
                                                                         runningTimer: startRunning.asObservable()))
        
        output.activity
            .subscribe(onNext: { [weak self] state in
                
        }).disposed(by: self.disposeBag)
        
        output.runningTimer
            .subscribe(onNext: { [weak self] timer in
                self?.durationLabel.text = "\(timer)"
            }).disposed(by: self.disposeBag)
        
        output.walkingTimer
            .subscribe(onNext: { [weak self] timer in
                self?.walkingTimeLabel.text = "\(timer)"
            }).disposed(by: self.disposeBag)
        
        output.distance.subscribe(onNext: { [weak self] totalDistance in
            self?.distanceLabel.text = "\(totalDistance)"
        }).disposed(by: self.disposeBag)
        
        output.doNotWalking
            .subscribe(onNext: { [weak self] _ in
                self?.impactGenerator.impactOccurred()
                let alert = UIAlertController(title: "", message: "그만 걸어라", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        }
                alert.addAction(okAction)
                self?.present(alert, animated: false, completion: nil)
        }).disposed(by: self.disposeBag)
    }
    
    private func bindUI() {
//        PaceDataManager.shared.
        
        self.pauseButton.rx.tap
            .withLatestFrom(startRunning)
            .map { !$0 }
            .bind(to: self.startRunning)
            .disposed(by: self.disposeBag)
        
        self.pauseButton.rx.tap
            .map {
                return Record(date: Date(),
                                    distance: 200,
                                    duration: 7777,
                                    walking: 2222,
                                    pace: "jhh")
            }
            .flatMap { record in
                return PaceDataManager.shared.save(record: record)
            }
            .subscribe(onNext: { [weak self] record in
                let keep = UIAlertAction(title: "Keep Running", style: .default)
                let finish = UIAlertAction(title: "Stop Running", style: .default) { (action) in
                    ContainerViewController.target?.execute(scene: .result(record))
                }
                
                self?.showAlert(title: "잠시 정지하고 있어요", message: "달리기를 종료할까요?", actions: keep,finish)
            }).disposed(by: self.disposeBag)
    }
}

extension PaceViewController: VCFactorable {
    public static var storyboardIdentifier = "Main"
    public static var vcIdentifier = "PaceViewController"
    public func bindData(value: Void) { }
}
