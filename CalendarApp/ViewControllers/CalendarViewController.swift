//
//  ViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/09/28.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift
import PKHUD

class CalendarViewController: UIViewController {

    enum MenuType: String {
        case month = "月表示"
        case week = "週表示"
        case holiday = "土日祝のみ"
        case weekday = "平日のみ"
    }

    enum DayOfWeekType: String {
        case monday = "月曜日スタート"
        case sunday = "日曜日スタート"
    }

    private let realm = try! Realm()
    // tablecellのイベントデータの表示用
    var eventResults: Results<EventModel>!
    // カレンダーの緑ぽち用
    var eventCounts: Results<EventModel>!

    private let cellId = "cellId"
    private let dateFormat = DateFormatter()
    private var date = String()
    private let todayDate = Date()
    private var todayString = String()
    var selectedMenuType = MenuType.month
    var selectDayOfWeekMenuType = DayOfWeekType.sunday

    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet private weak var taskTableView: UITableView!
    @IBOutlet private weak var selectElementDropDownView: UIView!
    @IBOutlet private weak var calendarInfoView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var calendarLabel: UILabel!
    @IBOutlet private weak var rokuyouLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var selectElementButton: UIButton!
    @IBOutlet private weak var elementDropDownButton: UIButton!
    @IBOutlet private weak var scrollButton: UIButton!
    @IBOutlet private weak var bulkDeleteButton: UIButton!
    @IBOutlet private weak var dayOfWeekSortButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTodayDate()
        setupView()
        setupCalendar()
        filterEvent(date: todayString)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupTodayDate()
        todayDateOrOtherDate()

    }
    // MARK: - Method
    private func setupView() {
        taskTableView.dataSource = self
        taskTableView.delegate = self
        taskTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        dateLabel.text = todayString
        addButton.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
        elementDropDownButton.addTarget(self, action: #selector(tappedElementDropDownButton), for: .touchUpInside)
        scrollButton.addTarget(self, action: #selector(tappedScrollButton), for: .touchUpInside)
        bulkDeleteButton.addTarget(self, action: #selector(tappedBulkDeleteButton), for: .touchUpInside)
        dayOfWeekSortButton.addTarget(self, action: #selector(tappedDayOfWeekButton), for: .touchUpInside)
        rokuyouLabel.text = calculateRokuyo(date: todayDate)
        calendarInfoView.layer.borderWidth = 2.5
        calendarInfoView.layer.borderColor = UIColor.rgb(red: 235, green: 235, blue: 235).cgColor

    }

    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .horizontal
        calendar.layer.borderWidth = 2.5
        calendar.layer.borderColor = UIColor.rgb(red: 235, green: 235, blue: 235).cgColor
        defaultWeekdayLabels()
    }

    private func setupTodayDate() {
        dateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "ja_JP"))
        todayString = dateFormat.string(from: todayDate)
    }

    private func todayDateOrOtherDate() {
        if date.isEmpty {
            filterEvent(date: todayString)
            return
        } else {
            filterEvent(date: date)
        }
    }

    private func defaultWeekdayLabels() {
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
    }

    @objc private func tappedElementDropDownButton() {
        var displayCalendarMenu = [UIMenuElement]()

        displayCalendarMenu.append(UIAction(title: MenuType.month.rawValue, image: UIImage(named: "calendar1"), state: self.selectedMenuType == MenuType.month ? .on : .off, handler: { [weak self] _ in
            if self?.calendar.scope == .week {
                self?.calendar.scope = .month
                self?.calendar.setScope(.month, animated: true)
            }
            self?.selectedMenuType = .month
            self?.calendar.reloadData()
            self?.tappedElementDropDownButton()
        }))

        displayCalendarMenu.append(UIAction(title: MenuType.week.rawValue, image: UIImage(named: "calendar2"), state: self.selectedMenuType == MenuType.week ? .on : .off, handler: { [weak self] _ in
            if self?.calendar.scope == .month {
                self?.calendar.scope = .week
                self?.calendar.setScope(.week, animated: true)
            }
            self?.selectedMenuType = .week
            self?.calendar.reloadData()
            self?.tappedElementDropDownButton()
        }))

        displayCalendarMenu.append(UIAction(title: MenuType.holiday.rawValue, image: UIImage(named: "calendar3"), state: self.selectedMenuType == MenuType.holiday ? .on : .off, handler: { [weak self] _ in
            self?.calendar.reloadData()
            self?.selectedMenuType = .holiday
            self?.tappedElementDropDownButton()

        }))

        displayCalendarMenu.append(UIAction(title: MenuType.weekday.rawValue, image: UIImage(named: "calendar4"), state: self.selectedMenuType == MenuType.weekday ? .on : .off, handler: { [weak self] _ in
            self?.selectedMenuType = .weekday
            self?.calendar.reloadData()
            self?.tappedElementDropDownButton()

        }))

        displayCalendarMenu.append(UIAction(title: "Googleカレンダーと同期", handler: { _ in
            HUD.show(.progress)
            GoogleCalendarSync.getEvents()
            HUD.flash(.success)
        }))
        elementDropDownButton.menu = UIMenu(title: "オプション", options: .displayInline, children: displayCalendarMenu)
        elementDropDownButton.showsMenuAsPrimaryAction = true
        elementDropDownButton.setTitle(self.selectedMenuType.rawValue, for: .normal)
    }

    @objc private func tappedDayOfWeekButton() {
        var dayOfWeekMenu = [UIMenuElement]()

        dayOfWeekMenu.append(UIAction(title: DayOfWeekType.sunday.rawValue, state: self.selectDayOfWeekMenuType == DayOfWeekType.sunday ? .on : .off, handler: { [weak self] _ in
            self?.calendar.firstWeekday = 1
            self?.defaultWeekdayLabels()
            self?.selectDayOfWeekMenuType = .sunday
            self?.calendar.reloadData()
            self?.tappedDayOfWeekButton()

        }))

        dayOfWeekMenu.append(UIAction(title: DayOfWeekType.monday.rawValue, state: self.selectDayOfWeekMenuType == DayOfWeekType.monday ? .on : .off, handler: { [weak self] _ in
            self?.calendar.firstWeekday = 2
            self?.calendar.calendarWeekdayView.weekdayLabels[0].text = "月"
            self?.calendar.calendarWeekdayView.weekdayLabels[1].text = "火"
            self?.calendar.calendarWeekdayView.weekdayLabels[2].text = "水"
            self?.calendar.calendarWeekdayView.weekdayLabels[3].text = "木"
            self?.calendar.calendarWeekdayView.weekdayLabels[4].text = "金"
            self?.calendar.calendarWeekdayView.weekdayLabels[5].text = "土"
            self?.calendar.calendarWeekdayView.weekdayLabels[6].text = "日"

            self?.selectDayOfWeekMenuType = .monday
            self?.calendar.reloadData()
            self?.tappedDayOfWeekButton()

        }))
        dayOfWeekSortButton.menu = UIMenu(title: "曜日順", options: .displayInline, children: dayOfWeekMenu)
        dayOfWeekSortButton.showsMenuAsPrimaryAction = true

    }

    @objc private func tappedScrollButton() {
        if calendar.scrollDirection == .vertical {
            calendar.scrollDirection = .horizontal
            scrollButton.setTitle("横方向", for: .normal)

        } else if calendar.scrollDirection == .horizontal {
            calendar.scrollDirection = .vertical
            scrollButton.setTitle("縦方向", for: .normal)
        }
    }

    @objc private func tappedAddButton() {
        let storyboard = UIStoryboard(name: "AddSchedule", bundle: nil)
        if let addEventViewController = storyboard.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddEventViewController {
            addEventViewController.modalTransitionStyle = .coverVertical
            addEventViewController.modalPresentationStyle = .fullScreen
            addEventViewController.delegate = self
            addEventViewController.date = date
            present(addEventViewController, animated: true, completion: nil)
        }
    }

    @objc private func tappedBulkDeleteButton() {
        let alert = UIAlertController(title: "アラート表示", message: "この日の予定を一括削除しても良いですか？", preferredStyle: UIAlertController.Style.alert)
        let clearAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default) { [weak self] (_: UIAlertAction) in
            self?.bulkDelete()
        }
        alert.addAction(clearAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    private func bulkDelete() {
        let realm = try! Realm()
        let result: Results<EventModel>!
        var eventModel = [EventModel]()
        let event = realm.objects(EventModel.self).filter("date == '\(date)'")

        if date.isEmpty {
            result = realm.objects(EventModel.self).filter("date == '\(todayString)'")
        } else {
            result = realm.objects(EventModel.self).filter("date == '\(date)'")
        }

        for results in event {
            eventModel.append(results)
        }

        let notificationIdArray = eventModel.map({ (eventNotificationId) -> String in
            return eventNotificationId.notificationId
        })

        do {
            try realm.write {
                // 通知の削除
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIdArray)
                realm.delete(result)
            }
        } catch {
            print("Error \(error)")
        }

        taskTableView.reloadData()
        todayDateOrOtherDate()
    }

    private func fetchEventModels() {
        eventCounts = realm.objects(EventModel.self)
    }

    private func filterEvent(date: String) {
        eventResults = realm.objects(EventModel.self).filter("date == '\(date)'").sorted(byKeyPath: "editStartTime", ascending: true)
        taskTableView.reloadData()
    }

    private func calculateRokuyo(date: Date) -> String {
        let chineseCalendar = Calendar(identifier: .chinese)
        let dateComponents = chineseCalendar.dateComponents([.year, .month, .day], from: date)

        if let month = dateComponents.month, let day = dateComponents.day {
            let result = (month + day) % 6
            switch result {
            case 0:
                return "(大安)"
            case 1:
                return "(赤口)"
            case 2:
                return "(先勝)"
            case 3:
                return "(友引)"
            case 4:
                return "(先負)"
            case 5:
                return "(仏滅)"
            default:
                break
            }
        }
        return ""
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override var shouldAutorotate: Bool {
        return false
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = taskTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? EventTableViewCell {
            cell.delegate = self
            cell.alertDelegate = self
            cell.eventModel = eventResults[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "AddSchedule", bundle: nil)
        if let addEventViewController = storyboard.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddEventViewController {
            addEventViewController.eventModel = eventResults[indexPath.row]
            addEventViewController.date = date
            addEventViewController.modalPresentationStyle = .fullScreen
            present(addEventViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - EventTableViewCellDelegate
extension CalendarViewController: EventTableViewCellDelegate {
    func notifiCell(eventFromCell: EventModel) {
        let realm = try! Realm()
        let result: Results<EventModel>!
        result = realm.objects(EventModel.self).filter("eventId == '\(eventFromCell.eventId)'")

        do {
            try eventFromCell.realm?.write {
                // 通知の削除
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventFromCell.notificationId])
                eventFromCell.realm?.delete(result)
            }
        } catch {
            print("Error \(error)")
        }
        taskTableView.reloadData()
        todayDateOrOtherDate()
    }
}

// MARK: - AddEventViewControllerDelegate
extension CalendarViewController: AddEventViewControllerDelegate {
    func event(addEvent: EventModel) {
        filterEvent(date: addEvent.date)
    }
}

// MARK: - FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormat.dateFormat = "yyyy/MM/dd"
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dateLabel.text = "\(year)年\(month)月\(day)日"
        rokuyouLabel.text = calculateRokuyo(date: date)

        self.date = date.toStringWithCurrentLocale()
        filterEvent(date: date.toStringWithCurrentLocale())
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        fetchEventModels()
        dateFormat.dateFormat = "yyyy/MM/dd"

        let date = dateFormat.string(from: date)
        var hasEvent: Bool = false
        for eventModel in eventCounts where eventModel.date == date {
            hasEvent = true
        }
        if hasEvent {
            return 1
        } else {
            return 0
        }
    }
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 土日祝のカレンダー表示
        if selectedMenuType == .holiday {
            if judgeHoliday(date) {
                return UIColor.red
            }

            let weekday = getWeekIdx(date)
            if weekday == 1 {   // 日曜日
                return UIColor.red
            } else if weekday == 7 {  // 土曜日
                return UIColor.blue
            }
            // 平日の色
            switch weekday {

            case 2...6:
                return UIColor.white
            default: break

            }
            // 平日のみの表示
        } else if selectedMenuType == .weekday {
            if judgeHoliday(date) {
                return UIColor.white
            }
            let weekday = getWeekIdx(date)
            if weekday == 1 {   // 日曜日
                return UIColor.white
            } else if weekday == 7 {  // 土曜日
                return UIColor.white
            }
        } else {
            // 祝日判定をする（祝日は赤色で表示する）
            if judgeHoliday(date) {
                return UIColor.red
            }
            // 土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
            let weekday = getWeekIdx(date)
            if weekday == 1 {   // 日曜日
                return UIColor.red
            } else if weekday == 7 {  // 土曜日
                return UIColor.blue
            }
        }
        return nil
    }

    private func judgeHoliday(_ date: Date) -> Bool {
        // 祝日判定用のカレンダークラスのインスタンス
        let tmpCalendar = Calendar(identifier: .gregorian)
        // 祝日判定を行う日にちの年、月、日を取得
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        // CalculateCalendarLogic()：祝日判定のインスタンスの生成
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    // date型 -> 年月日をIntで取得
    private func getDay(_ date: Date) -> (Int, Int, Int) {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year, month, day)
    }
    // 曜日判定(日曜日:1 〜 土曜日:7)
    private func getWeekIdx(_ date: Date) -> Int {
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
}

extension Date {
    func toStringWithCurrentLocale() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }
}
