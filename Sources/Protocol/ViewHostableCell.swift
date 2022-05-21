//
//  ViewHostableCell.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/30.
//

import SwiftUI

public protocol ViewHostableCell: ReusableCell {
    associatedtype View: CellableView
    
    var viewModel: View.VM? { get set }
    
    func configure(parentVC: UIViewController?, viewModel: View.VM)
}


public protocol ViewHostableSupplementaryCell: ReusableCell {
    associatedtype Component: ICComponentView
    
    var item: Component.Item? { get set }
    
    func configure(parentVC: UIViewController?, item: Component.Item)
}


public protocol ViewHostableDecorationCell: ReusableCell {
    associatedtype T: ICComponentView
    
    var item: T.Item? { get set }
    
    func setup(item: T.Item)
}
