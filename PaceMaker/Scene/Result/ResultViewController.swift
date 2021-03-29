//
//  ResultViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit

final class ResultViewController: UIViewController {

    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var paceLabel: UILabel!
    @IBOutlet private weak var walkingLabel: UILabel!
    
    private var record: Record!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.distanceLabel.text = "\(self.record.distance)"
        self.durationLabel.text = "\(self.record.duration)"
        self.paceLabel.text     = "\(self.record.pace)"
        self.walkingLabel.text = "\(self.record.walking)"
    }
}

extension ResultViewController: VCFactorable {
    public static var storyboardIdentifier = "Result"
    public static var vcIdentifier = "ResultViewController"
    public func bindData(value: Record) {
        self.modalPresentationStyle = .fullScreen
        self.record = value
    }
}
