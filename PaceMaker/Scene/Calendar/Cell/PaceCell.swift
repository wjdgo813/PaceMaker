//
//  PaceCell.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/20.
//

import UIKit
import RxSwift
import RxCocoa

class PaceCell: UITableViewCell, CellFactory {
    @IBOutlet private weak var dataLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var walkingLabel: UILabel!
    @IBOutlet private weak var paceLabel: UILabel!

    @IBOutlet weak var deleteButton: UIButton!
    var reusableBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.reusableBag = DisposeBag()
    }

    static let identifier = "PaceCell"
    func bindData(value: Pace) {
        self.dataLabel.text = value.runDate.string(WithFormat: .paceDate)
        self.distanceLabel.text = "\(value.distance)"
        self.durationLabel.text = "\(value.duration)"
        self.walkingLabel.text = "\(value.walking)"
        self.paceLabel.text = value.pace ?? ""
    }
}

extension PaceCell: CellRegister {
    static let nibName = "PaceCell"
}
