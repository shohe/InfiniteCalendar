//
//  ICViewSettings.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/04.
//

import UIKit
import SwiftUI


public protocol ICSettings: AnyObject {
    associatedtype TimeHeader
    associatedtype TimeHeaderBackground
    associatedtype DateHeader
    associatedtype DateHeaderBackground
    associatedtype DateHeaderCorner
    associatedtype AllDayHeader
    associatedtype AllDayHeaderBackground
    associatedtype AllDayHeaderCorner
    
    
    var numOfDays: Int { get set }
    var initDate: Date { get set }
    var scrollType: ScrollType { get set }
    var moveTimeMinInterval: Int { get set }
    var timeRange: (startTime: Int, endTime: Int) { get set }
    
    /* TODO: for future
     var viewType: ViewType
     var firstDayOfWeek: DayOfWeek?
     var hourGridDivision: JZHourGridDivision
     var scrollableRange: (startDate: Date?, endDate: Date?)
    */
}


// * If want to use custom components, create subclass and define new class to each typealias. *
// DON'T ADD new property to subclass, it wont be used.
open class ICViewSettings: ICSettings, ObservableObject {
    public typealias TimeHeader = ICTHeader
    public typealias TimeHeaderBackground = ICTHeaderBackground
    public typealias DateHeader = ICDHeader
    public typealias DateHeaderBackground = ICDHeaderBackground
    public typealias DateHeaderCorner = ICDCorner
    public typealias AllDayHeader = ICAllDayHeader
    public typealias AllDayHeaderBackground = ICAllDayHeaderBackground
    public typealias AllDayHeaderCorner = ICAllDayCorner
    public typealias Timeline = ICTimeline
    
    
    @Published public var numOfDays: Int
    @Published public var initDate: Date
    @Published public var scrollType: ScrollType
    @Published public var moveTimeMinInterval: Int
    @Published public var timeRange: (startTime: Int, endTime: Int)
    
    // option
    @Published public var withVibrateFeedback: Bool = true
    
    
    public init(
        numOfDays: Int = 1,
        initDate: Date = Date(),
        scrollType: ScrollType = .pageScroll,
        moveTimeMinInterval: Int = 15,
        timeRange: (startTime: Int, endTime: Int) = (1, 23),
        withVibration: Bool = true
    ) {
        self.numOfDays = numOfDays
        self.initDate = initDate
        self.scrollType = scrollType
        self.moveTimeMinInterval = moveTimeMinInterval
        self.timeRange = timeRange
        self.withVibrateFeedback = withVibration
    }
}
