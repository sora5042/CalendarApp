//
//  ContainerTableViewController.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/27.
//

import UIKit
import AppAuth
import GTMAppAuth
import GoogleAPIClientForREST
import PKHUD
import RealmSwift

class ContainerTableViewController: UITableViewController, UNUserNotificationCenterDelegate {

    var authorization: GTMAppAuthFetcherAuthorization?

    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // アプリのバージョン
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
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
        //        if let gtmAppAuth = GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization") {
        //            authorization = gtmAppAuth
        //        }

        if authorization == nil {
            showAuthorizationDialog(callBack: { [weak self] (error) -> Void in
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
                        let notificationId = UUID().uuidString

                        StandardCalendarAppSync.calendarSyncNotification(notificaitonId: notificationId, name: name, notificationDate: startDate ?? Date(), endDate: endDate ?? Date())
                        Realm.googleCalendar(id: id, notificationId: notificationId, name: name, startDate: startDate ?? Date(), endDate: endDate ?? Date(), notificationDate: startDateTime) { success in
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 2:
                if let url = URL(string: "https://itunes.apple.com/app/id1607735456?action=write-review") {
                    UIApplication.shared.open(url)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            case 3:
                guard let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSdkKuELsVccoESxOyN0F8Br4nw8k5Mh4V-6_qzToiGa2SYrsA/viewform?usp=sf_link") else { return }
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            case 4:
                guard let url = URL(string: "https://sora.sakurai-lab.info/プライバシーポリシー") else { return }
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            default:
                break
            }
        }

        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                requestNotification()
                StandardCalendarAppSync.checkAuth()
                tableView.deselectRow(at: indexPath, animated: true)
            case 1:
                requestNotification()
                getEvents()
                tableView.deselectRow(at: indexPath, animated: true)
            default:
                break
            }
        }
    }
}
