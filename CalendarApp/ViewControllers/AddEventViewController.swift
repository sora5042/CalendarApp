//
//  AddScheduleViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/10/09.
//

import UIKit
import TextFieldEffects
import RealmSwift
import PKHUD
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST

protocol AddEventViewControllerDelegate: AnyObject {
    func event(addEvent: EventModel)
}

class AddEventViewController: UIViewController {

    enum SwitchType: String {
        case on = "ON"
        case off = "OFF"
    }

    weak var delegate: AddEventViewControllerDelegate?
    var eventModel: EventModel?
    var eventModels = EventModel()
    private let dateFormat = DateFormatter()
    var date = String()
    var allDayDate = String()
    private var selectedSwitchType = SwitchType.off
    var authorization: GTMAppAuthFetcherAuthorization?

    @IBOutlet private weak var titleTextField: HoshiTextField!
    @IBOutlet private weak var placeTextField: HoshiTextField!
    @IBOutlet private weak var commentTextField: HoshiTextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var notificationDatePicker: UIDatePicker!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var datePickerMenuButton: UIButton!
    @IBOutlet private weak var navigationBarLabel: UILabel!
    @IBOutlet private weak var googleCalendarAddView: UIView!
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
    // MARK: - Method
    private func setupView() {
        let drawView = DrawView(frame: self.datePickerView.bounds)
        self.datePickerView.addSubview(drawView)
        self.datePickerView.sendSubviewToBack(drawView)

        dateFormat.dateFormat = "yyyy/MM/dd"
        let datePicker = dateFormat.date(from: date)
        startDatePicker.date = datePicker ?? Date()
        endDatePicker.date = datePicker ?? Date()
        notificationDatePicker.date = datePicker ?? Date()

        cancelButton.addTarget(self, action: #selector(tappedCancelButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(tappedSaveButton), for: .touchUpInside)
        tappedDatePickerMenuButton()

        dateView.layer.borderWidth = 1.2
        dateView.layer.borderColor = UIColor.lightGray.cgColor
        dateView.layer.cornerRadius = 12
        googleCalendarAddView.layer.borderWidth = 1.2
        googleCalendarAddView.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func setupTextField() {
        placeTextField.delegate = self
        commentTextField.delegate = self
        titleTextField.delegate = self

        titleTextField.text = eventModel?.title
        titleTextField.placeholderFontScale = 0.9
        titleTextField.placeholderColor = .lightGray
        titleTextField.borderInactiveColor = .lightGray
        titleTextField.borderActiveColor = UIColor(named: "textFieldBorderActiveColor")
        titleView.layer.borderWidth = 1.2
        titleView.layer.borderColor = UIColor.lightGray.cgColor
        titleView.layer.cornerRadius = 12

        placeTextField.text = eventModel?.place
        placeTextField.placeholderFontScale = 0.9
        placeTextField.placeholderColor = .lightGray
        placeTextField.borderInactiveColor = .lightGray
        placeTextField.borderActiveColor = UIColor(named: "textFieldBorderActiveColor")
        placeView.layer.borderWidth = 1.2
        placeView.layer.borderColor = UIColor.lightGray.cgColor
        placeView.layer.cornerRadius = 12

        commentTextField.text = eventModel?.comment
        commentTextField.placeholderFontScale = 0.9
        commentTextField.placeholderColor = .lightGray
        commentTextField.borderInactiveColor = .lightGray
        commentTextField.borderActiveColor = UIColor(named: "textFieldBorderActiveColor")
        commentView.layer.borderWidth = 1.2
        commentView.layer.borderColor = UIColor.lightGray.cgColor
        commentView.layer.cornerRadius = 12
    }

    private func newEventOrEditEvent() {
        if eventModel == nil {
            navigationBarLabel.text = "新規作成"
        } else {
            navigationBarLabel.text = "編集"
            startDatePicker.date = eventModel?.editStartTime ?? Date()
            endDatePicker.date = eventModel?.editEndTime ?? Date()
            notificationDatePicker.date = eventModel?.editNotificationTime ?? Date()
            googleCalendarAddView.alpha = 0
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

    private func tappedDatePickerMenuButton() {
        var selectedDatePickerMenu = [UIMenuElement]()

        selectedDatePickerMenu.append(UIAction(title: "終日", handler: { [weak self] _ in
            self?.dateFormat.dateFormat = "yyyy/MM/dd"
            let allDayDate = self?.dateFormat.date(from: self?.allDayDate ?? "")
            let calendar = Calendar(identifier: .gregorian)
            let startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: allDayDate ?? Date())
            let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: allDayDate ?? Date())
            self?.startDatePicker.date = startDate ?? Date()
            self?.endDatePicker.date = endDate ?? Date()
            self?.tappedDatePickerMenuButton()
        }))

        selectedDatePickerMenu.append(UIAction(title: "現在の日時", handler: { [weak self] _ in
            let startDate = Date()
            let endDate = Date()

            self?.startDatePicker.date = startDate
            self?.endDatePicker.date = endDate
            self?.tappedDatePickerMenuButton()
        }))
        selectedDatePickerMenu.append(UIAction(title: "元の日時に戻す", handler: { [weak self] _ in

            self?.dateFormat.dateFormat = "yyyy/MM/dd"
            let datePicker = self?.dateFormat.date(from: self?.date ?? "")
            self?.startDatePicker.date = datePicker ?? Date()
            self?.endDatePicker.date = datePicker ?? Date()
            self?.tappedDatePickerMenuButton()
        }))

        datePickerMenuButton.menu = UIMenu(title: "日時指定", options: .displayInline, children: selectedDatePickerMenu)
        datePickerMenuButton.showsMenuAsPrimaryAction = true
    }

    @IBAction func addGoogleCalendarSwitch(_ sender: UISwitch) {
        guard let title = titleTextField.text else { return }

        if sender.isOn {
            selectedSwitchType = .on
            add(eventName: title, startDateTime: startDatePicker.date, endDateTime: endDatePicker.date)
            print(selectedSwitchType)

        } else {
            selectedSwitchType = .off
            print(selectedSwitchType)
        }
    }

    private func createEvent(notificationId: String) {
        guard let titleText = titleTextField.text else { return }
        guard let commentText = commentTextField.text else { return }
        guard let placeText = placeTextField.text else { return }

        Realm.createEvent(notificationId: notificationId, title: titleText, place: placeText, comment: commentText, startDatePicker: startDatePicker.date, endDatePicker: endDatePicker.date, notificationDatePicker: notificationDatePicker.date) { (success) in

            if success {
                print("イベントデータの保存に成功しました")
            }
        }
    }

    private func updateEvent(notificationId: String) {
        guard let titleText = titleTextField.text else { return }
        guard let commentText = commentTextField.text else { return }
        guard let placeText = placeTextField.text else { return }
        guard let eventId = eventModel?.eventId else { return }

        Realm.updateEvent(eventId: eventId, notificationId: notificationId, title: titleText, place: placeText, comment: commentText, startDatePicker: startDatePicker.date, endDatePicker: endDatePicker.date, notificationDatePicker: notificationDatePicker.date) { success in

            if success {
                print("イベントデータの更新に成功しました")
            }
        }
    }

    private func localNotification() {
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        let titleText = titleTextField.text
        let startTime = timeFormat.string(from: startDatePicker.date)
        let endTime = timeFormat.string(from: endDatePicker.date)
        let placeText = placeTextField.text

        // 通知の中身を設定
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = titleText ?? ""
        content.subtitle = "場所：\(placeText ?? "")"
        content.body = "\(startTime)~\(endTime)"
        content.sound = UNNotificationSound.default
        content.badge = 1

        // 通知をいつ発動するかを設定
        // カレンダークラスを作成
        let calendar = Calendar.current
        let calendarComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDatePicker.date)
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
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        guard let notificationid = eventModel?.notificationId else { return }
        let titleText = titleTextField.text
        let startTime = timeFormat.string(from: startDatePicker.date)
        let endTime = timeFormat.string(from: endDatePicker.date)
        let placeText = placeTextField.text
        // 更新前の通知リクエストを削除
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationid])

