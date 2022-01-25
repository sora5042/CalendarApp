//
//  Realm.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/20.
//

import UIKit
import RealmSwift

extension Realm {

    static func createEvent(notificationId: String, title: String?, place: String?, comment: String?, startDatePicker: Date, endDatePicker: Date, notificationDatePicker: Date, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        let eventId = UUID().uuidString
        guard let title = title else { return }
        guard let comment = comment else { return }
        guard let place = place else { return }

        let eventModels = EventModel()

        do {
            let realm = try Realm()

            eventModels.eventId = eventId
            eventModels.notificationId = notificationId
            eventModels.title = title
            eventModels.place = place
            eventModels.comment = comment
            eventModels.editStartTime = startDatePicker
            eventModels.editEndTime = endDatePicker
            eventModels.editNotificationTime = notificationDatePicker
            eventModels.date = dateFormatter.string(from: startDatePicker)
            eventModels.startTime = timeFormat.string(from: startDatePicker)
            eventModels.endTime = timeFormat.string(from: endDatePicker)

            try realm.write {
                realm.add(eventModels)
            }
        } catch {
            print("create todo error.")
        }
    }

    static func updateEvent(eventId: String, notificationId: String, title: String?, place: String?, comment: String?, startDatePicker: Date, endDatePicker: Date, notificationDatePicker: Date, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        guard let title = title else { return }
        guard let comment = comment else { return }
        guard let place = place else { return }

        let eventModels = EventModel()

        do {
            let realm = try Realm()

            eventModels.eventId = eventId
            eventModels.notificationId = notificationId
            eventModels.title = title
            eventModels.place = place
            eventModels.comment = comment
            eventModels.editStartTime = startDatePicker
            eventModels.editEndTime = endDatePicker
            eventModels.editNotificationTime = notificationDatePicker
            eventModels.date = dateFormatter.string(from: startDatePicker)
            eventModels.startTime = timeFormat.string(from: startDatePicker)
            eventModels.endTime = timeFormat.string(from: endDatePicker)

            try realm.write {
                realm.add(eventModels, update: .modified)
            }
        } catch {
            print("create todo error.")
        }
    }

    static func googleCalendar(id: String, name: String?, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        guard let name = name else { return }

        do {
            let realm = try Realm()
            let eventModels = EventModel()

            try realm.write {
                eventModels.eventId = id
                eventModels.title = name
                eventModels.editStartTime = startDate
                eventModels.editEndTime = endDate
                eventModels.date = dateFormatter.string(from: startDate)
                eventModels.startTime = timeFormat.string(from: startDate)
                eventModels.endTime = timeFormat.string(from: endDate)
                realm.add(eventModels, update: .modified)
            }
        } catch {
            print("create todo error.")
        }

    }

    static func iOSCalendar(eventId: String, name: String?, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "HH:mm"

        guard let name = name else { return }
        let eventId = eventId

        do {
            let realm = try Realm()
            let eventModels = EventModel()

            try realm.write {
                eventModels.eventId = eventId
                eventModels.title = name
                eventModels.editStartTime = startDate
                eventModels.editEndTime = endDate
                eventModels.date = dateFormatter.string(from: startDate)
                eventModels.startTime = timeFormat.string(from: startDate)
                eventModels.endTime = timeFormat.string(from: endDate)
                realm.add(eventModels, update: .modified)
            }
        } catch {
            print("create todo error.")
        }

    }

}
