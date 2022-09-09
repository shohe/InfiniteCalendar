//
//  ICGridLine.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI

open class ICGridLine: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = ICViewColors.gridLine
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