        // 通知の中身を設定
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = titleText ?? ""
        content.subtitle = "場所：\(placeText ?? "")"
        content.body = "\(startTime)~\(endTime)"
        content.sound = UNNotificationSound.default
        content.badge = 1
        // 通知をいつ発動するかを設定
        // カレンダークラスを作成
        let calendar: Calendar = Calendar.current
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDatePicker.date), repeats: true)

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

    typealias ShowAuthorizationDialogCallBack = ((Error?) -> Void)
    private func showAuthorizationDialog(callBack: @escaping ShowAuthorizationDialogCallBack) {
        let clientID = "579964048764-q3nu1gpee4h5hjrqa4ubppvvg3g3jrnt.apps.googleusercontent.com"
        let redirectUrl = "com.googleusercontent.apps.579964048764-q3nu1gpee4h5hjrqa4ubppvvg3g3jrnt:/oauthredirect"
        let scopes = ["https://www.googleapis.com/auth/calendar.events"]

        let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
        let redirectURL = URL(string: redirectUrl + ":/oauthredirect")

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
                        //                        GTMAppAuthFetcherAuthorization.save((self?.authorization)!, toKeychainForName: "authorization")
                    }
                }
                callBack(error)
            })
    }
    // このアプリで保存したイベントデータをGoogleカレンダーアプリにも保存するメソッド
    private func add(eventName: String, startDateTime: Date, endDateTime: Date) {
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

    @objc private func tappedCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
