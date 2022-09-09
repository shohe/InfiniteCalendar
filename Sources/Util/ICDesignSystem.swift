//
//  ICDesignSystem.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import Foundation
import SwiftUI

public class ICViewColors {
    static var dateHeaderWeekday: UIColor { return .darkGray }
    static var dateHeaderDay: UIColor { return .black }
    static var today: UIColor { return .blue }
    static var highlight: UIColor { return .blue }
    static var timeHeader: UIColor { return .black }
    static var gridLine: UIColor { return UIColor.lightGray.withAlphaComponent(0.3) }
    static var currentTimeline: UIColor { return .black }
}

public class ICViewUI {
    public static var allDayItemHeight: CGFloat { return 28.0 }
    
    public enum DatePosition {
        case top, left
    }
}
