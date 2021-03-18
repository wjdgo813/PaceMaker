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

final class PaceViewController: UIViewController {
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var paceLabel: UILabel!
    @IBOutlet private weak var walkingTimeLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    private let viewModel = PaceViewModel()
    private let startRunning = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setBind()
        self.bindUI()
    }
}

extension PaceViewController {
    
    private func setupUI() {
            
    }
    
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
                let alert = UIAlertController(title: "", message: "그만 걸어라", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        }
                alert.addAction(okAction)
                self?.present(alert, animated: false, completion: nil)
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
