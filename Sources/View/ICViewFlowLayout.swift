//
//  InfiniteCalendarViewFlowLayout.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI

open class ICViewFlowLayout<Settings: ICSettings>: UICollectionViewFlowLayout {
    
    // UI params
    public var hourHeight: CGFloat!
    public var dateHeaderHeight: CGFloat!
    public var timeHeaderWidth: CGFloat!
    public var allDayHeaderHeight: CGFloat = 0
    public var sectionWidth: CGFloat!
    
    public var minuteHeight: CGFloat { return hourHeight / 60 }
    
    /// Date header is stay on top, when its scrolling down.
    open var isStickeyDateHeader: Bool { return true }
    
    // UI params default
    open var defaultDateHeaderHeight: CGFloat { return 64.0 }
    open var defaultHourHeight: CGFloat { return 56.0 }
    open var defaultTimeHeaderWidth: CGFloat { return 64.0 }
    open var defaultGridThickness: CGFloat { return 1.0 }
    open var defaultCurrentTimelineHeight: CGFloat { return 10.0 }
    open var defaultAllDayOneLineHeight: CGFloat { return ICViewUI.allDayItemHeight }
    
    /// Margin for flowLayout in collectionView
    open var contentsMargin: UIEdgeInsets { return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0) }
    open var allDayContentsMargin: UIEdgeInsets { return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0) }
    open var itemMargin: UIEdgeInsets { return UIEdgeInsets(top: 1, left: 0.5, bottom: 1, right: 4.0) }
    open var maxSectionHeight: CGFloat {
        let height = hourHeight * 24
        return height + contentsMargin.top + contentsMargin.bottom + allDayHeaderHeight + (isHiddenTopDate ? 0 : dateHeaderHeight)
    }
    open var minimumHeight: CGFloat { return (hourHeight ?? defaultHourHeight) / 2 }
    
    public let minOverlayZ = 1000  // Allows for 900 items in a section without z overlap issues
    public let minCellZ = 100      // Allows for 100 items in a section's background
    public let minBackgroundZ = 0
    
    // Attributes
    public typealias AttDic = [IndexPath: UICollectionViewLayoutAttributes]
    
    public var allAttributes = [UICollectionViewLayoutAttributes]()
    public var itemAttributes = AttDic()
    public var dateHeaderAttributes = AttDic()
    public var dateHeaderBackgroundAttributes = AttDic()
    public var timeHeaderAttributes = AttDic()
    public var timeHeaderBackgroundAttributes = AttDic()
    public var verticalGridlineAttributes = AttDic()
    public var horizontalGridlineAttributes = AttDic()
    public var cornerHeaderAttributes = AttDic()
    public var currentTimelineAttributes = AttDic()
    
    public var allDayHeaderAttributes = AttDic()
    public var allDayHeaderBackgroundAttributes = AttDic()
    public var allDayCornerAttributes = AttDic()
    
    public var currentTimeComponents: DateComponents {
        if cachedCurrentTimeComponents[0] == nil {
            cachedCurrentTimeComponents[0] = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        }
        return cachedCurrentTimeComponents[0]!
    }
    
    public var cachedDayDateComponents = [Int: DateComponents]()
    public var cachedStartTimeDateComponents = [IndexPath: DateComponents]()
    public var cachedEndTimeDateComponents = [IndexPath: DateComponents]()
    public var registeredDecorationClasses = [String: AnyClass]()
    public var cachedCurrentTimeComponents = [Int: DateComponents]()
    
    var needsToPrepareAttributesForAllSections = true
    public var needsToExpendAllDayHeader = false
    
    // Settings
    private var displayTimeRange: (startTime: Int, endTime: Int) {
        return currentSettings.timeRange
    }
    
    /// How many minute each can user move event cell
    private var moveTimeInterval: Int {
        return currentSettings.moveTimeMinInterval
    }
    
    /// If display date on left side, when display type is OneDay
    public var isHiddenTopDate: Bool {
        return currentSettings.datePosition == .left && currentSettings.numOfDays == 1
    }
    
    /// To fix timeHeaderBackground height size,  If use `.edgesIgnoringSafeArea()`
    var safeAreaInsets: UIEdgeInsets? {
        UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?
                    .windows
                    .filter({$0.isKeyWindow})
                    .first?.safeAreaInsets
    }
    
    
    public var delegate: ICViewFlowLayoutDelegate<Settings>!
    public var currentInitDate: Date! // This `currentInitDate` is should be leftest date for current collectionView
    public var currentSettings: Settings!
    private var minuteTimer: Timer?
    
    
    public init(settings: Settings, delegate: ICViewFlowLayoutDelegate<Settings>!) {
        super.init()
        self.delegate = delegate
        currentSettings = settings
        currentInitDate = settings.initDate
        setupUIParams()
        initializeMinuteTick()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        minuteTimer?.invalidate()
    }
    
    open override var collectionViewContentSize: CGSize {
        return CGSize(width: timeHeaderWidth + sectionWidth * CGFloat(collectionView!.numberOfSections), height: maxSectionHeight)
    }
    
    open override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        invalidateLayoutCache()
        prepare()
        super.prepare(forCollectionViewUpdates: updateItems)
    }
    
    open override func prepare() {
        super.prepare()
        
        if needsToPrepareAttributesForAllSections {
            guard let cv = collectionView else { return }
            prepareAttributesForSections(NSIndexSet(indexesIn: NSRange(location: 0, length: cv.numberOfSections)))
            needsToPrepareAttributesForAllSections = false
        }
        
        let needsToPrepareAllAttributes = (allAttributes.count == 0)
        
        if needsToPrepareAllAttributes {
            allAttributes.append(contentsOf: dateHeaderAttributes.values)
            allAttributes.append(contentsOf: dateHeaderBackgroundAttributes.values)
            allAttributes.append(contentsOf: timeHeaderAttributes.values)
            allAttributes.append(contentsOf: timeHeaderBackgroundAttributes.values)
            allAttributes.append(contentsOf: verticalGridlineAttributes.values)
            allAttributes.append(contentsOf: horizontalGridlineAttributes.values)
            allAttributes.append(contentsOf: cornerHeaderAttributes.values)
            allAttributes.append(contentsOf: currentTimelineAttributes.values)
            allAttributes.append(contentsOf: itemAttributes.values)
            
            allAttributes.append(contentsOf: allDayCornerAttributes.values)
            allAttributes.append(contentsOf: allDayHeaderAttributes.values)
            allAttributes.append(contentsOf: allDayHeaderBackgroundAttributes.values)
        }
    }
    
    open func prepareAttributesForSections(_ sectionIndexes: NSIndexSet) {
        guard let cv = collectionView, cv.numberOfSections != 0 else { return }
        var attributes = UICollectionViewLayoutAttributes()
        let contentMinX = timeHeaderWidth + contentsMargin.left
        let contentMinY = contentsMargin.top + (isHiddenTopDate ? 0 : dateHeaderHeight)
        layoutTimeHeaderAttributes(collectionView: cv, attributes: &attributes)
        
        // reset DateHeader with verticalGridLine
        layoutCurrentTimelineAttributes(sectionIndexes: sectionIndexes, collectionView: cv, attributes: &attributes)
        layoutDateHeaderAttributes(sectionIndexes: sectionIndexes, collectionView: cv, attributes: &attributes)
        layoutAllDayHeaderAttributes(sectionIndexes: sectionIndexes, collectionView: cv, attributes: &attributes)
        layoutCornerHeaderAttributes(collectionView: cv, attributes: &attributes)
        layoutHorizontalGridLineAttributes(collectionView: cv, calendarStartX: contentMinX, calendarStartY: contentMinY, attributes: &attributes)
    }
    
    open func zIndexForElementKind(_ kind: String) -> Int {
        switch kind {
        case Settings.AllDayCorner.className:
            return minOverlayZ + 11
        case Settings.DateCorner.className:
            return minOverlayZ + 10
        case Settings.AllDayHeader.className:
            return minOverlayZ + 9
        case Settings.AllDayHeaderBackground.className:
            return minOverlayZ + 8
        case Settings.DateHeader.className:
            return minOverlayZ + (isHiddenTopDate ? 12 : 7)
        case Settings.DateHeaderBackground.className:
            return minOverlayZ + 6
        case Settings.TimeHeader.className:
            return minOverlayZ + 5
        case Settings.TimeHeaderBackground.className:
            return minOverlayZ + 4
        case Settings.Timeline.className:
            return minOverlayZ + 3
        case ICViewKinds.Decoration.horizontalGridline:
            return minBackgroundZ + 2
        case ICViewKinds.Decoration.verticalGridline:
            return minBackgroundZ + 1
        default :
            return minCellZ
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let cv = collectionView else { return nil }
        let visibleSections = NSMutableIndexSet()
        NSIndexSet(indexesIn: NSRange(location: 0, length: cv.numberOfSections)).enumerate(_:) { (section: Int, _: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            let sectionRect = self.rect(forSection: section)
            if rect.intersects(sectionRect) {
                visibleSections.add(section)
            }
        }
        prepareAttributesForSections(visibleSections)
        
        return allAttributes.filter({ rect.intersects($0.frame) })
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override func register(_ viewClass: AnyClass?, forDecorationViewOfKind elementKind: String) {
        super.register(viewClass, forDecorationViewOfKind: elementKind)
        registeredDecorationClasses[elementKind] = viewClass
    }
    
    public func registerDecorationViews(_ viewClasses: [UICollectionReusableView.Type]) {
        viewClasses.forEach {
            register($0, forDecorationViewOfKind: $0.className)
        }
    }
    
    public func updateSettings(_ settings: Settings) {
        currentSettings = settings
    }
    
    public func updateInitDate(_ initDate: Date) {
        currentInitDate = initDate
    }
    
    open func invalidateLayoutCache() {
        needsToPrepareAttributesForAllSections = true
        
        cachedDayDateComponents.removeAll()
        cachedStartTimeDateComponents.removeAll()
        cachedEndTimeDateComponents.removeAll()
        
        dateHeaderAttributes.removeAll()
        dateHeaderBackgroundAttributes.removeAll()
        timeHeaderAttributes.removeAll()
        timeHeaderBackgroundAttributes.removeAll()
        verticalGridlineAttributes.removeAll()
        horizontalGridlineAttributes.removeAll()
        currentTimelineAttributes.removeAll()
        itemAttributes.removeAll()
        allAttributes.removeAll()
        
        allDayCornerAttributes.removeAll()
        allDayHeaderAttributes.removeAll()
        allDayHeaderBackgroundAttributes.removeAll()
    }
    
    
    open func indexPath(forHighlightAt point: CGPoint) -> IndexPath {
        let pathes: [IndexPath] = indexPathsForTimeHeader()
        let timeHeadDates: [Date] = pathes.map({date(forTimeHeaderAt: $0)})
        
        let currentDate: Date = date(forCollectionViewAt: point)
        
        let closestDateIndex = timeHeadDates.enumerated().min(by: { abs(Date.timeBetween(start: $0.1, end: currentDate, ignoreDate: true)) < abs(Date.timeBetween(start: $1.1, end: currentDate, ignoreDate: true)) })?.offset
        
        return pathes[closestDateIndex!]
    }
    
    open func section(forCollectionViewPoint point: CGPoint, withPointInSelfView pointInSelf: CGPoint) -> Int {
        let contentMinX: CGFloat = timeHeaderWidth + contentsMargin.left + defaultGridThickness
        let _point: CGPoint = CGPoint(
            x: (contentMinX < pointInSelf.x) ? point.x : point.x + (contentMinX - pointInSelf.x),
            y: point.y
        )
        let adjustedX = _point.x - timeHeaderWidth - contentsMargin.left
        return Int(adjustedX / sectionWidth)
    }
    
    
    // MARK: - CGPoint
    /// The point move by is must be point for CollectionView.
    open func point(forMoveTo point: CGPoint, pointInView targetPoint: CGPoint, withSection section: Int) -> CGPoint {
        let headerHeight: CGFloat = isHiddenTopDate ? 0 : dateHeaderHeight
        return CGPoint(
            x: rect(forSection: section).minX + defaultGridThickness + contentsMargin.left,
            y: max(max(point.y - targetPoint.y, headerHeight), CGFloat(collectionView?.contentOffset.y ?? 0) + headerHeight + allDayHeaderHeight)
        )
    }
    
    
    // MARK: - CGRect
    /// Rect for new cell.
    /// If set specific height by minute, set specificMin. Default value is 60min.
    open func rect(forNewCellAt position: CGPoint, withSpecificMinute specificMin: Int = 60) -> CGRect {
        let size: CGSize = CGSize(width: sectionWidth, height: hourHeight * CGFloat(specificMin)/60)
        let origin: CGPoint = point(forStartBlockFrom: position)
        return CGRect(origin: origin, size: size)
    }
    
    open func rect(forSection section: Int) -> CGRect {
        return CGRect(x: timeHeaderWidth + sectionWidth * CGFloat(section), y: 0, width: sectionWidth, height: collectionViewContentSize.height)
    }
    
    // isLast: firstTime and lastTime are both 00:00. For distinguish which 00:00 is for lastTime.
    open func rect(_ collectionView: UICollectionView, forTimeHeaderAt date: Date, isLast: Bool) -> CGRect {
        let timeHeaderHeight: CGFloat = hourHeight / CGFloat(60/moveTimeInterval)
        let calendarMinY = (isHiddenTopDate ? 0 : dateHeaderHeight) + contentsMargin.top - (timeHeaderHeight / 2.0)
        let headerMinX = fmax(collectionView.contentOffset.x, 0)
        
        let hourY = calendarMinY + (CGFloat(isLast ? 24 : date.hour)*hourHeight)
        let minuteY = timeHeaderHeight * CGFloat(date.minute/moveTimeInterval)
        return CGRect(x: headerMinX, y: hourY + minuteY, width: timeHeaderWidth, height: timeHeaderHeight)
    }
    
    /// Rect for move cell.
    open func rect<T:ICEventable>(forMoveCell originalRect: CGRect, vm: T?,
                                  collectionPointAt cPoint: CGPoint,
                                  screenPointAt sPoint: CGPoint,
                                  withPointInView tapPoint: CGPoint?) -> CGRect? {
        guard let vm = vm else { return nil }
        
        let section = section(forCollectionViewPoint: cPoint, withPointInSelfView: sPoint)
        let origin = point(forMoveTo: cPoint, pointInView: tapPoint ?? .zero, withSection: section)
        let cellSize = size(forMoveCellBetween: vm.startDate, andEnd: vm.endDate ?? vm.intraEndDate)
        
        return CGRect(
            x: origin.x,
            y: originalRect.origin.y,
            width: sectionWidth - itemMargin.left,
            height: cellSize.height
        )
    }
    
    /// Rect for resizing cell with point.
    /// The point resize by is must be point for CollectionView.
    open func rect(forResizeBy point: CGPoint, forEditView targetView: UIView, withBaseRect rect: CGRect) -> CGRect {
        let viewLocation: CGPoint = rect.origin
        
        // Check scroll direction, set base point
        // Position is out of longTapView frame and position.y is upper than view's maxY
        let cellHeightRange = rect.minY...rect.maxY
        let isScrollToTop = !cellHeightRange.contains(point.y) && (point.y < rect.maxY)
        
        let basePoint: CGPoint = CGPoint(
            x: viewLocation.x,
            y: isScrollToTop ? viewLocation.y + minimumHeight : viewLocation.y
        )
        
        let height: CGFloat = abs(basePoint.y - point.y)
        let size: CGSize = CGSize(width: targetView.frame.width, height: max(minimumHeight,height))
        let origin: CGPoint = CGPoint(
            x: targetView.frame.origin.x,
            y: isScrollToTop ? point.y : basePoint.y
        )
        
        return CGRect(origin: origin, size: size)
    }
    
    
    // MARK: - CGSize
    open func size(forMoveCellBetween start: Date, andEnd end: Date) -> CGSize {
        let secondDiff: Int = abs(Date.timeBetween(start: start, end: end, ignoreDate: false))
        let height: CGFloat = (minuteHeight / 60) * CGFloat(secondDiff)
        let horizontalMargin: CGFloat = contentsMargin.left + contentsMargin.right + defaultGridThickness*2
        return CGSize(width: sectionWidth - horizontalMargin, height: max(height, minimumHeight))
    }
    
    
    // MARK: - Layout
    open func minuteTick() {
        cachedCurrentTimeComponents.removeAll()
        invalidateLayout()
    }
    
    /**
     Setup method for dateHeaderView
     
     - Parameters:
        - sectionIndexes: index of section
        - collectionView: self CollectionView
        - attributes: the pointer of attributes
     */
    open func layoutDateHeaderAttributes(sectionIndexes: NSIndexSet, collectionView: UICollectionView, attributes: inout UICollectionViewLayoutAttributes) {
        let calendarMinX = timeHeaderWidth + contentsMargin.left
        let calendarGridMinY = contentsMargin.top + (isHiddenTopDate ? 0 : dateHeaderHeight)
        let dateHeaderMinY = isStickeyDateHeader ? collectionView.contentOffset.y : fmax(collectionView.contentOffset.y, 0.0)
        
        sectionIndexes.enumerate(_:) { (section, _) in
            let sectionMinX = calendarMinX + sectionWidth * CGFloat(section)
            (attributes, dateHeaderAttributes) = layoutAttributesForSupplementaryView(at: IndexPath(item: 0, section: section), ofKind: Settings.DateHeader.className, withItemCache: dateHeaderAttributes)
            
            let isDisplayAttribute = !isHiddenTopDate || date(forSection: section) == date(forContentOffset: collectionView.contentOffset)
            let shouldAttributeHidden = isHiddenTopDate && !isDisplayAttribute
            
            attributes.frame = CGRect(
                x: isHiddenTopDate ? shouldAttributeHidden ? -timeHeaderWidth : collectionView.contentOffset.x : sectionMinX,
                y: dateHeaderMinY,
                width: isHiddenTopDate ? timeHeaderWidth : sectionWidth,
                height: dateHeaderHeight
            )
            attributes.zIndex = zIndexForElementKind(Settings.DateHeader.className)
            
            layoutVerticalGridLineAttributes(section: section, sectionX: sectionMinX, calendarGridMinY: collectionView.contentOffset.y, sectionHeight: collectionView.contentSize.height, attributes: &attributes)
            layoutItemsAttributes(section: section, sectionX: sectionMinX, calendarStartY: calendarGridMinY)
        }
        
        // background
        if !isHiddenTopDate {
            (attributes, dateHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0), ofKind: Settings.DateHeaderBackground.className, withItemCache: dateHeaderBackgroundAttributes)
            let attributesHeight = dateHeaderHeight + (collectionView.contentOffset.y < 0 ? abs(collectionView.contentOffset.y) : 0)
            attributes.frame = CGRect(
                x: collectionView.contentOffset.x,
                y: collectionView.contentOffset.y,
                width: collectionViewContentSize.width,
                height: isStickeyDateHeader ? dateHeaderHeight : attributesHeight
            )
            attributes.zIndex = zIndexForElementKind(Settings.DateHeaderBackground.className)
        }
    }
    
    open func layoutItemsAttributes(section: Int, sectionX: CGFloat, calendarStartY: CGFloat) {
        var attributes = UICollectionViewLayoutAttributes()
        var sectionItemAttributes = [UICollectionViewLayoutAttributes]()
        
        for item in 0..<collectionView!.numberOfItems(inSection: section) {
            let itemIndexPath = IndexPath(item: item, section: section)
            (attributes, itemAttributes) = layoutAttributesForCell(at: itemIndexPath, withItemCache: itemAttributes)
            
            let itemStartTime = startTimeForIndexPath(itemIndexPath)
            let itemEndTime = endTimeForIndexPath(itemIndexPath)
            let startHourY = CGFloat(itemStartTime.hour!) * hourHeight
            let startMinuteY = CGFloat(itemStartTime.minute!) * minuteHeight
            let endHourY: CGFloat
            let endMinuteY = CGFloat(itemEndTime.minute!) * minuteHeight
            
            if itemEndTime.day! != itemStartTime.day! {
                endHourY = CGFloat(Calendar.current.maximumRange(of: .hour)!.count) * hourHeight + CGFloat(itemEndTime.hour!) * hourHeight
            } else {
                endHourY = CGFloat(itemEndTime.hour!) * hourHeight
            }
            
            let itemMinX = (sectionX + itemMargin.left).toDecimal1Value()
            let itemMinY = (startHourY + startMinuteY + calendarStartY + itemMargin.top).toDecimal1Value()
            let itemMaxX = (itemMinX + (sectionWidth - (itemMargin.left + itemMargin.right))).toDecimal1Value()
            let itemMaxY = (endHourY + endMinuteY + calendarStartY - itemMargin.bottom).toDecimal1Value()
            
            attributes.frame = CGRect(x: itemMinX, y: itemMinY, width: itemMaxX - itemMinX, height: itemMaxY - itemMinY)
            attributes.zIndex = zIndexForElementKind(ICViewKinds.Supplementary.eventCell)
            sectionItemAttributes.append(attributes)
        }
        
        adjustItemsForOverlap(sectionItemAttributes, inSection: section, sectionMinX: sectionX, currentSectionZ: zIndexForElementKind(ICViewKinds.Supplementary.eventCell))
    }
    
    /**
     Setup method for timeHeaderView
     
     - Parameters:
        - collectionView: self CollectionView
        - attributes: the pointer of attributes
     */
    open func layoutTimeHeaderAttributes(collectionView: UICollectionView, attributes: inout UICollectionViewLayoutAttributes) {
        let indexPaths: [IndexPath] = indexPathsForTimeHeader()
        indexPaths.forEach { indexPath in
            (attributes, timeHeaderAttributes) = layoutAttributesForSupplementaryView(at: indexPath, ofKind: Settings.TimeHeader.className, withItemCache: timeHeaderAttributes)
            let date = date(forTimeHeaderAt: indexPath)
            attributes.frame = rect(collectionView, forTimeHeaderAt: date, isLast: (indexPaths.last == indexPath))
            attributes.zIndex = zIndexForElementKind(Settings.TimeHeader.className)
        }
        
        // background
        (attributes, timeHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0), ofKind: Settings.TimeHeaderBackground.className, withItemCache: timeHeaderBackgroundAttributes)
        attributes.frame = CGRect(
            x: fmax(collectionView.contentOffset.x, 0),
            y: collectionView.contentOffset.y,
            width: timeHeaderWidth,
            height: collectionView.frame.height + (safeAreaInsets?.top ?? 0) + (safeAreaInsets?.bottom ?? 0)
        )
        attributes.zIndex = zIndexForElementKind(Settings.TimeHeaderBackground.className)
    }
    
    open func layoutCurrentTimelineAttributes(sectionIndexes: NSIndexSet, collectionView: UICollectionView, attributes: inout UICollectionViewLayoutAttributes) {
        let calendarMinX = timeHeaderWidth + contentsMargin.left
        let contentMinY = contentsMargin.top + (isHiddenTopDate ? 0 : dateHeaderHeight)
        
        sectionIndexes.enumerate(_:) { (section, _) in
            let sectionMinX = calendarMinX + sectionWidth * CGFloat(section)
            let timeY = contentMinY + (CGFloat(currentTimeComponents.hour!).toDecimal1Value() * hourHeight + CGFloat(currentTimeComponents.minute!) * minuteHeight)
            let calendarGridMinY = timeY - (defaultGridThickness / 2.0).toDecimal1Value() - defaultCurrentTimelineHeight/2
            
            (attributes, currentTimelineAttributes) = layoutAttributesForSupplementaryView(at: IndexPath(item: 0, section: section), ofKind: Settings.Timeline.className, withItemCache: currentTimelineAttributes)
            attributes.frame = CGRect(x: sectionMinX, y: calendarGridMinY, width: sectionWidth, height: defaultCurrentTimelineHeight)
            attributes.zIndex = zIndexForElementKind(Settings.Timeline.className)
        }
    }
    
    open func layoutCornerHeaderAttributes(collectionView: UICollectionView, attributes: inout UICollectionViewLayoutAttributes) {
        (attributes, cornerHeaderAttributes) = layoutAttributesForSupplementaryView(at: IndexPath(item: 0, section: 0), ofKind: Settings.DateCorner.className, withItemCache: cornerHeaderAttributes)
        attributes.frame = CGRect(origin: collectionView.contentOffset, size: CGSize(width: timeHeaderWidth, height: isHiddenTopDate ? max(dateHeaderHeight, allDayHeaderHeight) : dateHeaderHeight + allDayHeaderHeight))
        attributes.zIndex = zIndexForElementKind(Settings.DateCorner.className)
    }
    
    open func layoutAllDayHeaderAttributes(sectionIndexes: NSIndexSet, collectionView: UICollectionView, attributes: inout UICollectionViewLayoutAttributes) {
        let calendarContentMinX = timeHeaderWidth + contentsMargin.left
        let headerMinY = collectionView.contentOffset.y + (isHiddenTopDate ? 0 : dateHeaderHeight)
        
        sectionIndexes.enumerate(_:) { (section, _) in
            let sectionMinX = calendarContentMinX + sectionWidth * CGFloat(section)
            (attributes, allDayHeaderAttributes) = layoutAttributesForSupplementaryView(at: IndexPath(item: 0, section: section), ofKind: Settings.AllDayHeader.className, withItemCache: allDayHeaderAttributes)
            attributes.frame = CGRect(
                x: sectionMinX,
                y: headerMinY + (isHiddenTopDate ? allDayContentsMargin.top : 0),
                width: sectionWidth,
                height: isHiddenTopDate ? max(dateHeaderHeight, allDayHeaderHeight) : allDayHeaderHeight
            )
            attributes.zIndex = zIndexForElementKind(Settings.AllDayHeader.className)
        }
        
        // background
        (attributes, allDayHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0), ofKind: Settings.AllDayHeaderBackground.className, withItemCache: allDayHeaderBackgroundAttributes)
        attributes.frame = CGRect(
            x: collectionView.contentOffset.x,
            y: headerMinY,
            width: collectionViewContentSize.width,
            height: isHiddenTopDate ? max(dateHeaderHeight, allDayHeaderHeight) : allDayHeaderHeight
        )
        attributes.zIndex = zIndexForElementKind(Settings.AllDayHeaderBackground.className)
        
        // corner
        (attributes, allDayCornerAttributes) = layoutAttributesForSupplementaryView(at: IndexPath(item: 0, section: 0), ofKind: Settings.AllDayCorner.className, withItemCache: allDayCornerAttributes)

        attributes.frame = CGRect(
            x: needsToExpendAllDayHeader ? collectionView.contentOffset.x : -timeHeaderWidth,
            y: headerMinY,
            width: timeHeaderWidth,
            height: isHiddenTopDate ? max(dateHeaderHeight, allDayHeaderHeight) : allDayHeaderHeight
        )
        attributes.zIndex = zIndexForElementKind(Settings.AllDayCorner.className)
    }
    
    open func layoutAllDayCornerAttributes(collectionView: UICollectionView, attributes: inout UICollectionViewLayoutAttributes, headerMinY: CGFloat) {
        (attributes, allDayCornerAttributes) = layoutAttributesForSupplementaryView(at: IndexPath(item: 0, section: 0), ofKind: Settings.AllDayCorner.className, withItemCache: allDayCornerAttributes)
        attributes.frame = CGRect(
            x: collectionView.contentOffset.x,
            y: headerMinY,
            width: timeHeaderWidth,
            height: isHiddenTopDate ? max(dateHeaderHeight, allDayHeaderHeight) : allDayHeaderHeight
        )
        attributes.zIndex = zIndexForElementKind(Settings.AllDayCorner.className)
    }
    
    open func layoutAttributesForCell(at indexPath: IndexPath, withItemCache itemCache: AttDic) -> (UICollectionViewLayoutAttributes, AttDic) {
        var layoutAttributes = itemCache[indexPath]
        
        if layoutAttributes == nil {
            var _itemCache = itemCache
            layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            _itemCache[indexPath] = layoutAttributes
            return (layoutAttributes!, _itemCache)
        } else {
            return (layoutAttributes!, itemCache)
        }
    }
    
    open func adjustItemsForOverlap(_ sectionItemAttributes: [UICollectionViewLayoutAttributes], inSection: Int, sectionMinX: CGFloat, currentSectionZ: Int) {
        let (maxOverlapIntervalCount, overlapGroups) = groupOverlapItems(items: sectionItemAttributes)
        guard maxOverlapIntervalCount > 1 else { return }
        
        let sortedOverlapGroups = overlapGroups.sorted(by: { $0.count > $1.count })
        var adjustedItems = Set<UICollectionViewLayoutAttributes>()
        var sectionZ = currentSectionZ
        
        // First draw the largest overlap items layout (only this case itemWidth is fixed and always at the right position)
        let largestOverlapCountGroup = sortedOverlapGroups[0]
        setItemsAdjustedAttributes(fullWidth: sectionWidth, items: largestOverlapCountGroup, currentMinX: sectionMinX, sectionZ: &sectionZ, adjustedItems: &adjustedItems)
        
        for index in 1..<sortedOverlapGroups.count {
            let group = sortedOverlapGroups[index]
            var unadjustedItems = [UICollectionViewLayoutAttributes]()
            // unavailable area and already sorted
            var adjustedRanges = [ClosedRange<CGFloat>]()
            group.forEach {
                if adjustedItems.contains($0) {
                    adjustedRanges.append($0.frame.minX...$0.frame.maxX)
                } else {
                    unadjustedItems.append($0)
                }
            }
            guard adjustedRanges.count > 0 else {
                // No need to recalulate the layout
                setItemsAdjustedAttributes(fullWidth: sectionWidth, items: group, currentMinX: sectionMinX, sectionZ: &sectionZ, adjustedItems: &adjustedItems)
                continue
            }
            guard unadjustedItems.count > 0 else { continue }
            
            let availableRanges = getAvailableRanges(sectionRange: sectionMinX...sectionMinX + sectionWidth - itemMargin.right, adjustedRanges: adjustedRanges)
            let minItemDivisionWidth = (sectionWidth / CGFloat(largestOverlapCountGroup.count)).toDecimal1Value()
            var i = 0, j = 0
            while i < unadjustedItems.count && j < availableRanges.count {
                let availableRange = availableRanges[j]
                let availableWidth = availableRange.upperBound - availableRange.lowerBound
                let availableMaxItemsCount = Int(round(availableWidth / minItemDivisionWidth))
                let leftUnadjustedItemsCount = unadjustedItems.count - i
                if leftUnadjustedItemsCount <= availableMaxItemsCount {
                    // All left unadjusted items can evenly divide the current available area
                    // add itemMargin.right for keep size, because `setItemsAdjustedAttributes()` subtract itemMargin.right
                    setItemsAdjustedAttributes(fullWidth: availableWidth+itemMargin.right, items: Array(unadjustedItems[i..<unadjustedItems.count]), currentMinX: availableRange.lowerBound, sectionZ: &sectionZ, adjustedItems: &adjustedItems)
                    break
                } else {
                    // This current available interval cannot afford all left unadjusted items
                    // add itemMargin.right for keep size, because `setItemsAdjustedAttributes()` subtract itemMargin.right
                    setItemsAdjustedAttributes(fullWidth: availableWidth+itemMargin.right, items: Array(unadjustedItems[i..<i+availableMaxItemsCount]), currentMinX: availableRange.lowerBound, sectionZ: &sectionZ, adjustedItems: &adjustedItems)
                    i += availableMaxItemsCount
                    j += 1
                }
            }
        }
    }
    
    
    // MARK: - Date
    open func date(forSection section: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: section, to: currentInitDate)!
    }
    
    open func date(forContentOffset contentOffset: CGPoint) -> Date {
        let adjustedX = contentOffset.x + sectionWidth/2 - contentsMargin.left
        let section = Int(adjustedX / sectionWidth)
        return date(forSection: section)
    }
    
    open func dates(forInCurrentPage collectionView: UICollectionView, isScrolling: Bool) -> [Date] {
        var dates = [Date]()

        if !isScrolling {
            let passedDates: Int = Int(collectionView.contentOffset.x / sectionWidth)
            for i in passedDates ..< passedDates + currentSettings.numOfDays {
                dates.append(currentInitDate.set(day: currentInitDate.day + i))
            }
            return dates
        }
        
        var startDate = date(forContentOffset: collectionView.contentOffset)
        let contentViewWidth: CGFloat = collectionView.frame.width - timeHeaderWidth - contentsMargin.left - contentsMargin.right
        let endDate = date(forContentOffset: CGPoint(
            x: collectionView.contentOffset.x + contentViewWidth,
            y: collectionView.contentOffset.y
        ))
        repeat {
            dates.append(startDate)
            startDate = startDate.add(component: .day, value: 1)
        } while startDate <= endDate
        
        return dates
    }
    
    open func date(forTimeHeaderAt indexPath: IndexPath) -> Date {
        var components = daysForSection(indexPath.section)
        
        let hour = indexPath.item / (60/moveTimeInterval)
        let minute = Int(CGFloat(indexPath.item).truncatingRemainder(dividingBy: CGFloat(60/moveTimeInterval))) * moveTimeInterval
        
        components.hour = hour
        components.minute = minute
        
        return Calendar.current.date(from: components)!
    }
    
    open func date(forDateHeaderAt indexPath: IndexPath) -> Date {
        let day = delegate.collectionView(collectionView!, layout: self, dayForSection: indexPath.section)
        return day.startOfDay
    }
    
    open func daysForSection(_ section: Int) -> DateComponents {
        guard let cv = collectionView else { fatalError() }
        if let components = cachedDayDateComponents[section] {
            return components
        }
        
        let day = delegate.collectionView(cv, layout: self, dayForSection: section)
        let startOfDay = day.startOfDay
        let dayDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startOfDay)
        cachedDayDateComponents[section] = dayDateComponents
        return dayDateComponents
    }
    
    open func startTimeForIndexPath(_ indexPath: IndexPath) -> DateComponents {
        if cachedStartTimeDateComponents[indexPath] != nil {
            return cachedStartTimeDateComponents[indexPath]!
        } else {
            let date = delegate.collectionView(collectionView!, layout: self, startTimeForItemAtIndexPath: indexPath)
            cachedStartTimeDateComponents[indexPath] = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
            return cachedStartTimeDateComponents[indexPath]!
        }
    }
    
    open func endTimeForIndexPath(_ indexPath: IndexPath) -> DateComponents {
        if cachedEndTimeDateComponents[indexPath] != nil {
            return cachedEndTimeDateComponents[indexPath]!
        } else {
            let date = delegate.collectionView(collectionView!, layout: self, endTimeForItemAtIndexPath: indexPath)
            cachedEndTimeDateComponents[indexPath] = Calendar.current.dateComponents([.day, .hour, .minute], from: date)
            return cachedEndTimeDateComponents[indexPath]!
        }
    }
    
    /// Get date excluding time from point.X for **gesture point in collectionView only** rather than collectionView contentOffset
    open func date(forCollectionViewAt point: CGPoint) -> Date {
        let adjustedX = point.x - timeHeaderWidth - contentsMargin.left
        let section = Int(adjustedX / sectionWidth)
        let date = date(forSection: section)
        let time = time(forCollectionViewPoint: point)
        return date.set(hour: time.hour, minute: time.minute, second: time.second)
    }
    
    /// Get (hour, minute) from point.X for **gesture point in collectionView only** rather than collectionView contentOffset
    open func time(forCollectionViewPoint point: CGPoint) -> (hour: Int, minute: Int, second: Int) {
        let headerHeight: CGFloat = isHiddenTopDate ? 0 : dateHeaderHeight
        var adjustedY = point.y - contentsMargin.top - headerHeight
        let maxY: CGFloat = collectionView!.contentSize.height - contentsMargin.top - contentsMargin.bottom - allDayHeaderHeight - headerHeight
        adjustedY = max(0, min(adjustedY, maxY))
        let hour = Int(adjustedY / hourHeight)
        let minute = Int((adjustedY / hourHeight - CGFloat(hour)) * 60)
        return (hour, minute, 0)
    }
    
    /// Get startDate & endDate from cell's rect on CollectionView
    open func dateRange(forCell rect: CGRect, type action: LongTapType?, originStart: Date, originEnd: Date?) -> (startDate: Date, endDate: Date) {
        let base = date(forCollectionViewAt: CGPoint(x: rect.minX, y: rect.minY))
        
        switch action {
        case .addNew:
            // adjust start & end time by same way as highlight time
            let startIndex = indexPath(forHighlightAt: rect.origin)
            let endIndex = indexPath(forHighlightAt: CGPoint(x: rect.minX, y: rect.maxY))
            let startTime = date(forTimeHeaderAt: startIndex)
            let endTime = date(forTimeHeaderAt: endIndex)
            return (
                base.set(hour: startTime.hour, minute: startTime.minute),
                base.set(hour: (endTime.hour < startTime.hour) ? 24 : endTime.hour, minute: endTime.minute)
            )
        default:
            let startTime = date(forTimeHeaderAt: indexPath(forHighlightAt: rect.origin))
            let distance = abs(originStart.distance(to: originEnd ?? Date()))
            return (
                base.set(hour: startTime.hour, minute: startTime.minute),
                base.set(hour: startTime.hour, minute: startTime.minute).addingTimeInterval(TimeInterval(distance))
            )
        }
    }
}


