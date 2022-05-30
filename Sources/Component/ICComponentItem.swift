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
    
    public init() {}
    
    public init(date: Date = Date(), isDisplayed: Bool = false, isHighlighted: Bool = false) {
        self.date = date
        self.isDisplayed = isDisplayed
        self.isHighlighted = isHighlighted
    }
}


// MARK: DateHeader
public struct ICDateHeaderItem: ICComponent {
    public var date: Date = Date()
    public var isHighlighted: Bool = false
    
    public init() {}
    
    public init(date: Date = Date(), isHighlighted: Bool = false) {
        self.date = date
        self.isHighlighted = isHighlighted
    }
}


// MARK: AllDayHeader
public struct ICAllDayHeaderItem: ICComponent {
    public var views = [AnyView]()
    public var isExpended: Bool = false
    public var toggle: ((Bool)->Void)?
    
    public init() {}
    
    public init(views: [AnyView] = [], isExpended: Bool = false, toggle: ((Bool)->Void)? = nil) {
        self.views = views
        self.isExpended = isExpended
        self.toggle = toggle
    }
}

public struct ICAllDayCornerItem: ICComponent {
    public var background: Color = .white
    public var itemCount: Int = 0
    public var isExpended: Bool = false
    public var toggle: ((Bool)->Void)?
    
    public init() {}
    
    public init(background: Color = .white, itemCount: Int = 0, isExpended: Bool = false, toggle: ((Bool)->Void)? = nil) {
        self.background = background
        self.itemCount = itemCount
        self.isExpended = isExpended
        self.toggle = toggle
    }
}


// MARK: Timeline
public struct ICTimelineItem: ICComponent {
    public var isDisplayed: Bool = false
    
    public init() {}
    
    public init(isDisplayed: Bool = false) {
        self.isDisplayed = isDisplayed
    }
}


// MARK: Background
public struct ICContentBackgroundItem: ICComponent {
    public var color: Color = .white
    
    public init() {}
    
    public init(color: Color = .white) {
        self.color = color
    }
}
