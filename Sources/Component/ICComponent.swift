//
//  ICComponent.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/28.
//

import SwiftUI

public protocol ICComponent {
    init()
}
public protocol ICComponentView: View {
    associatedtype Item: ICComponent
    init(_ item: Item)
}

public protocol ICTimeHeaderView: ICComponentView where Item == ICTimeHeaderItem {}
public protocol ICDateHeaderView: ICComponentView where Item == ICDateHeaderItem {}
public protocol ICDateCornerView: ICComponentView where Item == ICContentBackgroundItem {}
public protocol ICAllDayHeaderView: ICComponentView where Item == ICAllDayHeaderItem {}
public protocol ICAllDayCornerView: ICComponentView where Item == ICAllDayCornerItem {}
public protocol ICTimelineView: ICComponentView where Item == ICTimelineItem {}

public protocol ICTimeHeaderBackgroundView: ICComponentView where Item == ICContentBackgroundItem {}
public protocol ICDateHeaderBackgroundView: ICComponentView where Item == ICContentBackgroundItem {}
public protocol ICAllDayHeaderBackgroundView: ICComponentView where Item == ICContentBackgroundItem {}


public class ICDefaultComponent {}

// When create custom component, inherit those classes
open class ICTimeHeader<T:ICTimeHeaderView>: ViewHostingSupplementaryCell<T> {}
open class ICDateHeader<T:ICDateHeaderView>: ViewHostingSupplementaryCell<T> {}
open class ICDateCorner<T:ICDateCornerView>: ViewHostingSupplementaryCell<T> {}
open class ICAllDayHeader<T:ICAllDayHeaderView>: ViewHostingSupplementaryCell<T> {}
open class ICAllDayCorner<T:ICAllDayCornerView>: ViewHostingSupplementaryCell<T> {}
open class ICTimeline<T:ICTimelineView>: ViewHostingSupplementaryCell<T> {}

open class ICTimeHeaderBackground<T:ICTimeHeaderBackgroundView>: ViewHostingDecorationCell<T> {}
open class ICDateHeaderBackground<T:ICDateHeaderBackgroundView>: ViewHostingDecorationCell<T> {}
open class ICAllDayHeaderBackground<T:ICAllDayHeaderBackgroundView>: ViewHostingDecorationCell<T> {}