// MARK: - CGPoint
extension ICViewFlowLayout {
    public func offset(forCurrentTimeline scrollView: UIScrollView) -> CGPoint {
        let calendarContentMinY = dateHeaderHeight + contentsMargin.top
        let timeY = calendarContentMinY + (CGFloat(currentTimeComponents.hour!).toDecimal1Value() * hourHeight + CGFloat(currentTimeComponents.minute!) * minuteHeight)
        let timelineOffsetY = timeY - (defaultGridThickness / 2.0).toDecimal1Value() - defaultCurrentTimelineHeight/2
        
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
        let offsetY = timelineOffsetY - scrollView.center.y
        return CGPoint(x: scrollView.contentOffset.x, y: min(max(offsetY, -allDayHeaderHeight), maxOffsetY))
    }
    
    public func offset(forHorizontalBounce scrollView: UIScrollView) -> CGPoint {
        var offset: CGPoint = scrollView.contentOffset
        
        let min: CGFloat = 0
        let max: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        if offset.x <= min {
            offset.x = min
        } else if offset.x >= max {
            offset.x = max
        }
        
        return CGPoint(x: offset.x, y: offset.y)
    }
    
    /// Block position for new cell from tap position.
    /// If set minimum  block height, set specific BlockMinute. Default value is 30min.
    public func point(forStartBlockFrom position: CGPoint, withMinimumBlockMinute minute: Int = 30) -> CGPoint {
        let contentMinX: CGFloat = timeHeaderWidth + contentsMargin.left
        let contentMinY: CGFloat = (isHiddenTopDate ? 0 : dateHeaderHeight) + contentsMargin.bottom + allDayHeaderHeight
        
        let size: CGSize = CGSize(width: sectionWidth, height: CGFloat(minute) / 60 * hourHeight)
        
        let blockDatePositionX: Int = Int((position.x - contentMinX) / size.width)
        let blockHourPositionY: Int = Int((position.y - contentMinY) / size.height)
        
        let minX: CGFloat = CGFloat(blockDatePositionX) * size.width + contentMinX
        let minY: CGFloat = CGFloat(blockHourPositionY) * size.height + contentMinY
        
        return CGPoint(x: minX, y: minY)
    }
}


