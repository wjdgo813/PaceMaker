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
import RxDataSources

final class CalendarViewController: UIViewController {
    
    @IBOutlet public weak var tableView: UITableView! {
        didSet {
            self.tableView.separatorStyle = .none
            self.tableView.rowHeight = UITableView.automaticDimension
        }
    }
    @IBOutlet private weak var calendarView: JTACMonthView!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    
    public let disposeBag = DisposeBag()
    public let selectedDay = PublishRelay<[Pace]>()
    private let reloadMonth = PublishRelay<String>()
    private var currentMonthPace = [Pace]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setBind()
        self.setTableView()
    }
}

extension CalendarViewController {
    private func setupUI() {
        self.setCalendarView()
    }
    
    private func setBind() {
        
        Observable.just(())
            .delay(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map { [weak self] in
                self?.currentMonthPace.filter { ($0.runDate?.string(WithFormat: .dd) == Date().string(WithFormat: .dd)) && ($0.runDate?.string(WithFormat: .MM) == Date().string(WithFormat: .MM)) }
            }.unwrap()
            .bind(to: selectedDay)
            .disposed(by: self.disposeBag)
        
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
        
        self.reloadMonth.flatMapLatest {
            PaceDataManager.shared.rxQuery(yearMonth: $0)
        }.subscribe(onNext: { [weak self] pace in
            guard let self = self else { return }
            self.currentMonthPace = pace
            self.calendarView.reloadData()
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
        self.reloadMonth.accept("\(monthName) \(year)")
    }
    
    private func configureCell(view: JTACDayCell?, cellState: CellState, date: Date) {
        guard let cell = view as? CalendarCell  else { return }
        var pace: Pace?
        if let data = self.currentMonthPace.first(where: { ($0.runDate?.string(WithFormat: .dd) == date.string(WithFormat: .dd)) && ($0.runDate?.string(WithFormat: .MM) == date.string(WithFormat: .MM)) }) {
            pace = data
        }
        
        cell.compose(date: cellState.text, pace: pace)
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
        configureCell(view: cell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState) -> Bool {
        return true
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        self.configureCell(view: cell, cellState: cellState, date: date)
        let datas = self.currentMonthPace.filter { ($0.runDate?.string(WithFormat: .dd) == date.string(WithFormat: .dd)) && ($0.runDate?.string(WithFormat: .MM) == date.string(WithFormat: .MM)) }
        self.selectedDay.accept(datas)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        self.configureCell(view: cell, cellState: cellState, date: date)
    }
}
