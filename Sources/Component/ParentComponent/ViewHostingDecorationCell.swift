//
//  ViewHostingDecorationCell.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/28.
//

import SwiftUI


open class ViewHostingDecorationCell<T: ICComponentView>: UICollectionReusableView, ViewHostableDecorationCell {
    public typealias T = T
    
    public var item: T.Item?
    private let host: UIHostingController<T?> = UIHostingController<T?>(rootView: nil)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host._disableSafeArea = true
        addSubview(host.view)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup(item: T.Item) {
        host.rootView = T(item)
        host.view.invalidateIntrinsicContentSize()
        setupLayoutConstraint()
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: self.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    deinit {
        host.view.removeFromSuperview()
    }
}
