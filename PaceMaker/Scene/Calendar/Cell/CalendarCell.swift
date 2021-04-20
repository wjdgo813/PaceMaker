//
//  CalendarCell.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/07.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTACDayCell {

    @IBOutlet private weak var selectedView: StrokeView!
    @IBOutlet private weak var hilightView: StrokeView!
    @IBOutlet private weak var dayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

extension CalendarCell {
    func compose(date: String, pace: Pace?) {
        self.dayLabel.text = date
        self.hilightView.isHidden = pace.isEmpty
    }
    
    func changedColor(color: UIColor) {
        self.dayLabel.textColor = color
    }
    
    func selected(_ isAble: Bool) {
        self.selectedView.isHidden = !isAble
        if isAble {
            self.hilightView.isHidden = isAble
            self.dayLabel.textColor = .white
        }
    }
}
