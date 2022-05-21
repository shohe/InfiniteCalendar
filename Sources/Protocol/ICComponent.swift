//
//  ICComponent.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/28.
//

import SwiftUI

public protocol ICComponent { }

public protocol ICComponentView: View {
    associatedtype Item: ICComponent
    init(_ item: Item)
}
