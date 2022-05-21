//
//  Buildable.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/26.
//

import Foundation


protocol Buildable { }

extension Buildable {
    func mutating<T>(keyPath: WritableKeyPath<Self, T>, value: T) -> Self {
        var newSelf = self
        newSelf[keyPath: keyPath] = value
        return newSelf
    }
}
