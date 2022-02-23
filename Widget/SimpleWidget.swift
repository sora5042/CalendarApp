//
//  Widget.swift
//  Widget
//
//  Created by 大谷空 on 2022/01/06.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift

@main
struct SimpleWidget: Widget {
    let kind: String = "Widget"
        
        var body: some WidgetConfiguration {
            StaticConfiguration(kind: kind, provider: SimpleWidgetTimeline()) { entry in
                SimpleWidgetEntryView(entry: entry)
            }
            .configurationDisplayName("Re:スケウィジェット")
            .description("カレンダーのウィジェットです")
        }
    }

//struct WidgetWithRealmWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SimpleWidgetEntryView(entry: SimpleWidgetEntry(date: Date(), event: ))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
