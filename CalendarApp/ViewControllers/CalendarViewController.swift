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

class CalendarViewController: UIViewController {
    
    enum MenuType: String {
        case month = "月表示"
        case week = "週表示"
        case holiday = "土日祝のみ"
        case weekday = "平日のみ"
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
    
    @IBOutlet weak private var calendar: FSCalendar!
    @IBOutlet weak private var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak private var taskTableView: UITableView!
    @IBOutlet weak private var addButton: UIButton!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var selectElementButton: UIButton!
    @IBOutlet weak private var selectElementDropDownView: UIView!
    @IBOutlet weak private var elementDropDownButton: UIButton!
    @IBOutlet weak private var scrollButton: UIButton!
    @IBOutlet weak private var bulkDeleteButton: UIButton!
    @IBOutlet weak private var rokuyouLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        dateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd", options: 0, locale: Locale(identifier: "ja_JP"))
        todayString = dateFormat.string(from: todayDate)
        
        print("todayString", todayString)
        
        setupView()
        setupCalendar()
        filterEvent(date: todayString)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if date == "" {
            print("date", date)
            return
            
        } else {
            
            filterEvent(date: date)
        }
    }
    
    private func setupView() {
        
        taskTableView.dataSource = self
        taskTableView.delegate = self
        taskTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        dateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateLabel.text = dateFormat.string(from: todayDate)
        addButton.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
        elementDropDownButton.addTarget(self, action: #selector(tappedElementDropDownButton), for: .touchUpInside)
        scrollButton.addTarget(self, action: #selector(tappedScrollButton), for: .touchUpInside)
        bulkDeleteButton.addTarget(self, action: #selector(tappedBulkDeleteButton), for: .touchUpInside)
        
        rokuyouLabel.text = calculateRokuyo(date: todayDate)
    }
    
    private func setupCalendar() {
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .horizontal
        calendar.layer.borderWidth = 2.2
        calendar.layer.borderColor = UIColor.lightGray.cgColor
        
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
    }
    
    @objc private func tappedElementDropDownButton() {
        
        var actions = [UIMenuElement]()
        
        actions.append(UIAction(title: MenuType.month.rawValue, image: UIImage(named: "calendar1"), state: self.selectedMenuType == MenuType.month ? .on : .off, handler: { [weak self] _ in
            
            if self?.calendar.scope == .week {
                self?.calendar.scope = .month
                self?.calendar.setScope(.month, animated: true)
            }
            self?.selectedMenuType = .month
            self?.calendar.reloadData()
            self?.tappedElementDropDownButton()
        }))
        
        actions.append(UIAction(title: MenuType.week.rawValue, image: UIImage(named: "calendar2"), state: self.selectedMenuType == MenuType.week ? .on : .off, handler: { [weak self] _ in
            
            if self?.calendar.scope == .month {
                self?.calendar.scope = .week
                self?.calendar.setScope(.week, animated: true)
            }
            self?.selectedMenuType = .week
            self?.calendar.reloadData()
            self?.tappedElementDropDownButton()
        }))
        
        actions.append( UIAction(title: MenuType.holiday.rawValue, image: UIImage(named: "calendar3"), state: self.selectedMenuType == MenuType.holiday ? .on : .off, handler: { [weak self] _ in
            
            self?.calendar.reloadData()
            self?.selectedMenuType = .holiday
            self?.tappedElementDropDownButton()
            
        }))
        
        actions.append( UIAction(title: MenuType.weekday.rawValue, image: UIImage(named: "calendar3"), state: self.selectedMenuType == MenuType.weekday ? .on : .off, handler: { [weak self] _ in
            
            self?.selectedMenuType = .weekday
            self?.calendar.reloadData()
            self?.tappedElementDropDownButton()
            
        }))
        
        elementDropDownButton.menu = UIMenu(title: "", options: .displayInline, children: actions)
        elementDropDownButton.showsMenuAsPrimaryAction = true
        elementDropDownButton.setTitle(self.selectedMenuType.rawValue, for: .normal)
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
        
        let alert = UIAlertController(title: "アラート表示", message: "本当に一括削除しても良いですか？", preferredStyle: UIAlertController.Style.alert)
        let clearAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default) { [self] (action: UIAlertAction) in
            
            bulkDelete()
        }
        
        alert.addAction(clearAction)
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func bulkDelete() {
        
        let realm = try! Realm()
        let result: Results<EventModel>!
        var eventModel =  [EventModel]()
        let event = realm.objects(EventModel.self).filter("date == '\(date)'")
        
        if date == "" {
            
            result = realm.objects(EventModel.self).filter("date == '\(todayString)'")
            
        } else {
            
            result = realm.objects(EventModel.self).filter("date == '\(date)'")
        }
        
        for results in event {
            eventModel.append(results)
        }
        
        let notificationIdArray = eventModel.map ({ (eventNotificationId) -> String in
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
        filterEvent(date: date)
    }
    
    private func fetchEventModels() {
        
        eventCounts = realm.objects(EventModel.self)
    }
    
    private func filterEvent(date: String) {
        
        eventResults = realm.objects(EventModel.self).filter("date == '\(date)'").sorted(byKeyPath: "editStartTime", ascending: true)
        
        print("filter", eventResults)
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
        filterEvent(date: date)
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
        for eventModel in eventCounts {
            if eventModel["date"] as? String == date {
                hasEvent = true
            }
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
            if weekday == 1 {   //日曜日
                return UIColor.red
            }
            else if weekday == 7 {  //土曜日
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
            if weekday == 1 {   //日曜日
                return UIColor.white
            }
            else if weekday == 7 {  //土曜日
                return UIColor.white
                
            }
            
        } else {
            
            //祝日判定をする（祝日は赤色で表示する）
            if judgeHoliday(date) {
                return UIColor.red
            }
            
            //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
            let weekday = getWeekIdx(date)
            if weekday == 1 {   //日曜日
                return UIColor.red
            }
            else if weekday == 7 {  //土曜日
                return UIColor.blue
            }
        }
        
        return nil
    }
    
    private func judgeHoliday(_ date : Date) -> Bool {
        //祝日判定用のカレンダークラスのインスタンス
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
    private func getDay(_ date:Date) -> (Int,Int,Int) {
        
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
        
    }
    
    //曜日判定(日曜日:1 〜 土曜日:7)
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
