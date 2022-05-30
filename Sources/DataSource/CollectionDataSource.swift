//
//  CollectionDataSource.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/30.
//

import Foundation
import UIKit


open class CollectionDataSource<Provider: CollectionDataProvider, Cell: UICollectionViewCell>:
    NSObject, UICollectionViewDataSource where Cell: ViewHostableCell, Provider.T == Cell.View.VM {
    
    public var provider: Provider
    public var parentVC: UIViewController
    public var collectionView: UICollectionView
    
    public init(parentVC: UIViewController, collectionView: UICollectionView, provider: Provider) {
        self.parentVC = parentVC
        self.collectionView = collectionView
        self.provider = provider
        super.init()
        
        collectionView.dataSource = self
    }
    
    
    // MARK: - UICollectionViewDataSource
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return provider.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider.numberOfItems(in: section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell, let item = provider.item(at: indexPath) else {
            return UICollectionViewCell()
        }
        cell.configure(parentVC: parentVC, viewModel: item)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView(frame: CGRect.zero)
    }
}
