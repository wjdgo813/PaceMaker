//
//  CalendarViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit
import JTAppleCalendar
import RxSwift
import RxCocoa

final class CalendarViewController: UIViewController {
    @IBOutlet private weak var calendarView: JTACMonthView!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setBind()
    }
}

extension CalendarViewController {
    private func setupUI() {
        self.setCalendarView()
    }
    
    private func setBind() {
        self.nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.calendarView.scrollToSegment(.next,
                                                   completionHandler: {
                                                    self.setupViewsOfCalendar(from:self.calendarView.visibleDates())
                })
            }).disposed(by: self.disposeBag)
        
        self.previousButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.calendarView.scrollToSegment(.previous,
                                                   completionHandler: {
                                                    self.setupViewsOfCalendar(from:self.calendarView.visibleDates())
                })
            }).disposed(by: self.disposeBag)
    }
}

extension CalendarViewController {
    private func setCalendarView() {
        self.calendarView.calendarDataSource  = self
        self.calendarView.calendarDelegate  = self
        self.calendarView.scrollToDate(Date())
        self.calendarView.selectDates([Date()])
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        self.calendarView.register(UINib(nibName: CalendarCell.className, bundle: Bundle.main),
                              forCellWithReuseIdentifier: CalendarCell.className)
    }
    
    private func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = Calendar.current.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        let year = Calendar.current.component(.year, from: startDate)
        
        monthLabel.text = monthName + " " + String(year)
    }
    
    private func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? CalendarCell  else { return }
        cell.compose(date: cellState.text, havePace: true)
        self.handleCellTextColor(cell: cell, cellState: cellState)
        self.handleCellSelected(cell: cell, cellState: cellState)
    }
    
    private func handleCellTextColor(cell: CalendarCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.changedColor(color: .black)
        } else {
            cell.changedColor(color: .gray)
        }
    }
    
    private func handleCellSelected(cell: CalendarCell, cellState: CellState) {
        cell.selected(cellState.isSelected)
    }
}

extension CalendarViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = formatter.date(from: "2030 01 01")!
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
}

extension CalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        self.calendar(calendar,
                      willDisplay: cell,
                      forItemAt: date,
                      cellState: cellState,
                      indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) -> Bool {
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        self.configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        self.configureCell(view: cell, cellState: cellState)
    }
}
