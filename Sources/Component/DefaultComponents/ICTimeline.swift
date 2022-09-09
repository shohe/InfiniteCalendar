//
//  ICTimeline.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/18.
//

import SwiftUI

public extension ICDefaultComponent {
    class Timeline: ICTimeline<D_TimelineView> {}
    
    struct D_TimelineView: ICTimelineView {
        public typealias Item = ICTimelineItem
        var item: Item
        private let ballSize: CGFloat = 8
        
        public init(_ item: Item) {
            self.item = item
        }
        
        public var body: some View {
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 1.0)
                Circle()
                    .frame(width: ballSize, height: ballSize)
                    .offset(x: -ballSize/2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(item.isDisplayed ? 1 : 0)
        }
    }
}
