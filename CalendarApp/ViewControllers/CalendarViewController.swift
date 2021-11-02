//
//  ViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/09/28.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import DropDown
import RealmSwift

class CalendarViewController: UIViewController {
    
    private let cellId = "cellId"
    private let selectElementDropDown = DropDown()
    private let elementArray = ["週だけ", "土日祝だけ"]
    private let dateFormat = DateFormatter()
    //    var eventModels: [[String:String]] = []
    var eventModel: EventModel?
    var eventModels = [EventModel]()
    
    
    @IBOutlet weak private var calendar: FSCalendar!
    @IBOutlet weak private var taskTableView: UITableView!
    @IBOutlet weak private var addButton: UIButton!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var selectElementButton: UIButton!
    @IBOutlet weak private var selectElementDropDownView: UIView!
    @IBOutlet weak private var elementDropDownButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        setupView()
        setupCalendar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        fetchEvent()
        //        print("fetchEvent", eventModels)
    }
    
    private func setupView() {
        
        taskTableView.dataSource = self
        taskTableView.delegate = self
        
        addButton.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
        elementDropDownButton.addTarget(self, action: #selector(tappedElementDropDownButton), for: .touchUpInside)
        
        taskTableView.register(UINib(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        initSelectElementDropDownMenu()
    }
    
    private func setupCalendar() {
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        
    }
    
    @objc private func tappedElementDropDownButton() {
        
        selectElementDropDown.show()
        
        
    }
    
    @objc private func tappedAddButton() {
        
        let storyboard = UIStoryboard(name: "AddSchedule", bundle: nil)
        let addEventViewController = storyboard.instantiateViewController(withIdentifier: "AddScheduleViewController") as! AddEventViewController
        addEventViewController.modalTransitionStyle = .coverVertical
        addEventViewController.modalPresentationStyle = .fullScreen
        addEventViewController.delegate = self
        self.present(addEventViewController, animated: true, completion: nil)
    }
    
    
    
    private func initSelectElementDropDownMenu() {
        
        selectElementButton.backgroundColor = .clear
        selectElementDropDown.anchorView = selectElementDropDownView
        selectElementDropDown.dataSource = elementArray // [String]
        selectElementDropDown.direction = .bottom
        selectElementDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            // 選択されたときのActionを記載する
            
        }
    }
    
    private func fetchEvent() {
        do {
            let realm = try Realm()
            
            let results = realm.objects(EventModel.self)
            for result in results {
                eventModels.append(result)
                eventModel = result
                
            }
        } catch {
            print("read todo error.")
            
            
        }
        
        taskTableView.reloadData()
    }
    
    private func filterEvent(date: Date) {
        do {
            
            dateFormat.dateFormat = "yyyy/MM/dd"
            
            let date = dateFormat.string(from: date)
            
            let realm = try Realm()
            let filter = realm.objects(EventModel.self).filter("date == '\(date)'")
            
            print("filter", filter)
            
            for result in filter {
                
                if result.date == date {
                    
                    self.eventModels.append(result)
                    print("date", date)
                    
                } else {
                    
                    eventModels = []
                    print("この日は何もありません")
                    return
                }
                
            }
            
        } catch {
            print("read todo error.")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return eventModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = taskTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EventTableViewCell
        cell.delegate = self
        cell.eventModels = self.eventModels
        cell.alertDelegate = self
        cell.eventModel = self.eventModels[indexPath.row]
        
        
        return cell
    }
    
}

// MARK: - EventTableViewCellDelegate
extension CalendarViewController: EventTableViewCellDelegate {
    func notifiCell(eventFromCell: EventModel) {
        
        let realm = try! Realm()
        
        let event = realm.objects(EventModel.self)
        
        do {
            try eventFromCell.realm?.write {
                eventFromCell.realm?.delete(event)
            }
        } catch {
            print("Error \(error)")
        }
        
        fetchEvent()
        taskTableView.reloadData()
        
    }
}

// MARK: - AddEventViewControllerDelegate
extension CalendarViewController: AddEventViewControllerDelegate {
    func event(addEvent: EventModel) {
        
        fetchEvent()
        print("fetchEvent", eventModels)
    }
}

// MARK: - FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance
extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dateLabel.text = "\(year)年\(month)月\(day)日"
        
        
        filterEvent(date: date)
        taskTableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        
        dateFormat.dateFormat = "yyyy/MM/dd"
        
        let date = dateFormat.string(from: date)
        var hasEvent: Bool = false
        for eventModel in eventModels {
            if eventModel["date"] as! String == date {
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
        
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date) {
            return UIColor.red
        }
        
        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
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
