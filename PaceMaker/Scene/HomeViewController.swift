//
//  ViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/08.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {

    @IBOutlet private weak var timerButton: UIButton!
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        PaceDataManager.shared.rxQuery().debug("PaceDataManager rxQuery")
            .subscribe(onNext: { paces in
                paces.forEach { pace in
                    print("-------")
                    print(pace.id)
                    print("\(pace.distance)")
                    print(String(pace.duration))
                    print(String(pace.walking))
                    print(String(pace.pace ?? ""))
                    print("\(pace.runDate?.toUTCString())")
                    print("\(pace.runDate?.string(WithFormat: .MM))")
                    print("\(pace.runDate?.string(WithFormat: .paceDate))")
                }
            }).disposed(by: self.disposeBag)
        
        self.setupUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let vc = segue.destination as? PaceViewController else { return }
        vc.limitedWalkingTime = 1
    }
}

extension HomeViewController {
    private func setupUI() {
//        F3DFD0
        self.timerButton.layer.cornerRadius = 25
        self.timerButton.layer.borderWidth = 1
//        self.timerButton.layer.borderColor =
    }
    
    private func setBind() {
        self.timerButton.rx.tap
            .subscribe(onNext: {
            
            }).disposed(by: self.disposeBag)
    }
}
