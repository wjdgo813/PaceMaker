//
//  PaceViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/08.
//

import UIKit
import CoreMotion
import CoreLocation

import RxSwift
import RxCocoa

enum ActivityState: String {
    case stationary
    case walking
    case running
}

class PaceViewController: UIViewController {
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    private let viewModel = PaceViewModel()
    private let startRunning = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setBind()
        self.bindUI()
    }
    
    private func setupUI() {
            
    }
    
    private func setBind() {
        let output = self.viewModel.transform(input: PaceViewModel.Input(tracking: driverUtility.signalViewDidAppear(),
                                                                         runningTimer: startRunning.asObservable()))
        
        output.activity
            .subscribe(onNext: { [weak self] state in
                self?.activityLabel.text = state.rawValue
        }).disposed(by: self.disposeBag)
        
        output.timer
            .subscribe(onNext: { [weak self] timer in
                self?.timerLabel.text = "\(timer)"
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
