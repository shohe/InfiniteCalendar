//
//  Settings.swift
//  Demo
//
//  Created by Shohe Ohtani on 2022/05/21.
//

import Foundation
import InfiniteCalendar

class CustomSettings: ICSettings {
    typealias DateHeaderView = CustomDateHeaderView
    typealias DateHeader = CustomDateHeader
    
    @Published public var numOfDays: Int = 1
    @Published public var initDate: Date = Date()
    @Published public var scrollType: ScrollType = .pageScroll
    @Published public var moveTimeMinInterval: Int = 15
    @Published public var timeRange: (startTime: Int, endTime: Int) = (1, 23)
    @Published public var withVibrateFeedback: Bool = true
    @Published public var datePosition: ICViewUI.DatePosition = .left
    
    required public init() {}
    
    init(numOfDays: Int, setDate: Date) {
        self.numOfDays = numOfDays
        initDate = setDate
        scrollType = (numOfDays == 1 || numOfDays == 7) ? .pageScroll : .sectionScroll
    }
    
    func updateScrollType(numOfDays: Int) {
        self.numOfDays = numOfDays
        scrollType = (numOfDays == 1 || numOfDays == 7) ? .pageScroll : .sectionScroll
    }
}
