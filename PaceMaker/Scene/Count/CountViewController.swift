//
//  CountViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/28.
//

import UIKit
import Lottie

class CountViewController: UIViewController {
    var limitedWalkingTime = 0
    @IBOutlet private weak var countView: UIView!
    private let countLottie = AnimationView(name:"countdown")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.initLottie()
        self.afterStartPace()
    }
    
    private func initLottie() {
        self.countLottie.frame = self.countView.bounds
//        self.countLottie.center = self.countView.center
        self.countLottie.contentMode = .scaleAspectFill
        self.countView.addSubview(self.countLottie)
        
        self.countLottie.play()
    }
    
    private func afterStartPace() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ContainerViewController.target?.execute(scene: .pace(walkingTime: self.limitedWalkingTime))
        }
    }
}
