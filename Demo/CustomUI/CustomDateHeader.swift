//
//  CustomDateHeader.swift
//  Demo
//
//  Created by Shohe Ohtani on 2022/05/28.
//

import SwiftUI
import InfiniteCalendar

class CustomDateHeader: ICDateHeader<CustomDateHeaderView> {}

struct CustomDateHeaderView: ICDateHeaderView {
    /// When you create custom DateHeader, should set `ICDateHeaderItem` to get property
    public typealias Item = ICDateHeaderItem
    
    var item: Item
    
    var isToday: Bool { return item.date.startOfDay == Date().startOfDay }
    var weekDay: String {
        let weekday = Calendar.current.component(.weekday, from: item.date) - 1
        let weekdayString = DateFormatter().shortWeekdaySymbols[weekday].uppercased()
        return String(weekdayString[weekdayString.startIndex])
    }
    
    private let accentRed = Color(#colorLiteral(red: 0.8823529412, green: 0.2117647059, blue: 0.3019607843, alpha: 1))
    
    public init(_ item: Item) {
        self.item = item
    }
    
    public var body: some View {
        VStack(spacing: 1.0) {
            Text(weekDay)
                .font(.system(size: 10))
                .foregroundColor(isToday ? .white : Color.black.opacity(0.7))
            Text("\(item.date.day)")
                .font(.system(size: 17))
                .foregroundColor(isToday ? .white : .black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 4.0)
                .frame(width: 36.0, height: 36.0)
                .foregroundColor(isToday ? accentRed : .clear)
        )
    }
}


