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
    public var date: Date = Date()
    public var isDisplayed: Bool = false
    public var isHighlighted: Bool = false
}


// MARK: DateHeader
public struct ICDateHeaderItem: ICComponent {
    public var date: Date = Date()
    public var isHighlighted: Bool = false
}


// MARK: AllDayHeader
public struct ICAllDayHeaderItem: ICComponent {
    public var views = [AnyView]()
    public var isExpended: Bool = false
    public var toggle: ((Bool)->Void)?
}

public struct ICAllDayCornerItem: ICComponent {
    public var background: Color = .white
    public var itemCount: Int = 0
    public var isExpended: Bool = false
    public var toggle: ((Bool)->Void)?
}


// MARK: Timeline
public struct ICTimelineItem: ICComponent {
    public var isDisplayed: Bool = false
}


// MARK: Background
public struct ICContentBackgroundItem: ICComponent {
    public var color: Color = .white
}
