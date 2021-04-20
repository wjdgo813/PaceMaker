//
//  PaceCell.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/20.
//

import UIKit

class PaceCell: UITableViewCell, CellFactory {
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var walkingLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    static let identifier = "PaceCell"
    func bindData(value: Pace) {
        self.dataLabel.text = value.runDate?.string(WithFormat: .paceDate)
        self.distanceLabel.text = "\(value.distance)"
        self.durationLabel.text = "\(value.duration)"
        self.walkingLabel.text = "\(value.walking)"
        self.paceLabel.text = value.pace ?? ""
    }
}

extension PaceCell: CellRegister {
    static let nibName = "PaceCell"
}
