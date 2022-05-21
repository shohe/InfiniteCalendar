//
//  ICComponentItem.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/26.
//

import Foundation
import SwiftUI


// MARK: TimeHeader
public struct ICTimeHeaderItem: ICComponent {
    var date: Date = Date()
    var isDisplayed: Bool = false
    var isHighlighted: Bool = false
}


// MARK: DateHeader
public struct ICDateHeaderItem: ICComponent {
    var date: Date = Date()
    var isHighlighted: Bool = false
}


// MARK: AllDayHeader
public struct ICAllDayHeaderItem: ICComponent {
    var views = [AnyView]()
    var isExpended: Bool = false
    var toggle: ((Bool)->Void)?
}

public struct ICAllDayCornerItem: ICComponent {
    var background: Color = .white
    var itemCount: Int = 0
    var isExpended: Bool = false
    var toggle: ((Bool)->Void)?
}


// MARK: Timeline
public struct ICTimelineItem: ICComponent {
    var isDisplayed: Bool = false
}


// MARK: Background
public struct ICContentBackgroundItem: ICComponent {
    var color: Color = .white
}
