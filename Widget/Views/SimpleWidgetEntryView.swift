//
//  SimpleWidgetEntryView.swift
//  CalendarApp
//
//  Created by 大谷空 on 2022/01/06.
//

import SwiftUI

struct SimpleWidgetEntryView: View {
    let entry: SimpleWidgetEntry
    
    var body: some View {
        ZStack {
            VStack (spacing: 5) {
                Text(getMonth())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .background(Rectangle().fill(Color.red))
                Text(getDay())
                Text(getDate())
                    .font(.largeTitle)
            }
            .background(Rectangle().fill(Color.gray))
            .padding(20)
            .clipShape(Circle())
            .shadow(color: .gray, radius: 5, x: 5, y: 5)
        }.edgesIgnoringSafeArea(.all)
    }
    
    private func getDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: entry.date)
    }
    
    private func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: entry.date)
    }
    
    private func getMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: entry.date)
    }
}
