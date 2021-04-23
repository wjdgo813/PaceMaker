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
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.separatorStyle = .none
            self.tableView.rowHeight = UITableView.automaticDimension
        }
    }
    @IBOutlet private weak var calendarView: JTACMonthView!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    
    private let selectedDay = BehaviorRelay<Date>(value: Date())
    private let selectedPace = BehaviorRelay<[Pace]?>(value: nil)
    private let reloadMonth = PublishRelay<String>()
    private var currentMonthPace = [Pace]()
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
        self.setTableView()
    }
    
    private func setBind() {
        
        self.selectedDay
            .map { [weak self] selected in
                self?.currentMonthPace.filter { ($0.runDate.string(WithFormat: .dd) == selected.string(WithFormat: .dd)) && ($0.runDate.string(WithFormat: .MM) == selected.string(WithFormat: .MM)) }
            }.unwrap()
            .bind(to: self.selectedPace)
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
        
        self.reloadMonth
            .flatMapLatest { PaceDataManager.shared.rxQuery(yearMonth: $0) }
            .subscribe(onNext: { [weak self] paces in
                guard let self = self else { return }
                self.currentMonthPace = paces
                self.selectedDay.accept(self.selectedDay.value)
//                let datas = paces.filter { ($0.runDate.string(WithFormat: .dd) == selected.string(WithFormat: .dd)) && ($0.runDate.string(WithFormat: .MM) == selected.string(WithFormat: .MM)) }
//                self.selectedPace.accept(datas)
                
                
                self.calendarView.reloadData()
            }).disposed(by: self.disposeBag)
    }
    
    func setTableView() {
        self.tableView.register(PaceCell.self)
        
        self.selectedPace.unwrap().map { [PaceSection(items: $0)] }
            .bind(to: self.tableView.rx.items(dataSource: RxTableViewSectionedAnimatedDataSource<PaceSection>(configureCell: { [weak self] dataSource, tableview, indexPath, data in
                
                let cell = tableview.getCell(value: PaceCell.self, data: data)
                cell.deleteButton.rx.tap
                    .flatMap { [weak self] _ -> Observable<Bool> in
                        guard let self = self else { return .just(false) }
                        return self.showRemovePace()
                    }
                    .filter { $0 }
                    .flatMap { _ -> Observable<Void> in
                        return PaceDataManager.shared.rxDeletePace(id: data.id)
                    }
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        self.setupViewsOfCalendar(from:self.calendarView.visibleDates())
                    }).disposed(by: cell.reusableBag)
                
                return cell
            }))).disposed(by: self.disposeBag)
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
        if let data = self.currentMonthPace.first(where: { ($0.runDate.string(WithFormat: .dd) == date.string(WithFormat: .dd)) && ($0.runDate.string(WithFormat: .MM) == date.string(WithFormat: .MM)) }) {
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
        self.selectedDay.accept(date)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        self.configureCell(view: cell, cellState: cellState, date: date)
    }
}

extension CalendarViewController: Alertable {
    private func showRemovePace() -> Observable<Bool> {
        return Observable.create { observer in
            let yes = UIAlertAction(title: "Yes", style: .default) { _ in
                observer.onNext(true)
                observer.onCompleted()
            }
            
            let no = UIAlertAction(title: "No", style: .default) { (action) in
                observer.onNext(false)
                observer.onCompleted()
            }

            self.showAlert(title: "", message: "Should I delete the record?", actions: no, yes)
            return Disposables.create()
        }
    }
}
