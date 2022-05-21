//
//  SampleData.swift
//  Demo
//
//  Created by Shohe Ohtani on 2022/05/21.
//

import Foundation

class SampleData {
    private let firstDate = Date().set(hour: Date().hour, minute: 0, second: 0)
    private let secondDate = Date().set(day: Date().day+1, hour: Date().hour-2, minute: 0, second: 0)
    private let thirdDate = Date().set(day: Date().day+2, hour: Date().hour+1, minute: 0, second: 0)
    
    lazy var events: [EventCellView.VM] = [
        EventCellView.VM(text: "One", start: firstDate, end: firstDate.add(component: .hour, value: 1)),
        EventCellView.VM(text: "AllDay-1", start: firstDate.startOfDay, end: firstDate.endOfDay, isAllDay: true, color: .green),
        EventCellView.VM(text: "AllDay-2", start: firstDate.startOfDay, end: firstDate.endOfDay, isAllDay: true, color: .green),
        EventCellView.VM(text: "AllDay-3", start: firstDate.startOfDay, end: firstDate.endOfDay, isAllDay: true, color: .purple),
        EventCellView.VM(text: "AllDay-4", start: firstDate.startOfDay, end: firstDate.endOfDay, isAllDay: true, color: .purple),
        
        EventCellView.VM(text: "Two", start: secondDate, end: secondDate.add(component: .hour, value: 4), color: .yellow),
        EventCellView.VM(text: "AllDay-5", start: secondDate.startOfDay, end: secondDate.endOfDay, isAllDay: true),
        
        EventCellView.VM(text: "Three", start: thirdDate, end: thirdDate.add(component: .hour, value: 2), color: .gray),
        EventCellView.VM(text: "AllDay-6", start: thirdDate.startOfDay, end: thirdDate.endOfDay, isAllDay: true),
        EventCellView.VM(text: "AllDay-7", start: thirdDate.startOfDay, end: thirdDate.endOfDay, isAllDay: true),
    ]
}
