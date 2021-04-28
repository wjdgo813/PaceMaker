//
//  ResultViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit

import RxSwift
import RxCocoa
import GoogleMobileAds

final class ResultViewController: UIViewController, Bannerable {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet private weak var runDateLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var paceLabel: UILabel!
    @IBOutlet private weak var walkingLabel: UILabel!
    
    private var record: Record!
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initBanner(root: self)
        self.distanceLabel.text = "\(self.record.distance)"
        self.durationLabel.text = "\(self.record.duration)"
        self.paceLabel.text     = "\(self.record.pace)"
        self.walkingLabel.text = "\(self.record.walking)"
        self.runDateLabel.text = self.record.date.string(WithFormat: .paceDate)
        
        self.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
        }).disposed(by: self.disposeBag)
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
