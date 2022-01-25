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
import EventKit
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST

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
    var eventResults: Results<EventModel>?
    // カレンダーの緑ぽち用
    var allEvent: Results<EventModel>!
    var eventCounts: Results<EventModel>!

    private let cellId = "cellId"
    private let dateFormat = DateFormatter()
    private var date = String()
    private let todayDate = Date()
    private var todayString = String()
    private var selectedMenuType = MenuType.month
    private var selectDayOfWeekMenuType = DayOfWeekType.sunday
    var authorization: GTMAppAuthFetcherAuthorization?
    let redirectURL = "com.googleusercontent.apps.579964048764-q3nu1gpee4h5hjrqa4ubppvvg3g3jrnt:/oauthredirect"

    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet private weak var taskTableView: UITableView!
    @IBOutlet private weak var selectElementDropDownView: UIView!
    @IBOutlet private weak var calendarInfoView: UIView!
    @IBOutlet private weak var bannerView: GADBannerView!
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
        addButton.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
        elementDropDownButton.addTarget(self, action: #selector(tappedElementDropDownButton), for: .touchUpInside)
        scrollButton.addTarget(self, action: #selector(tappedScrollButton), for: .touchUpInside)
        bulkDeleteButton.addTarget(self, action: #selector(tappedBulkDeleteButton), for: .touchUpInside)
        dayOfWeekSortButton.addTarget(self, action: #selector(tappedDayOfWeekButton), for: .touchUpInside)
        rokuyouLabel.text = calculateRokuyo(date: todayDate)
        calendarInfoView.layer.borderWidth = 2.5
        calendarInfoView.layer.borderColor = UIColor.rgb(red: 235, green: 235, blue: 235).cgColor
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

    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.scrollDirection = .horizontal
        calendar.layer.borderWidth = 2.5
        calendar.layer.borderColor = UIColor.rgb(red: 235, green: 235, blue: 235).cgColor
        calendar.layer.shadowOffset = CGSize(width: 15.0, height: 5.0)
        calendar.layer.shadowColor = UIColor.gray.cgColor
        calendar.layer.shadowOpacity = 1.0
        calendar.layer.shadowRadius = 8
        selectedWeekdayLabels()
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

        displayCalendarMenu.append(UIAction(title: "Googleカレンダーと同期", handler: { [weak self] _ in
            self?.getEvents()
        }))

        displayCalendarMenu.append(UIAction(title: "標準カレンダーアプリと同期", handler: { _ in
            StandardCalendarAppSync.checkAuth()

        }))
        elementDropDownButton.menu = UIMenu(title: "オプション", options: .displayInline, children: displayCalendarMenu)
        elementDropDownButton.showsMenuAsPrimaryAction = true
        elementDropDownButton.setTitle(self.selectedMenuType.rawValue, for: .normal)
    }

    @objc private func tappedDayOfWeekButton() {
        var dayOfWeekMenu = [UIMenuElement]()

        dayOfWeekMenu.append(UIAction(title: DayOfWeekType.sunday.rawValue, state: self.selectDayOfWeekMenuType == DayOfWeekType.sunday ? .on : .off, handler: { [weak self] _ in
            self?.calendar.firstWeekday = 1
            self?.selectDayOfWeekMenuType = .sunday
            self?.selectedWeekdayLabels()
            self?.calendar.reloadData()
            self?.tappedDayOfWeekButton()

        }))

        dayOfWeekMenu.append(UIAction(title: DayOfWeekType.monday.rawValue, state: self.selectDayOfWeekMenuType == DayOfWeekType.monday ? .on : .off, handler: { [weak self] _ in
            self?.calendar.firstWeekday = 2
            self?.selectDayOfWeekMenuType = .monday
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
        todayDateOrOtherDate()
    }

    typealias ShowAuthorizationDialogCallBack = ((Error?) -> Void)
    private func showAuthorizationDialog(callBack: @escaping ShowAuthorizationDialogCallBack) {
        let clientID = "579964048764-q3nu1gpee4h5hjrqa4ubppvvg3g3jrnt.apps.googleusercontent.com"
        let scopes = ["https://www.googleapis.com/auth/calendar", "https://www.googleapis.com/auth/calendar.readonly", "https://www.googleapis.com/auth/calendar.events", "https://www.googleapis.com/auth/calendar.events.readonly"]

        let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
        let redirectURL = URL(string: redirectURL + ":/oauthredirect")

        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              scopes: scopes,
                                              redirectURL: redirectURL!,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            presenting: self,
            callback: { [weak self] (authState, error) in
                if let error = error {
                    HUD.flash(.labeledError(title: "認証に失敗しました", subtitle: nil), delay: 1)
                    NSLog("\(error)")
                } else {
                    if let authState = authState {
                        // 認証情報オブジェクトを生成
                        self?.authorization = GTMAppAuthFetcherAuthorization(authState: authState)
                        GTMAppAuthFetcherAuthorization.save((self?.authorization)!, toKeychainForName: "authorization")
                    }
                }
                callBack(error)
            })
    }

    private func getEvents() {
        let today = Date()
        let startDateTime = Calendar(identifier: .gregorian).date(byAdding: .year, value: -1, to: today)
        let endDateTime = Calendar(identifier: .gregorian).date(byAdding: .year, value: 1, to: today)
        get(startDateTime: startDateTime!, endDateTime: endDateTime!)
    }

    private func get(startDateTime: Date, endDateTime: Date) {
        if let gtmAppAuth = GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization") {
            authorization = gtmAppAuth
        }

        if authorization == nil {
            showAuthorizationDialog(callBack: { [weak self](error) -> Void in
                if error == nil {
                    self?.getCalendarEvents(startDateTime: startDateTime, endDateTime: endDateTime)
                }
            })
        } else {
            getCalendarEvents(startDateTime: startDateTime, endDateTime: endDateTime)
        }
    }

    private func getCalendarEvents(startDateTime: Date, endDateTime: Date) {
        let calendarService = GTLRCalendarService()
        calendarService.authorizer = authorization
        calendarService.shouldFetchNextPages = true

        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.timeMin = GTLRDateTime(date: startDateTime)
        query.timeMax = GTLRDateTime(date: endDateTime)

        calendarService.executeQuery(query, completionHandler: { (_, event, error) -> Void in
            if let error = error {
                HUD.flash(.labeledError(title: "データの取得に失敗しました", subtitle: nil), delay: 1)
                NSLog("\(error)")
            } else {
                if let event = event as? GTLRCalendar_Events, let items = event.items {
                    for item in items {
                        HUD.show(.progress)
                        let id: String = item.identifier ?? ""
                        let name: String = item.summary ?? ""
                        let startDate: Date? = item.start?.dateTime?.date
                        let endDate: Date? = item.end?.dateTime?.date

                        Realm.googleCalendar(id: id, name: name, startDate: startDate ?? Date(), endDate: endDate ?? Date()) { success in
                            if success {
                                print("Googleカレンダーからのデータの取得に成功しました")
                            }
                        }
                    }
                    HUD.flash(.labeledSuccess(title: "同期に成功しました", subtitle: nil), delay: 1)
                }
            }
        })
    }
    // このアプリで保存したイベントデータをGoogleカレンダーアプリにも保存するメソッド
    func add(eventName: String, startDateTime: Date, endDateTime: Date) {
        if GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization") != nil {
            authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization")!
        }

        if authorization == nil {
            showAuthorizationDialog(callBack: { [weak self](error) -> Void in
                if error == nil {
                    self?.addCalendarEvent(eventName: eventName, startDateTime: startDateTime, endDateTime: endDateTime)
                }
            })
        } else {
            addCalendarEvent(eventName: eventName, startDateTime: startDateTime, endDateTime: endDateTime)
        }
    }

    private func addCalendarEvent(eventName: String, startDateTime: Date, endDateTime: Date) {
        let calendarService = GTLRCalendarService()
        calendarService.authorizer = authorization
        calendarService.shouldFetchNextPages = true

        let event = GTLRCalendar_Event()
        event.summary = eventName

        let gtlrDateTimeStart: GTLRDateTime = GTLRDateTime(date: startDateTime)
        let startEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        startEventDateTime.dateTime = gtlrDateTimeStart
        event.start = startEventDateTime

        let gtlrDateTimeEnd: GTLRDateTime = GTLRDateTime(date: endDateTime)
        let endEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        endEventDateTime.dateTime = gtlrDateTimeEnd
        event.end = endEventDateTime

        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        calendarService.executeQuery(query, completionHandler: { (_, _, error) -> Void in
            if let error = error {
                HUD.flash(.labeledError(title: "データの追加に失敗しました", subtitle: nil), delay: 1)
                NSLog("\(error)")
            }
        })
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
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dateLabel.text = "\(year)年\(month)月\(day)日"
        rokuyouLabel.text = calculateRokuyo(date: date)
        self.date = date.toStringWithCurrentLocale()
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
