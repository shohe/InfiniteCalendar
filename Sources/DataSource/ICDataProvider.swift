//
//  ICDataProvider.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/03.
//

import SwiftUI

public class ICDataProvider<View: CellableView, Cell: ViewHostingCell<View>>: CollectionDataProvider {
    public typealias T = View.VM
    
    public let layout: ICViewFlowLayout
    public let preparePages: Int
    public var settings: ICViewSettings
    public var allDayEvents = [Date: [T]]()
    public var events = [Date: [T]]()
    
    
    init(layout: ICViewFlowLayout, allDayEvents: [Date: [T]], events: [Date: [T]], settings: ICViewSettings, preparePages: Int) {
        self.allDayEvents = allDayEvents
        self.events = events
        self.layout = layout
        self.settings = settings
        self.preparePages = preparePages
    }
    
    public func numberOfSections() -> Int {
        return (preparePages * settings.numOfDays)
    }
    
    public func numberOfItems(in section: Int) -> Int {
        let date = layout.date(forDateHeaderAt: IndexPath(item: 0, section: section))
        if let events = events[date] {
            return events.count
        } else {
            return 0
        }
    }
    
    public func item(at indexPath: IndexPath) -> View.VM? {
        let date = layout.date(forDateHeaderAt: indexPath)
        return events[date]?[indexPath.row]
    }
    
    // TODO: updateItem
    public func updateItem(at indexPath: IndexPath, value: View.VM) {
        let _ = layout.date(forDateHeaderAt: indexPath)
    }
}
