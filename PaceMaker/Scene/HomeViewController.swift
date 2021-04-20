//
//  ViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/08.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: UIViewController, Alertable {

    @IBOutlet private weak var timerButton: UIButton!
    private var setCount = 3 {
        didSet {
            self.timerButton.setTitle("\(setCount) minutes", for: .normal)
        }
    }
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
                    print("\(pace.runDate.toUTCString())")
                    print("\(pace.runDate.string(WithFormat: .MM))")
                    print("\(pace.runDate.string(WithFormat: .paceDate))")
                }
            }).disposed(by: self.disposeBag)
        
        self.setupUI()
        self.setBind()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let vc = segue.destination as? PaceViewController else { return }
        vc.limitedWalkingTime = self.setCount
    }
}

extension HomeViewController {
    private func setupUI() {
        self.setCount = 3
        self.timerButton.layer.cornerRadius = 25
        self.timerButton.layer.borderWidth = 2
        self.timerButton.layer.borderColor = UIColor.init(hexStr: "#F3DFD0").cgColor
    }
    
    private func setBind() {
        self.timerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let cancel = UIAlertAction(title: "cancel", style: .cancel) { (action) in
                
                }
                
                let one = UIAlertAction(title: "1 minutes", style: .default) { (action) in
                    self.setCount = 1
                }
                
                let three = UIAlertAction(title: "3 minutes", style: .default) { (action) in
                    self.setCount = 3
                }
                
                let five = UIAlertAction(title: "5 minutes", style: .default) { (action) in
                    self.setCount = 5
                }
                
                let ten = UIAlertAction(title: "10 minutes", style: .default) { (action) in
                    self.setCount = 10
                }
                
                self.showAction(actions: one,three,five,ten,cancel)
            }).disposed(by: self.disposeBag)
    }
}
