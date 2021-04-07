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
    func compose(date: String, havePace: Bool) {
        self.dayLabel.text = date
        self.hilightView.isHidden = !havePace
    }
    
    func changedColor(color: UIColor) {
        self.dayLabel.textColor = color
    }
    
    func selected(_ isAble: Bool) {
        self.selectedView.isHidden = !isAble
        self.hilightView.isHidden = isAble
        if isAble {
            self.dayLabel.textColor = .white
        }
    }
}
