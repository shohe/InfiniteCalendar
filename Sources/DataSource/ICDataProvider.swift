//
//  ICDataProvider.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/03.
//

import SwiftUI

open class ICDataProvider<View: CellableView, Cell: ViewHostingCell<View>, Settings: ICSettings>: CollectionDataProvider {
    public typealias VM = View.VM
    
    public let layout: ICViewFlowLayout<Settings>
    public let preparePages: Int
    public var settings: Settings
    public var allDayEvents = [Date: [VM]]()
    public var events = [Date: [VM]]()
    
    
    public init(layout: ICViewFlowLayout<Settings>, allDayEvents: [Date: [VM]], events: [Date: [VM]], settings: Settings, preparePages: Int) {
        self.allDayEvents = allDayEvents
        self.events = events
        self.layout = layout
        self.settings = settings
        self.preparePages = preparePages
    }
    
    open func numberOfSections() -> Int {
        return (preparePages * settings.numOfDays)
    }
    
    open func numberOfItems(in section: Int) -> Int {
        let date = layout.date(forDateHeaderAt: IndexPath(item: 0, section: section))
        if let events = events[date] {
            return events.count
        } else {
            return 0
        }
    }
    
    open func item(at indexPath: IndexPath) -> View.VM? {
        let date = layout.date(forDateHeaderAt: indexPath)
        return events[date]?[indexPath.row]
    }
    
    // TODO: updateItem
    open func updateItem(at indexPath: IndexPath, value: View.VM) {
        let _ = layout.date(forDateHeaderAt: indexPath)
    }
}
