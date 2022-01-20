//
//  GoogleCalendarSync.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/14.
//

import UIKit
import RealmSwift
import AppAuth
import GTMAppAuth
import PKHUD
import GoogleAPIClientForREST

class GoogleCalendarSync {

    static var authorization: GTMAppAuthFetcherAuthorization?
    static let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
    static let clientID = "579964048764-q3nu1gpee4h5hjrqa4ubppvvg3g3jrnt.apps.googleusercontent.com"
    static let redirectURL = "com.googleusercontent.apps.579964048764-q3nu1gpee4h5hjrqa4ubppvvg3g3jrnt:/oauthredirect"

    typealias ShowAuthorizationDialogCallBack = ((Error?) -> Void)
    static func showAuthorizationDialog(callBack: @escaping ShowAuthorizationDialogCallBack) {
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
        let calendarViewController = CalendarViewController()
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            presenting: calendarViewController,
            callback: { (authState, error) in
                if let error = error {
                    HUD.flash(.labeledError(title: "認証に失敗しました", subtitle: nil), delay: 1)
                    NSLog("\(error)")
                } else {
                    if let authState = authState {
                        // 認証情報オブジェクトを生成
                        authorization = GTMAppAuthFetcherAuthorization(authState: authState)
                        GTMAppAuthFetcherAuthorization.save(authorization!, toKeychainForName: "authorization")
                    }
                }
                callBack(error)
            })
    }

    static func getEvents() {
        let today = Date()
        let startDateTime = Calendar(identifier: .gregorian).date(byAdding: .year, value: -1, to: today)
        let endDateTime = Calendar(identifier: .gregorian).date(byAdding: .year, value: 1, to: today)
        get(startDateTime: startDateTime!, endDateTime: endDateTime!)
    }

    static func get(startDateTime: Date, endDateTime: Date) {
        if let gtmAppAuth = GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization") {
            authorization = gtmAppAuth
        }

        if authorization == nil {
            showAuthorizationDialog(callBack: {(error) -> Void in
                if error == nil {
                    getCalendarEvents(startDateTime: startDateTime, endDateTime: endDateTime)
                }
            })
        } else {
            getCalendarEvents(startDateTime: startDateTime, endDateTime: endDateTime)
        }
    }

    static func getCalendarEvents(startDateTime: Date, endDateTime: Date) {
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
                }
            }
        })
    }
    // このアプリで保存したイベントデータをGoogleカレンダーアプリにも保存するメソッド
    static func add(eventName: String, startDateTime: Date, endDateTime: Date) {
        if GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization") != nil {
            authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization")!
        }

        if authorization == nil {
            showAuthorizationDialog(callBack: {(error) -> Void in
                if error == nil {
                    addCalendarEvent(eventName: eventName, startDateTime: startDateTime, endDateTime: endDateTime)
                }
            })
        } else {
            addCalendarEvent(eventName: eventName, startDateTime: startDateTime, endDateTime: endDateTime)
        }
    }

    static func addCalendarEvent(eventName: String, startDateTime: Date, endDateTime: Date) {
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

}
