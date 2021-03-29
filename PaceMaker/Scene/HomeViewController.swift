//
//  ViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/08.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var timerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
