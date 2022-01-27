//
//  iOSCalendarSync.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/25.
//

import UIKit
import EventKit
import RealmSwift
import PKHUD

class StandardCalendarAppSync {

    static let eventStore = EKEventStore()

    static func checkAuth() {
        // 現在のアクセス権限の状態を取得
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        if status == .authorized {
            getEvents()
            HUD.flash(.labeledSuccess(title: "同期に成功しました", subtitle: nil), delay: 1)
            print("アクセスできます！！")
        } else if status == .notDetermined {
            // アクセス権限のアラートを送る。
            eventStore.requestAccess(to: EKEntityType.event) { (granted, _) in
                if granted { // 許可されたら
                    DispatchQueue.main.sync {
                        HUD.show(.progress)
                        getEvents()
                        HUD.flash(.labeledSuccess(title: "同期に成功しました", subtitle: nil), delay: 1)
                    }
                    print("アクセス可能になりました。")
                } else { // 拒否されたら
                    print("アクセスが拒否されました。")
                }
            }
        }
    }
    // 認証ステータスを確認する
    static func getAuthorizationStatus() -> Bool {
        // 認証ステータスを取得
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)

        // ステータスを表示 許可されている場合のみtrueを返す
        switch status {
        case .notDetermined:
            print("NotDetermined")
            return false
        case .restricted:
            print("Restricted")
            return false
        case .denied:
            print("Denied")
            return false
        case .authorized:
            print("Authorized")
            return true
        @unknown default:
            return false
        }
    }

    static func getEvents() {
        let today = Date()
        let calendars = eventStore.calendars(for: .event)
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: today)
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: today)
        let predicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: calendars)

        var eventArray: [EKEvent] = []
        eventArray = eventStore.events(matching: predicate)

        for events in eventArray {
            let title = events.title
            let eventId = events.eventIdentifier ?? ""
            let startDate = events.startDate ?? Date()
            let endDate = events.endDate ?? Date()
            Realm.iOSCalendar(eventId: eventId, name: title, startDate: startDate, endDate: endDate, notificationDate: startDate) { success in
                if success {
                    print("イベントデータの取得に成功しました")
                }
            }
        }
    }
}
