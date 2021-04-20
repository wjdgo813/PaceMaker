//
//  CalendarDataSource.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/16.
//

import RxDataSources

extension Pace: IdentifiableType {
    public var identity: String {
        return "Pace"
    }
}

struct PaceSection {
    var items: [Pace]
}

extension PaceSection: AnimatableSectionModelType {
    var identity: String { "PaceSection" }
    
    init(original: PaceSection, items: [Pace]) {
        self = original
        self.items = items
    }
}
