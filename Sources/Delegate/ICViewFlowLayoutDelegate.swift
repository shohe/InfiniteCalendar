//
//  ICViewFlowLayoutDelegate.swift
//  Demo
//
//  Created by Shohe Ohtani on 2022/05/28.
//

import SwiftUI

public protocol ICViewFlowLayoutDelegateProvider {
    associatedtype Settings: ICSettings
    
    /// Get the date for givin section
    func collectionView(_ collectionView: UICollectionView, layout: ICViewFlowLayout<Settings>, dayForSection section: Int) -> Date
    /// Get the start time for given item intexPath
    func collectionView(_ collectionView: UICollectionView, layout: ICViewFlowLayout<Settings>, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date
    /// Get the end time for given item intexPath
    func collectionView(_ collectionView: UICollectionView, layout: ICViewFlowLayout<Settings>, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date
}

open class ICViewFlowLayoutDelegate<Settings: ICSettings>: ICViewFlowLayoutDelegateProvider {
    private let dayForSection: (UICollectionView, ICViewFlowLayout<Settings>, Int) -> Date
    private let startTimeForItemAtIndexPath: (UICollectionView, ICViewFlowLayout<Settings>, IndexPath) -> Date
    private let endTimeForItemAtIndexPath: (UICollectionView, ICViewFlowLayout<Settings>, IndexPath) -> Date
    
    init<Provider: ICViewFlowLayoutDelegateProvider>(_ provider: Provider) where Provider.Settings == Settings {
        dayForSection = provider.collectionView(_:layout:dayForSection:)
        startTimeForItemAtIndexPath = provider.collectionView(_:layout:startTimeForItemAtIndexPath:)
        endTimeForItemAtIndexPath = provider.collectionView(_:layout:endTimeForItemAtIndexPath:)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: ICViewFlowLayout<Settings>, dayForSection section: Int) -> Date {
        dayForSection(collectionView, layout, section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: ICViewFlowLayout<Settings>, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        startTimeForItemAtIndexPath(collectionView, layout, indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: ICViewFlowLayout<Settings>, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
        endTimeForItemAtIndexPath(collectionView, layout, indexPath)
    }
}
