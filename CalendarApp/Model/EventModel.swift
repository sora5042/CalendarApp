//
//  EventModel.swift
//  CalendarApp
//
//  Created by 大谷空 on 2021/10/17.
//

import Foundation
import RealmSwift

class EventModel: Object {
    
    @objc dynamic var dateKey = ""
    @objc dynamic var notificationId = ""
    @objc dynamic var title = ""
    @objc dynamic var comment = ""
    @objc dynamic var date = ""
    @objc dynamic var place = ""
    @objc dynamic var startTime = "" //00:00
    @objc dynamic var endTime = "" //00:00
    
    override static func primaryKey() -> String? {
            return "dateKey"
        }
    
}

class EventList: Object {
    
    let eventList = List<EventModel>()
    
}
