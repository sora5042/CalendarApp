//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/10/09.
//

import UIKit
import TextFieldEffects
import RealmSwift

protocol AddEventViewControllerDelegate: class {
    
    func event(addEvent: EventModel)
    
//    func eventList(list: List<EventModel>)
    
}

class AddEventViewController: UIViewController {
    
    weak var delegate: AddEventViewControllerDelegate?
    private let dateFormat = DateFormatter()
    var eventModel = EventModel()
    var eventModels = [EventModel]()
    var eventLists: List<EventModel>!
    var eventList = EventList()
    
    @IBOutlet weak private var cancelButton: UIButton!
    @IBOutlet weak private var titleTextField: HoshiTextField!
    @IBOutlet weak private var placeTextField: HoshiTextField!
    @IBOutlet weak private var commentTextField: HoshiTextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak private var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        
        cancelButton.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)
        
        placeTextField.delegate = self
        commentTextField.delegate = self
        titleTextField.delegate = self
        
        
        titleTextField.placeholderColor = .darkGray
        titleTextField.borderInactiveColor = .darkGray
        titleTextField.borderActiveColor = .systemGreen
        titleTextField.placeholderFontScale = 1
        
        placeTextField.placeholderColor = .darkGray
        placeTextField.borderActiveColor = .systemGreen
        placeTextField.borderInactiveColor = .darkGray
        placeTextField.placeholderFontScale = 1
        
        commentTextField.placeholderColor = .darkGray
        commentTextField.borderActiveColor = .systemGreen
        commentTextField.borderInactiveColor = .darkGray
        commentTextField.placeholderFontScale = 1
        
    }
    
    @objc private func tappedSaveButton() {
        
        localNotification()
        delegate?.event(addEvent: eventModel)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func createEvent(notificationId: String) {
        
        dateFormat.dateFormat = "yyyy/MM/dd"
        let dateKeyFormat = DateFormatter()
        dateKeyFormat.dateFormat = "yyyy/MM/dd/HH:mm:ss"
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"
        
        guard let title = titleTextField.text else { return }
        guard let comment = commentTextField.text else { return }
        guard let place = placeTextField.text else { return }
        
        do {
            
            let realm = try Realm()
            
//            let event = [
//
//                EventModel(value: ["dateKey": "\(dateKeyFormat.string(from: startDatePicker.date))", "notificationId": notificationId, "title": title, "comment": comment, "place": place, "date": "\(dateFormat.string(from: startDatePicker.date))", "startTime": "\(timeFormat.string(from: startDatePicker.date))", "endTime": "\(timeFormat.string(from: endDatePicker.date))"])
//            ]
            
            eventModel.dateKey = "\(dateKeyFormat.string(from: startDatePicker.date))"
            eventModel.notificationId = notificationId
            eventModel.title = title
            eventModel.comment = comment
            eventModel.place = place
            eventModel.date = "\(dateFormat.string(from: startDatePicker.date))"
            eventModel.startTime = "\(timeFormat.string(from: startDatePicker.date))"
            eventModel.endTime = "\(timeFormat.string(from: endDatePicker.date))"
            
            try realm.write {
//                eventList.eventList.append(eventModel)
                realm.add(eventModel)
//                self.eventLists = realm.objects(EventList.self).first?.eventList
                //                print("eventModel", eventModel)
                
            }
        } catch {
            print("create todo error.")
        }
    }
    
    private func localNotification() {
        
        guard let titleText = titleTextField.text else { return }
        guard let commentText = commentTextField.text else { return }
        
        // MARK: 通知の中身を設定
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = "\(titleText)の時間です！"
        content.subtitle = commentText
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // MARK: 通知をいつ発動するかを設定
        // カレンダークラスを作成
        let calendar = Calendar.current
        let calendarComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDatePicker.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendarComponents, repeats: true)
        
        // MARK: 通知のリクエストを作成
        let id = UUID().uuidString
        let request: UNNotificationRequest = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        print("notificationId", id)
        createEvent(notificationId: id)
        
        // MARK: 通知のリクエストを実際に登録する
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            
            if error != nil {
                
            } else {
                
            }
        }
    }
    
    @objc private func tappedCancelButton() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
}

extension AddEventViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        placeTextField.resignFirstResponder()
        commentTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        
        return true
    }
}
