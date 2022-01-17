//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/10/09.
//

import UIKit
import TextFieldEffects
import RealmSwift

protocol AddEventViewControllerDelegate: AnyObject {
    func event(addEvent: EventModel)
}

class AddEventViewController: UIViewController {

    weak var delegate: AddEventViewControllerDelegate?
    var eventModel: EventModel?
    var eventModels = EventModel()
    private let dateFormat = DateFormatter()
    var date = String()

    @IBOutlet private weak var titleTextField: HoshiTextField!
    @IBOutlet private weak var placeTextField: HoshiTextField!
    @IBOutlet private weak var commentTextField: HoshiTextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var noticationDatePicker: UIDatePicker!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var navigationBarLabel: UILabel!
    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var dateView: UIView!
    @IBOutlet private weak var placeView: UIView!
    @IBOutlet private weak var commentView: UIView!
    @IBOutlet private weak var datePickerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTextField()
        newEventOrEditEvent()
    }

    private func setupView() {
        let drawView = DrawView(frame: self.datePickerView.bounds)
        self.datePickerView.addSubview(drawView)
        self.datePickerView.sendSubviewToBack(drawView)

        dateFormat.dateFormat = "yyyy/MM/dd"
        let datePicker = dateFormat.date(from: date)
        startDatePicker.date = datePicker ?? Date()
        endDatePicker.date = datePicker ?? Date()
        noticationDatePicker.date = datePicker ?? Date()

        cancelButton.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)

        dateView.layer.borderWidth = 1.2
        dateView.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func setupTextField() {
        placeTextField.delegate = self
        commentTextField.delegate = self
        titleTextField.delegate = self

        titleTextField.text = eventModel?.title
        titleTextField.placeholderColor = .darkGray
        titleTextField.borderInactiveColor = .darkGray
        titleTextField.borderActiveColor = .systemGreen
        titleTextField.placeholderFontScale = 1
        titleView.layer.borderWidth = 1.2
        titleView.layer.borderColor = UIColor.lightGray.cgColor

        placeTextField.text = eventModel?.place
        placeTextField.placeholderColor = .darkGray
        placeTextField.borderActiveColor = .systemGreen
        placeTextField.borderInactiveColor = .darkGray
        placeTextField.placeholderFontScale = 1
        placeView.layer.borderWidth = 1.2
        placeView.layer.borderColor = UIColor.lightGray.cgColor

        commentTextField.text = eventModel?.comment
        commentTextField.placeholderColor = .darkGray
        commentTextField.borderActiveColor = .systemGreen
        commentTextField.borderInactiveColor = .darkGray
        commentTextField.placeholderFontScale = 1
        commentView.layer.borderWidth = 1.2
        commentView.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func newEventOrEditEvent() {
        if eventModel == nil {
            navigationBarLabel.text = "新規イベント"
        } else {
            navigationBarLabel.text = "編集"
            startDatePicker.date = eventModel?.editStartTime ?? Date()
            endDatePicker.date = eventModel?.editEndTime ?? Date()
            noticationDatePicker.date = eventModel?.editNotificationTime ?? Date()
        }
    }

    @objc private func tappedSaveButton() {
        if eventModel == nil {
            localNotification()
        } else {
            updateLocalNotification()
        }
        delegate?.event(addEvent: eventModels)
        dismiss(animated: true, completion: nil)
    }

    private func createEvent(notificationId: String) {
        dateFormat.dateFormat = "yyyy/MM/dd"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        let eventId = UUID().uuidString
        guard let title = titleTextField.text else { return }
        guard let comment = commentTextField.text else { return }
        guard let place = placeTextField.text else { return }

        do {
            let realm = try Realm()

            eventModels.eventId = eventId
            eventModels.notificationId = notificationId
            eventModels.title = title
            eventModels.place = place
            eventModels.comment = comment
            eventModels.editStartTime = startDatePicker.date
            eventModels.editEndTime = endDatePicker.date
            eventModels.editNotificationTime = noticationDatePicker.date
            eventModels.date = dateFormat.string(from: startDatePicker.date)
            eventModels.startTime = timeFormat.string(from: startDatePicker.date)
            eventModels.endTime = timeFormat.string(from: endDatePicker.date)

            try realm.write {
                realm.add(eventModels)
            }
        } catch {
            print("create todo error.")
        }
    }

    private func updateEvent(notificationId: String) {
        dateFormat.dateFormat = "yyyy/MM/dd"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        guard let eventId = eventModel?.eventId else { return }
        guard let title = titleTextField.text else { return }
        guard let comment = commentTextField.text else { return }
        guard let place = placeTextField.text else { return }

        do {
            let realm = try Realm()

            eventModels.eventId = eventId
            eventModels.notificationId = notificationId
            eventModels.title = title
            eventModels.place = place
            eventModels.comment = comment
            eventModels.editStartTime = startDatePicker.date
            eventModels.editEndTime = endDatePicker.date
            eventModels.editNotificationTime = noticationDatePicker.date
            eventModels.date = dateFormat.string(from: startDatePicker.date)
            eventModels.startTime = timeFormat.string(from: startDatePicker.date)
            eventModels.endTime = timeFormat.string(from: endDatePicker.date)

            try realm.write {
                realm.add(eventModels, update: .modified)
            }
        } catch {
            print("create todo error.")
        }
    }

    private func localNotification() {
        let titleText = titleTextField.text
        let commentText = commentTextField.text
        let placeText = placeTextField.text

        // 通知の中身を設定
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = titleText ?? ""
        content.subtitle = "場所：\(placeText ?? "")"
        content.body = commentText ?? ""
        content.sound = UNNotificationSound.default
        content.badge = 1

        // 通知をいつ発動するかを設定
        // カレンダークラスを作成
        let calendar = Calendar.current
        let calendarComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: noticationDatePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendarComponents, repeats: true)

        // 通知のリクエストを作成
        let id = UUID().uuidString
        let request: UNNotificationRequest = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        createEvent(notificationId: id)

        // MARK: 通知のリクエストを実際に登録する
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            if let error = error {
                print("プッシュ通知の作成に失敗しました", error)
                return
            } else {
            }
        }
    }

    private func updateLocalNotification() {
        guard let notificationid = eventModel?.notificationId else { return }
        let titleText = titleTextField.text
        let commentText = commentTextField.text
        let placeText = placeTextField.text
        // 更新前の通知リクエストを削除
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationid])

        // 通知の中身を設定
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = titleText ?? ""
        content.subtitle = "場所：\(placeText ?? "")"
        content.body = commentText ?? ""
        content.sound = UNNotificationSound.default
        content.badge = 1
        // 通知をいつ発動するかを設定
        // カレンダークラスを作成
        let calendar: Calendar = Calendar.current
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: noticationDatePicker.date), repeats: true)

        // 通知のリクエストを作成
        let newId = UUID().uuidString
        let request: UNNotificationRequest = UNNotificationRequest(identifier: newId, content: content, trigger: trigger)
        updateEvent(notificationId: newId)
        // 通知のリクエストを実際に登録する
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            if let error = error {
                print("プッシュ通知の作成に失敗しました", error)
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override var shouldAutorotate: Bool {
        return false
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
