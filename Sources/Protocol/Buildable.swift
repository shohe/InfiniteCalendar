//
//  Buildable.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/26.
//

import Foundation


public protocol Buildable { }

public extension Buildable {
    func mutating<T>(keyPath: WritableKeyPath<Self, T>, value: T) -> Self {
        var newSelf = self
        newSelf[keyPath: keyPath] = value
        return newSelf
    }
}
