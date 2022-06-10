//
//  ViewHostingCell.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/31.
//

import SwiftUI


open class ViewHostingCell<T: CellableView>: UICollectionViewCell, ViewHostableCell {
    public typealias View = T
    
    public var viewModel: T.VM?
    public var view: T? {
        return host.rootView
    }
    
    public let host: UIHostingController<T?> = UIHostingController<T?>(rootView: nil)
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host._disableSafeArea = true
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure(parentVC: UIViewController?, viewModel: T.VM) {
        self.viewModel = viewModel
        host.rootView = T(viewModel)
        host.view.invalidateIntrinsicContentSize()
        
        guard host.parent == nil else { return }
        parentVC?.addChild(host)
        contentView.addSubview(host.view)
        setupLayoutConstraint()
        host.didMove(toParent: parentVC)
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    deinit {
        host.willMove(toParent: nil)
        host.view.removeFromSuperview()
        host.removeFromParent()
    }
}
