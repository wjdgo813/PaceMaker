//
//  SettingViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/23.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {

    @IBOutlet private weak var notificationSwitch: UISwitch!
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationSwitch.isOn = UserDefaults.standard.bool(forKey: "notiOn")

        self.notificationSwitch.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                UserDefaults.standard.set(self.notificationSwitch.isOn, forKey: "notiOn")
                
            }).disposed(by: self.disposeBag)
    }
}
