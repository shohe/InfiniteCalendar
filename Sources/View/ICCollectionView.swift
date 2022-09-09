//
//  InfiniteCalendarCollectionView.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI


public class ICCollectionView: UICollectionView {
    public var registeredCells = [String]() // [identifiers]
    public var registeredSupplementaryClasses = [String:String]() // [kind:identifiers]
    
    public override func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        super.register(nib, forCellWithReuseIdentifier: identifier)
        registeredCells.append(identifier)
    }
    
    public override func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        super.register(cellClass, forCellWithReuseIdentifier: identifier)
        registeredCells.append(identifier)
    }
    
    public override func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
        super.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        registeredSupplementaryClasses[kind] = identifier
    }
    
    public override func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind elementKind: String, withReuseIdentifier identifier: String) {
        super.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
        registeredSupplementaryClasses[elementKind] = identifier
    }
    
    public func registerSupplementaryViews(_ viewClasses: [UICollectionReusableView.Type]) {
        viewClasses.forEach {
            self.register($0, forSupplementaryViewOfKind: $0.className, withReuseIdentifier: $0.className)
        }
    }
}
