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
import GoogleMobileAds

class CalendarViewController: UIViewController, UNUserNotificationCenterDelegate {

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
    var eventResults: Results<EventModel>?
    // カレンダーの緑ぽち用
    var allEvent: Results<EventModel>!
    var eventCounts: Results<EventModel>!

    private let cellId = "cellId"
    private let dateFormat = DateFormatter()
    private var date = String()
    private let todayDate = Date()
    private var todayString = String()
    var allDayDate = String()
    private var selectedMenuType = MenuType.month
    private var selectDayOfWeekMenuType = DayOfWeekType.sunday
    private var dayOfWeekBool = Bool()

    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet private weak var taskTableView: UITableView!
    @IBOutlet private weak var calendarInfoView: UIView!
    @IBOutlet private weak var bannerView: GADBannerView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var calendarLabel: UILabel!
    @IBOutlet private weak var rokuyouLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var optionButton: UIButton!
    @IBOutlet private weak var scrollButton: UIButton!
    @IBOutlet private weak var bulkDeleteButton: UIButton!
    @IBOutlet private weak var dayOfWeekSortButton: UIButton!
    @IBOutlet private weak var settingButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTodayDate()
        setupView()
        setupCalendar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultDayOfWeek()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTodayDate()
        todayDateOrOtherDate()
        setupBannerView()
    }
    // MARK: - Method
    private func setupView() {
        taskTableView.dataSource = self
        taskTableView.delegate = self
        taskTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        dateLabel.text = todayString
        tappedOptionMenuButton()
        tappedDayOfWeekButton()
        addButton.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
        scrollButton.addTarget(self, action: #selector(tappedScrollButton), for: .touchUpInside)
        bulkDeleteButton.addTarget(self, action: #selector(tappedBulkDeleteButton), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(tappedSettingButton), for: .touchUpInside)
        rokuyouLabel.text = calculateRokuyo(date: todayDate)
        calendarInfoView.layer.borderWidth = 2.3
        calendarInfoView.layer.borderColor = UIColor(named: "calendarInfoViewBorder")?.cgColor
        calendarInfoView.layer.cornerRadius = 12
    }

    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.scrollDirection = .horizontal
        calendar.layer.borderWidth = 2.5
        calendar.layer.cornerRadius = 20
        calendar.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        calendar.layer.shadowOffset = CGSize(width: 18.0, height: 8.0)
        calendar.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        calendar.layer.shadowOpacity = 1.0
        calendar.layer.shadowRadius = 8
        selectedWeekdayLabels()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        calendar.layer.shadowColor = UIColor(named: "shadow")?.cgColor
        calendarInfoView.layer.borderColor = UIColor(named: "calendarInfoViewBorder")?.cgColor
        calendar.layer.borderColor = UIColor(named: "borderColor")?.cgColor
    }

    private func setupTodayDate() {
        dateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "ja_JP"))
        todayString = dateFormat.string(from: todayDate)
    }

    private func todayDateOrOtherDate() {
        if date.isEmpty {
            filterEvent(date: todayString)
            taskTableView.reloadData()
            return
        } else {
            filterEvent(date: date)
            taskTableView.reloadData()
        }
    }

    private func selectedWeekdayLabels() {
        if selectDayOfWeekMenuType == .sunday {
            calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
            calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
            calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
            calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
            calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
            calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
            calendar.calendarWeekdayView.weekdayLabels[6].text = "土"

        } else if selectDayOfWeekMenuType == .monday {
            calendar.calendarWeekdayView.weekdayLabels[0].text = "月"
            calendar.calendarWeekdayView.weekdayLabels[1].text = "火"
            calendar.calendarWeekdayView.weekdayLabels[2].text = "水"
            calendar.calendarWeekdayView.weekdayLabels[3].text = "木"
            calendar.calendarWeekdayView.weekdayLabels[4].text = "金"
            calendar.calendarWeekdayView.weekdayLabels[5].text = "土"
            calendar.calendarWeekdayView.weekdayLabels[6].text = "日"
        }
    }

    private func tappedOptionMenuButton() {
        var displayCalendarMenu = [UIMenuElement]()

        displayCalendarMenu.append(UIAction(title: MenuType.weekday.rawValue, image: UIImage(named: "calendar4"), state: self.selectedMenuType == MenuType.weekday ? .on : .off, handler: { [weak self] _ in
            self?.selectedMenuType = .weekday
            self?.calendar.reloadData()
            self?.tappedOptionMenuButton()

        }))

        displayCalendarMenu.append(UIAction(title: MenuType.holiday.rawValue, image: UIImage(named: "calendar3"), state: self.selectedMenuType == MenuType.holiday ? .on : .off, handler: { [weak self] _ in
            self?.calendar.reloadData()
            self?.selectedMenuType = .holiday
            self?.tappedOptionMenuButton()

        }))

        displayCalendarMenu.append(UIAction(title: MenuType.week.rawValue, image: UIImage(named: "calendar2"), state: self.selectedMenuType == MenuType.week ? .on : .off, handler: { [weak self] _ in
            if self?.calendar.scope == .month {
                self?.calendar.scope = .week
                self?.calendar.setScope(.week, animated: true)
            }
            self?.selectedMenuType = .week
            self?.calendar.reloadData()
            self?.tappedOptionMenuButton()
        }))

        displayCalendarMenu.append(UIAction(title: MenuType.month.rawValue, image: UIImage(named: "calendar1"), state: self.selectedMenuType == MenuType.month ? .on : .off, handler: { [weak self] _ in
            if self?.calendar.scope == .week {
                self?.calendar.scope = .month
                self?.calendar.setScope(.month, animated: true)
            }
            self?.selectedMenuType = .month
            self?.calendar.reloadData()
            self?.tappedOptionMenuButton()
        }))
        optionButton.menu = UIMenu(title: "オプション", options: .displayInline, children: displayCalendarMenu)
        optionButton.showsMenuAsPrimaryAction = true
        optionButton.setTitle(selectedMenuType.rawValue, for: .normal)
    }

    private func defaultDayOfWeek() {
        let userDefaults = UserDefaults.standard.bool(forKey: "dayOfWeek")
        print(userDefaults)

        if userDefaults == false {
            calendar.firstWeekday = 1
            selectDayOfWeekMenuType = .sunday
            selectedWeekdayLabels()
        } else {
            calendar.firstWeekday = 2
            selectDayOfWeekMenuType = .monday
            selectedWeekdayLabels()
        }
        calendar.reloadData()
    }

    private func tappedDayOfWeekButton() {
        var dayOfWeekMenu = [UIMenuElement]()

        dayOfWeekMenu.append(UIAction(title: DayOfWeekType.sunday.rawValue, handler: { [weak self] _ in
            self?.calendar.firstWeekday = 1
            self?.selectDayOfWeekMenuType = .sunday
            self?.dayOfWeekBool = false
            UserDefaults.standard.set(self?.dayOfWeekBool, forKey: "dayOfWeek")
            self?.selectedWeekdayLabels()
            self?.calendar.reloadData()
            self?.tappedDayOfWeekButton()

        }))

        dayOfWeekMenu.append(UIAction(title: DayOfWeekType.monday.rawValue, handler: { [weak self] _ in
            self?.calendar.firstWeekday = 2
            self?.selectDayOfWeekMenuType = .monday
            self?.dayOfWeekBool = true
            UserDefaults.standard.set(self?.dayOfWeekBool, forKey: "dayOfWeek")
            self?.selectedWeekdayLabels()
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
        requestNotification()
        let storyboard = UIStoryboard(name: "AddSchedule", bundle: nil)
        if let addEventViewController = storyboard.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddEventViewController {
            addEventViewController.modalTransitionStyle = .coverVertical
            addEventViewController.modalPresentationStyle = .fullScreen
            addEventViewController.delegate = self
            addEventViewController.date = date
            addEventViewController.allDayDate = allDayDate
            present(addEventViewController, animated: true, completion: nil)
        }
    }

    @objc private func tappedSettingButton() {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        if let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
            settingViewController.modalTransitionStyle = .coverVertical
            settingViewController.modalPresentationStyle = .fullScreen
            present(settingViewController, animated: true, completion: nil)
        }
    }

    @objc private func tappedBulkDeleteButton() {
        let alert = UIAlertController(title: "アラート表示", message: "この日の予定を一括削除してもよろしいですか？", preferredStyle: UIAlertController.Style.alert)
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
        calendar.reloadData()
        todayDateOrOtherDate()
    }

    private func fetchEventModels() {
        allEvent = realm.objects(EventModel.self)
    }

    private func fetchEventCounts(date: String) {
        eventCounts = realm.objects(EventModel.self).filter("date == '\(date)'")
    }

    private func filterEvent(date: String) {
        eventResults = realm.objects(EventModel.self).filter("date == '\(date)'").sorted(byKeyPath: "editStartTime", ascending: true)
    }

    private func setupBannerView() {
        if let id = adUnitID(key: "banner") {
            bannerView.adUnitID = id
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }

    private func adUnitID(key: String) -> String? {
        guard let adUnitIDs = Bundle.main.object(forInfoDictionaryKey: "AdUnitIDs") as? [String: String] else {
            return nil
        }
        return adUnitIDs[key]
    }

    private func requestNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted: Bool, _: Error?) in
            // [.alert, .badge, .sound]と指定されているので、「アラート、バッジ、サウンド」の3つに対しての許可をリクエストした
            if granted {
                // 「許可」が押された場合
                UNUserNotificationCenter.current().delegate = self
            } else {
                return
                // 「許可しない」が押された場合
            }
        }
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

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventResults?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = taskTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? EventTableViewCell {
            cell.delegate = self
            cell.alertDelegate = self
            cell.eventModel = eventResults?[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "AddSchedule", bundle: nil)
        if let addEventViewController = storyboard.instantiateViewController(withIdentifier: "AddScheduleViewController") as? AddEventViewController {
            addEventViewController.eventModel = eventResults?[indexPath.row]
            addEventViewController.date = date
            addEventViewController.allDayDate = allDayDate
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
        calendar.reloadData()
        todayDateOrOtherDate()
    }
}

// MARK: - AddEventViewControllerDelegate
extension CalendarViewController: AddEventViewControllerDelegate {
    func event(addEvent: EventModel) {
        filterEvent(date: addEvent.date)
        calendar.reloadData()
        taskTableView.reloadData()
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
        let allDayDateFormatter = DateFormatter()
        allDayDateFormatter.dateFormat = "yyyy/MM/dd"

        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dateLabel.text = "\(year)年\(month)月\(day)日"
        rokuyouLabel.text = calculateRokuyo(date: date)
        self.date = date.toStringWithCurrentLocale()
        allDayDate = allDayDateFormatter.string(from: date)
        filterEvent(date: date.toStringWithCurrentLocale())
        taskTableView.reloadData()
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        fetchEventModels()
        dateFormat.dateFormat = "yyyy/MM/dd"

        let date = dateFormat.string(from: date)
        fetchEventCounts(date: date)
        var hasEvent: Bool = false
        for eventModel in allEvent where eventModel.date == date {
            hasEvent = true
        }
        if hasEvent {
            return eventCounts.count
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
                return UIColor(named: "calendarBackground")
            default: break

            }
            // 平日のみの表示
        } else if selectedMenuType == .weekday {
            if judgeHoliday(date) {
                return UIColor(named: "calendarBackground")
            }
            let weekday = getWeekIdx(date)
            if weekday == 1 {   // 日曜日
                return UIColor(named: "calendarBackground")
            } else if weekday == 7 {  // 土曜日
                return UIColor(named: "calendarBackground")
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
