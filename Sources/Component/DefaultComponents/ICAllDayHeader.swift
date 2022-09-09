//
//  ICAllDayHeader.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/20.
//

import SwiftUI


// MARK: AllDayHeader
public protocol ICAllDayHeaderDelegate: AnyObject {
    associatedtype T: ICAllDayHeaderView
    func didExpand(sender: ICAllDayHeader<T>)
}

public extension ICDefaultComponent {
    class AllDayHeader: ICAllDayHeader<D_AllDayHeaderView> {}
    
    struct D_AllDayHeaderView: ICAllDayHeaderView {
        public typealias Item = ICAllDayHeaderItem
        var item: Item
        
        private let itemHeight: CGFloat = 26.0
        private let itemPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 2.0, trailing: 3.0)
        private let maxItems: Int = 3
        
        private var displayItemRange: Range<Int> {
            let upper: Int = item.isExpended ? item.views.count : min(item.views.count, maxItems)
            return 0..<upper
        }
        
        public init(_ item: Item) {
            self.item = item
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(displayItemRange, id: \.self) { i in
                    if !item.isExpended && item.views.count > maxItems && i == maxItems-1 {
                        ZStack {
                            Rectangle()
                                .frame(maxHeight: itemHeight)
                                .foregroundColor(Color.white.opacity(0.01))
                            Text("+\(item.views.count-(maxItems-1))")
                                .bold()
                                .font(.system(size: 11.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color.black.opacity(0.6))
                        }
                        .padding(itemPadding)
                        .padding(.leading, 6.0)
                        .onTapGesture { item.toggle?(!item.isExpended) }
                    } else {
                        item.views[i]
                            .frame(maxHeight: itemHeight)
                            .padding(itemPadding)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(minHeight: 0)
            .clipped()
        }
    }
}


// MARK: AllDayCorner
public extension ICDefaultComponent {
    class AllDayCorner: ICAllDayCorner<D_AllDayCornerView> {}
    
    struct D_AllDayCornerView: ICAllDayCornerView {
        public typealias Item = ICAllDayCornerItem
        var item: Item
        
        private let maxItems: Int = 3
        private var isEnableToggle: Bool {
            return item.itemCount > maxItems
        }
        
        public init(_ item: Item) {
            self.item = item
        }
        
        public var body: some View {
            ZStack(alignment: .bottom) {
                item.background
                Image(systemName: item.isExpended ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14.0))
                    .padding(.bottom, 7.0)
                    .foregroundColor(Color.black.opacity(0.7))
            }
            .frame(minHeight: 0)
            .clipped()
            .onTapGesture { if isEnableToggle { item.toggle?(!item.isExpended) } }
        }
    }
}


// MARK: AllDayHeaderBackground
public extension ICDefaultComponent {
    class AllDayHeaderBackground: ICAllDayHeaderBackground<D_AllDayHeaderBackgroundView> {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup(item: ICContentBackgroundItem())
        }
    }
    
    struct D_AllDayHeaderBackgroundView: ICAllDayHeaderBackgroundView {
        public typealias Item = ICContentBackgroundItem
        var item: Item
        
        public init(_ item: Item) {
            self.item = item
        }
        
        public var body: some View {
            HStack(spacing: 0) {
                item.color
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.gray.opacity(0.3))
            }.shadow(color: Color.black.opacity(0.25), radius: 1.0, x: 0.0, y: 3.0)
        }
    }
}
