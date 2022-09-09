//
//  ICViewHelper.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI

public enum ICViewKinds {
    public enum Supplementary {
        public static let eventCell = "eventCell"
    }
    public enum Decoration {
        public static let verticalGridline = "VerticalGridline"
        public static let horizontalGridline = "HorizontalGridline"
    }
}

/// For checking scrollView(collectionView) currently scrolling direction
public struct ScrollDirection {
    public enum Direction {
        case horizontal
        case vertical
        
        // for autoScroll
        case top
        case bottom
        case left
        case right
        case neutral
    }
    
    /// scrolling direction
    public let direction: Direction
    
    /// locked at curtain x or y value, nil means not locked, similar to previous initialContentOffset but put it in direction
    public let lockedAt: CGFloat?
    
    /// used for auto scroll
    public var autoScrollOffset: CGFloat?
    
    /// interval time for horizontal auto scroll
    public var interval: Int = 0
    
    public init(direction: Direction, lockedAt: CGFloat?) {
        self.direction = direction
        self.lockedAt = lockedAt
        self.autoScrollOffset = nil
    }
    
    public init(direction: Direction, autoScrollOffset: CGFloat?) {
        self.direction = direction
        self.autoScrollOffset = autoScrollOffset
        self.lockedAt = nil
    }
}

/// For checking scrollView(collectionView) currently scrolling  paging direction
public struct PagingDirection {
    public enum Direction {
        case previous
        case next
        case stay
    }
    
    public let direction: Direction   // final page direction
    public let scrollingTo: Direction // scrolling direction (previous or next)
    
    public init(_ collectionView: UICollectionView) {
        let minOffsetX: CGFloat = 0, maxOffsetX = collectionView.contentSize.width - collectionView.frame.width
        let currentOffsetX = collectionView.contentOffset.x
        var direction: Direction = .stay
        if currentOffsetX >= maxOffsetX { direction = .next }
        if currentOffsetX <= minOffsetX { direction = .previous }
        self.direction = direction
        self.scrollingTo = (currentOffsetX == 0.0) ? .stay : (currentOffsetX > maxOffsetX / 2) ? .next : .previous
    }
}

public enum EditState {
    case moving
    case resizing
}

public enum ScrollType {
    case pageScroll
    case sectionScroll
}

public enum WeekDay: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

public enum LongTapType {
    /// When long tap position is not on  a existed cell, it will create a new cell
    case addNew
    /// When long tap position is on  a existed cell, it will allow user to move the existed cell
    case move
}

public enum SupplementKind {
    case timeHeader(ICTimeHeaderItem?)
    case timeHeaderBackground
    
    case dateCorner
    case dateHeader
    case dateHeaderBackground
    
    case allDayHeader
    case allDayHeaderBackground
    case allDayCorner
    
    case timeline
}

open class ICViewHelper {
    
    /**
     Get calculated events dictionary with intraStartTime and intraEndTime
     - Parameters:
        - events: A list of original Events (subclassed from BaseEvent)
     - Returns:
        A dictionary used by JZBaseWeekView. Key is a day Date, value is all the events in that day
     */
    open class func getIntraEventsByDate<T:ICEventable>(events: [T]) -> [Date: [T]] {
        var resultEvents = [Date: [T]]()
        for event in events {
            let startDateStartDay = event.startDate.startOfDay
            // get days from both startOfDay, othrewize 22:00 - 01:00 case will get 0 daysBetween result
            let daysBetween = Date.daysBetween(start: startDateStartDay, end: event.endDate ?? Date(), ignoreHours: true)
            
            guard daysBetween >= 0 else {
                assertionFailure("DaysBetween can't be negative value")
                continue
            }
            
            if daysBetween == 0 {
                if resultEvents[startDateStartDay] == nil {
                    resultEvents[startDateStartDay] = [T]()
                }
                resultEvents[startDateStartDay]?.append(event.copy())
            } else {
                // Cross days
                for day in 0...daysBetween {
                    let currentStartDate = startDateStartDay.add(component: .day, value: day)
                    if resultEvents[currentStartDate] == nil {
                        resultEvents[currentStartDate] = [T]()
                    }
                    var newEvent = event.copy()
                    if day == 0 {
                        newEvent.intraEndDate = startDateStartDay.endOfDay
                    } else if day == daysBetween {
                        newEvent.intraStartDate = currentStartDate
                    } else {
                        newEvent.intraStartDate = currentStartDate.startOfDay
                        newEvent.intraEndDate = currentStartDate.endOfDay
                    }
                    
                    // if newEvent time is 0:00 - 0:00, ignore
                    if newEvent.intraStartDate != newEvent.intraEndDate {
                        resultEvents[currentStartDate]?.append(newEvent)
                    }
                }
            }
        }
        return resultEvents
    }
}
