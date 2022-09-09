//
//  CollectionDataProvider.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/30.
//

import Foundation
import SwiftUI

public protocol CollectionDataProvider {
    associatedtype T
    
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func item(at indexPath: IndexPath) -> T?
    
    func updateItem(at indexPath: IndexPath, value: T)
}
