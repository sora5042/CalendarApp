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

class CalendarViewController: UIViewController {

    let cellId = "cellId"
    let selectElementDropDown = DropDown()
    let elementArray = ["週だけ", "土日祝だけ"]
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectElementButton: UIButton!
    @IBOutlet weak var selectElementDropDownView: UIView!
    @IBOutlet weak var elementDropDownButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCalendar()
        
    }
    
    private func setupView() {
        
        taskTableView.dataSource = self
        taskTableView.delegate = self
        addButton.addTarget(self, action: #selector(tappedAddButton), for: .touchUpInside)
        elementDropDownButton.addTarget(self, action: #selector(tappedElementDropDownButton), for: .touchUpInside)
        initSelectElementDropDownMenu()
    }
    
    @objc private func tappedElementDropDownButton() {
        
        selectElementDropDown.show()
        
        
    }
    
    @objc private func tappedAddButton() {
        
        let storyboard = UIStoryboard(name: "AddSchedule", bundle: nil)
        
        let addScheduleViewController = storyboard.instantiateViewController(withIdentifier: "AddScheduleViewController") as! AddScheduleViewController
        
        addScheduleViewController.modalTransitionStyle = .coverVertical
        addScheduleViewController.modalPresentationStyle = .fullScreen
        self.present(addScheduleViewController, animated: true, completion: nil)
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
    
    private let gregorian: Calendar = Calendar(identifier: .gregorian)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
   private func initSelectElementDropDownMenu() {
        
        selectElementButton.backgroundColor = .clear
        selectElementDropDown.anchorView = selectElementDropDownView
        selectElementDropDown.dataSource = elementArray // [String]
        selectElementDropDown.direction = .bottom
        selectElementDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            // 選択されたときのActionを記載する
    
        }
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = taskTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        return cell
    }
    
}

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
    }
    
    // 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
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
    private func getDay(_ date:Date) -> (Int,Int,Int){
         let tmpCalendar = Calendar(identifier: .gregorian)
         let year = tmpCalendar.component(.year, from: date)
         let month = tmpCalendar.component(.month, from: date)
         let day = tmpCalendar.component(.day, from: date)
         return (year,month,day)
     }
     
     //曜日判定(日曜日:1 〜 土曜日:7)
    private func getWeekIdx(_ date: Date) -> Int{
         let tmpCalendar = Calendar(identifier: .gregorian)
         return tmpCalendar.component(.weekday, from: date)
     }
     
    
}
