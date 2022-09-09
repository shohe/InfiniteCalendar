//
//  ICViewDelegate.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/11.
//

import SwiftUI


public protocol ICBaseViewDelegateProvider {
    associatedtype View: CellableView
    associatedtype Cell: ViewHostingCell<View>
    associatedtype Settings: ICSettings
    
    func didUpdateCurrentDate(_ date: Date)
    func didSelectItem(_ item: View.VM)
}

open class ICBaseViewDelegate<View: CellableView, Cell: ViewHostingCell<View>, Settings: ICSettings>: NSObject, ICBaseViewDelegateProvider {
    private let updateInitDate: (Date) -> Void
    private let selectItem: (View.VM) -> Void
    
    init<Provider: ICBaseViewDelegateProvider>(_ provider: Provider) where Provider.View == View, Provider.Cell == Cell {
        updateInitDate = provider.didUpdateCurrentDate(_:)
        selectItem = provider.didSelectItem(_:)
    }
    
    open func didUpdateCurrentDate(_ date: Date) {
        updateInitDate(date)
    }
    
    open func didSelectItem(_ item: View.VM) {
        selectItem(item)
    }
}
