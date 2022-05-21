//
//  ReusableCell.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/29.
//

import Foundation

public protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

public extension ReusableCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
