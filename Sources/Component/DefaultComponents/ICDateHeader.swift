//
//  ICDateHeader.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI


// MARK: DateHeader
public extension ICDefaultComponent {
    class DateHeader: ICDateHeader<D_DateHeaderView> {}
    
    struct D_DateHeaderView: ICDateHeaderView {
        public typealias Item = ICDateHeaderItem
        var item: Item
        var isToday: Bool { return item.date.startOfDay == Date().startOfDay }
        var weekDay: String {
            let weekday = Calendar.current.component(.weekday, from: item.date) - 1
            return DateFormatter().shortWeekdaySymbols[weekday].uppercased()
        }
        
        public init(_ item: Item) {
            self.item = item
        }
        
        public var body: some View {
            VStack(spacing: 1.0) {
                Text(weekDay)
                    .font(.system(size: 10))
                    .foregroundColor(isToday ? .blue : Color.black.opacity(0.7))
                ZStack {
                    Circle()
                        .frame(width: 36.0, height: 36.0)
                        .foregroundColor(isToday ? .blue : .clear)
                    Text("\(item.date.day)")
                        .font(.system(size: 17))
                        .foregroundColor(isToday ? .white : .black)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


// MARK: DateHeaderCorner
public extension ICDefaultComponent {
    class DateCorner: ICDateCorner<D_DateCornerView> {}
    
    struct D_DateCornerView: ICDateCornerView {
        public typealias Item = ICContentBackgroundItem
        var item: Item
        
        public init(_ item: Item) {
            self.item = item
        }
        
        public var body: some View {
            VStack {
                item.color
            }
        }
    }
}



// MARK: DateHeaderBackground
public extension ICDefaultComponent {
    class DateHeaderBackground: ICDateHeaderBackground<D_DateHeaderBackgroundView> {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup(item: ICContentBackgroundItem())
        }
    }
    
    struct D_DateHeaderBackgroundView: ICDateHeaderBackgroundView {
        public typealias Item = ICContentBackgroundItem
        var item: Item
        
        public init(_ item: Item) {
            self.item = item
        }
        
        public var body: some View {
            ZStack {
                item.color
            }.shadow(color: Color.black.opacity(0.25), radius: 1.0, x: 0.0, y: 3.0)
        }
    }
}
