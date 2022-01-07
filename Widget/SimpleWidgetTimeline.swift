//
//  SimpleWidgetTimeline.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/06.
//

import SwiftUI
import WidgetKit

struct SimpleWidgetTimeline: TimelineProvider {
    typealias Entry = SimpleWidgetEntry
    
    func placeholder(in context: Context) -> SimpleWidgetEntry {
        SimpleWidgetEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleWidgetEntry) -> Void) {
        let entry = SimpleWidgetEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleWidgetEntry>) -> Void) {
        var entries: [SimpleWidgetEntry] = []
        let currentDate = Date()
        
        for dayOffSet in 0..<7 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: dayOffSet, to: currentDate)!
            let entry = SimpleWidgetEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

