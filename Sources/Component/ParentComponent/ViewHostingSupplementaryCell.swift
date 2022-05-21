//
//  ViewHostingSupplementaryCell.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/27.
//

import SwiftUI


open class ViewHostingSupplementaryCell<T: ICComponentView>: UICollectionReusableView, ViewHostableSupplementaryCell {
    public typealias Component = T
    
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
    
    public func configure(parentVC: UIViewController?, item: T.Item) {
        self.item = item
        host.rootView = T(item)
        host.view.invalidateIntrinsicContentSize()
        
        guard host.parent == nil else { return }
        parentVC?.addChild(host)
        addSubview(host.view)
        host.didMove(toParent: parentVC)
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
        host.willMove(toParent: nil)
        host.view.removeFromSuperview()
        host.removeFromParent()
    }
}
