//
//  CalendarViewController+TableView.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/17.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

extension CalendarViewController {
    func setTableView() {
        self.tableView.register(PaceCell.self)
        
        self.selectedDay.map { [PaceSection(items: $0)] }
            .bind(to: self.tableView.rx.items(dataSource: RxTableViewSectionedAnimatedDataSource<PaceSection>(configureCell: { dataSource, tableview, indexPath, data in
                return tableview.getCell(value: PaceCell.self, data: data)
            }))).disposed(by: self.disposeBag)
    }
}







