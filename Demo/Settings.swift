//
//  Settings.swift
//  Demo
//
//  Created by Shohe Ohtani on 2022/05/21.
//

import Foundation
import InfiniteCalendar

class Settings: ICViewSettings {
    init(numOfDays: Int, setDate: Date) {
        super.init()
        self.numOfDays = numOfDays
        initDate = setDate
        scrollType = (numOfDays == 1 || numOfDays == 7) ? .pageScroll : .sectionScroll
    }
    
    func updateScrollType(numOfDays: Int) {
        self.numOfDays = numOfDays
        scrollType = (numOfDays == 1 || numOfDays == 7) ? .pageScroll : .sectionScroll
    }
}
