//
//  CellableView.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/30.
//

import SwiftUI

public protocol CellableView: View {
    associatedtype VM: ICEventable
    
    init(_ viewModel: VM)
}

public protocol ICEventable: Identifiable {
    var startDate: Date { get set }
    /// If use for timeLog app, end can be nil
    var endDate: Date? { get set }
    
    /// If a event crosses two days, it should be devided into two events but with different intraStartDate and intraEndDate
    /// eg. startDate = 2018.03.29 14:00 endDate = 2018.03.30 03:00, then two events should be generated: 1. 0329 14:00 - 23:59(IntraEnd) 2. 0330 00:00(IntraStart) - 03:00
    var intraStartDate: Date { get set }
    var intraEndDate: Date { get set }
    
    /// When it's streaching to create new item, use this state.
    var editState: EditState? { get set }
    
    var isAllDay: Bool { get set }
    
    /// When create new item, called this method.
    static func create(from eventable: Self?, state: EditState?) -> Self
    
    func copy() -> Self
}
