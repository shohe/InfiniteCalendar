//
//  ICViewSettings.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/04.
//

import SwiftUI

public protocol ICSettings: ObservableObject {
    // ViewHostableSupplementaryCells
    associatedtype TimeHeaderView: ICTimeHeaderView                 = ICDefaultComponent.D_TimeHeaderView
    associatedtype TimeHeader: ICTimeHeader<TimeHeaderView>         = ICDefaultComponent.TimeHeader
    associatedtype DateHeaderView: ICDateHeaderView                 = ICDefaultComponent.D_DateHeaderView
    associatedtype DateHeader: ICDateHeader<DateHeaderView>         = ICDefaultComponent.DateHeader
    associatedtype DateCornerView: ICDateCornerView                 = ICDefaultComponent.D_DateCornerView
    associatedtype DateCorner: ICDateCorner<DateCornerView>         = ICDefaultComponent.DateCorner
    associatedtype AllDayHeaderView: ICAllDayHeaderView             = ICDefaultComponent.D_AllDayHeaderView
    associatedtype AllDayHeader: ICAllDayHeader<AllDayHeaderView>   = ICDefaultComponent.AllDayHeader
    associatedtype AllDayCornerView: ICAllDayCornerView             = ICDefaultComponent.D_AllDayCornerView
    associatedtype AllDayCorner: ICAllDayCorner<AllDayCornerView>   = ICDefaultComponent.AllDayCorner
    associatedtype TimelineView: ICTimelineView                     = ICDefaultComponent.D_TimelineView
    associatedtype Timeline: ICTimeline<TimelineView>               = ICDefaultComponent.Timeline
    
    // ViewHostableDecorationCells
    associatedtype TimeHeaderBackgroundView: ICTimeHeaderBackgroundView                         = ICDefaultComponent.D_TimeHeaderBackgroundView
    associatedtype TimeHeaderBackground: ICTimeHeaderBackground<TimeHeaderBackgroundView>       = ICDefaultComponent.TimeHeaderBackground
    associatedtype DateHeaderBackgroundView: ICDateHeaderBackgroundView                         = ICDefaultComponent.D_DateHeaderBackgroundView
    associatedtype DateHeaderBackground: ICDateHeaderBackground<DateHeaderBackgroundView>       = ICDefaultComponent.DateHeaderBackground
    associatedtype AllDayHeaderBackgroundView: ICAllDayHeaderBackgroundView                     = ICDefaultComponent.D_AllDayHeaderBackgroundView
    associatedtype AllDayHeaderBackground: ICAllDayHeaderBackground<AllDayHeaderBackgroundView> = ICDefaultComponent.AllDayHeaderBackground
    
    
    var numOfDays: Int { get set }
    var initDate: Date { get set }
    var scrollType: ScrollType { get set }
    var moveTimeMinInterval: Int { get set }
    var timeRange: (startTime: Int, endTime: Int) { get set }
    var withVibrateFeedback: Bool { get set }
    var datePosition: ICViewUI.DatePosition { get set }
    
    /* TODO: for future
     var viewType: ViewType
     var firstDayOfWeek: DayOfWeek?
     var hourGridDivision: JZHourGridDivision
     var scrollableRange: (startDate: Date?, endDate: Date?)
    */
    
    init()
}


// * If want to use custom components, create subclass and define new class to each typealias. *
// DON'T ADD new property to subclass, it wont be used.
open class ICViewSettings: ICSettings {
    @Published public var numOfDays: Int = 1
    @Published public var initDate: Date = Date()
    @Published public var scrollType: ScrollType = .pageScroll
    @Published public var moveTimeMinInterval: Int = 15
    @Published public var timeRange: (startTime: Int, endTime: Int) = (1, 23)
    @Published public var withVibrateFeedback: Bool = true
    @Published public var datePosition: ICViewUI.DatePosition = .left
    
    required public init() { }
}