// MARK: - Layout
extension ICViewFlowLayout {
    // MARK: UI, Layout
    public func setupUIParams(hourHeight: CGFloat? = nil, timeHeaderWidth: CGFloat? = nil, dateHeaderHeight: CGFloat? = nil) {
        self.hourHeight = hourHeight ?? defaultHourHeight
        self.dateHeaderHeight = dateHeaderHeight ?? defaultDateHeaderHeight
        self.timeHeaderWidth = timeHeaderWidth ?? defaultTimeHeaderWidth
    }
    
    public func initializeMinuteTick() {
        if #available(iOS 10.0, *) {
            minuteTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
                self?.minuteTick()
            })
        } else {
            minuteTimer = WeakTimer.scheduleTimer(timeInterval: 60, target: self, repeats: true, action: { [weak self] _ in
                self?.minuteTick()
            })
        }
    }
    
    /// Group all the overlap items depending on the maximum overlap items
    ///
    /// Refer to the previous algorithm but integrated with groups
    /// - Parameter items: All the items(cells) in the UICollectionView
    /// - Returns: maxOverlapIntervalCount and all the maximum overlap groups
    public func groupOverlapItems(items: [UICollectionViewLayoutAttributes]) -> (maxOverlapIntervalCount: Int, overlapGroups: [[UICollectionViewLayoutAttributes]]) {
        var maxOverlap = 0, currentOverlap = 0
        let sortedMinYItems = items.sorted(by: { $0.frame.minY < $1.frame.minY })
        let sortedMaxYItems = items.sorted(by: { $0.frame.maxY < $1.frame.maxY })
        let itemCount = items.count
        
        var i = 0, j = 0
        var overlapGroups = [[UICollectionViewLayoutAttributes]]()
        var currentOverlapGroup = [UICollectionViewLayoutAttributes]()
        var shouldAppendToOverlapGroups: Bool = false
        while i < itemCount && j < itemCount {
            if sortedMinYItems[i].frame.minY < sortedMaxYItems[j].frame.maxY {
                currentOverlap += 1
                maxOverlap = max(maxOverlap, currentOverlap)
                shouldAppendToOverlapGroups = true
                currentOverlapGroup.append(sortedMinYItems[i])
                i += 1
            } else {
                currentOverlap -= 1
                // Should not append to group with continuous minus
                if shouldAppendToOverlapGroups {
                    if currentOverlapGroup.count > 1 { overlapGroups.append(currentOverlapGroup) }
                    shouldAppendToOverlapGroups = false
                }
                currentOverlapGroup.removeAll(where: { $0 == sortedMaxYItems[j] })
                j += 1
            }
        }
        // Add last currentOverlapGroup
        if currentOverlapGroup.count > 1 { overlapGroups.append(currentOverlapGroup) }
        return (maxOverlap, overlapGroups)
    }
    
    /// Set provided items correct adjusted layout attributes
    ///
    /// - Parameters:
    ///   - fullWidth: Full width for items can be divided
    ///   - items: All the items need to be adjusted
    ///   - currentMinX: Current minimum contentOffset(start position of the first item)
    ///   - sectionZ: section Z value (inout)
    ///   - adjustedItems: already adjused item (inout)
    public func setItemsAdjustedAttributes(fullWidth: CGFloat,
                                            items: [UICollectionViewLayoutAttributes],
                                            currentMinX: CGFloat,
                                            sectionZ: inout Int,
                                            adjustedItems: inout Set<UICollectionViewLayoutAttributes>) {
        let divisionWidth = (fullWidth - itemMargin.left - itemMargin.right)
        let spacing = CGFloat(1)
        let itemWidth = (divisionWidth / CGFloat(items.count)).toDecimal1Value()
        for (index, itemAttribute) in items.enumerated() {
            itemAttribute.frame.size = CGSize(width: itemWidth - spacing, height: itemAttribute.frame.height)
            itemAttribute.frame.origin.x = currentMinX+itemMargin.left + CGFloat(index)*itemWidth
            itemAttribute.zIndex = sectionZ
            sectionZ += 1
            adjustedItems.insert(itemAttribute)
        }
    }
    
    // Get current available ranges for unadjusted items with given current section range and already adjusted ranges
    ///
    /// - Parameters:
    ///   - sectionRange: current section minX and maxX range
    ///   - adjustedRanges: already adjusted ranges(cannot draw items on these ranges)
    /// - Returns: All available ranges after substract all adjusted ranges
    public func getAvailableRanges(sectionRange: ClosedRange<CGFloat>, adjustedRanges: [ClosedRange<CGFloat>]) -> [ClosedRange<CGFloat>] {
        var availableRanges: [ClosedRange<CGFloat>] = [sectionRange]
        let sortedAdjustedRange = adjustedRanges.sorted(by: { $0.lowerBound < $1.lowerBound })
        for adjustedRange in sortedAdjustedRange {
            let lastAvailableRange = availableRanges.last!
            if adjustedRange.lowerBound > lastAvailableRange.lowerBound + itemMargin.left + itemMargin.right {
                var currentAvailableRanges = [ClosedRange<CGFloat>]()
                if adjustedRange.upperBound + itemMargin.right >= lastAvailableRange.upperBound {
                    // Adjusted range covers right part of the last available range
                    let leftAvailableRange = lastAvailableRange.lowerBound...adjustedRange.lowerBound
                    currentAvailableRanges.append(leftAvailableRange)
                } else {
                    // Adjusted range is in middle of the last available range
                    let leftAvailableRange = lastAvailableRange.lowerBound...adjustedRange.lowerBound
                    let rightAvailableRange = adjustedRange.upperBound...lastAvailableRange.upperBound
                    currentAvailableRanges = [leftAvailableRange, rightAvailableRange]
                }
                availableRanges.removeLast()
                availableRanges += currentAvailableRanges
            } else {
                if adjustedRange.upperBound > lastAvailableRange.lowerBound {
                    let avairableRange = adjustedRange.upperBound...lastAvailableRange.upperBound
                    availableRanges.removeLast()
                    availableRanges.append(avairableRange)
                }
            }
        }
        return availableRanges
    }
    
    /**
     Setup method for VerticalGridLine
     
     - Parameters:
        - attributes: the pointer of attributes
     */
    public func layoutVerticalGridLineAttributes(section: Int, sectionX: CGFloat, calendarGridMinY: CGFloat, sectionHeight: CGFloat, attributes: inout UICollectionViewLayoutAttributes) {
        (attributes, verticalGridlineAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: section), ofKind: ICViewKinds.Decoration.verticalGridline, withItemCache: verticalGridlineAttributes)
        attributes.frame = CGRect(x: (sectionX - defaultGridThickness / 2.0).toDecimal1Value(), y: calendarGridMinY, width: defaultGridThickness, height: sectionHeight)
        attributes.zIndex = zIndexForElementKind(ICViewKinds.Decoration.verticalGridline)
    }
    
    /**
     Setup method for HorizontalGridLine
     
     - Parameters:
        - attributes: the pointer of attributes
     */
    public func layoutHorizontalGridLineAttributes(collectionView: UICollectionView, calendarStartX: CGFloat, calendarStartY: CGFloat, attributes: inout UICollectionViewLayoutAttributes) {
        var horizontalGridlineIndex = 0
        let gridWidth = collectionViewContentSize.width - timeHeaderWidth - contentsMargin.left - contentsMargin.right
        
        for hour in 0...24 {
            (attributes, horizontalGridlineAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: horizontalGridlineIndex, section: 0), ofKind: ICViewKinds.Decoration.horizontalGridline, withItemCache: horizontalGridlineAttributes)
            let gridlineXOffset = calendarStartX
            let gridlineMinX = fmax(gridlineXOffset, collectionView.contentOffset.x + gridlineXOffset)
            let gridlineMinY = (calendarStartY + (hourHeight * CGFloat(hour))) - (defaultGridThickness / 2.0).toDecimal1Value()
            let gridlineWidth = fmin(gridWidth, collectionView.frame.width)
            
            attributes.frame = CGRect(x: gridlineMinX, y: gridlineMinY, width: gridlineWidth, height: defaultGridThickness)
            attributes.zIndex = zIndexForElementKind(ICViewKinds.Decoration.horizontalGridline)
            horizontalGridlineIndex += 1
            
            // hourGridDivision...
        }
    }
    
    public func layoutAttributesForSupplementaryView(at indexPath: IndexPath, ofKind kind: String, withItemCache itemCache: AttDic) -> (UICollectionViewLayoutAttributes, AttDic) {
        var layoutAttributes = itemCache[indexPath]
        
        if let _layoutAttributes = layoutAttributes {
            return (_layoutAttributes, itemCache)
        } else {
            var _itemCache = itemCache
            layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind, with: indexPath)
            _itemCache[indexPath] = layoutAttributes
            return (layoutAttributes!, _itemCache)
        }
    }
    
    public func layoutAttributesForDecorationView(at indexPath: IndexPath, ofKind kind: String, withItemCache itemCache: AttDic) -> (UICollectionViewLayoutAttributes, AttDic) {
        var layoutAttributes = itemCache[indexPath]
        
        if let _layoutAttributes = layoutAttributes {
            return (_layoutAttributes, itemCache)
        } else {
            var _itemCache = itemCache
            layoutAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: kind, with: indexPath)
            _itemCache[indexPath] = layoutAttributes
            return (layoutAttributes!, _itemCache)
        }
    }
    
    func indexPathsForTimeHeader() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        var item: Int = 0
        
        for hour in 0...24 {
            let memories = hour != displayTimeRange.endTime ? (60/moveTimeInterval) : 1
            for _ in 0..<memories {
                indexPaths.append(IndexPath(item: item, section: 0))
                item += 1
            }
        }
        
        return indexPaths
    }
}
