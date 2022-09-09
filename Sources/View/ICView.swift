//
//  ICView.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/05.
//

import SwiftUI


/// This class is extended longTap action based on the ICBaseView
open class ICView<View: CellableView, Cell: ViewHostingCell<View>, Settings: ICSettings>: ICBaseView<View, Cell, Settings>, UIGestureRecognizerDelegate {
    
    public typealias HightlightIndex = (IndexPath?, IndexPath?)
    
    public struct CurrentEditingCellInfo {
        public var viewModel: View.VM!
        public var cellRect: CGRect!
        public var indexPath: IndexPath!
        public var tapPosition: CGPoint? // Tap position on EditingView
        public var allOpacityContentViews = [UIView]()
        public var highlightPath: HightlightIndex?
    }
    
    /// When moving the longTap view, if it causes the collectionView scrolling
    public var isScrolling: Bool = false
    public var isLongTapping: Bool = false
    public var currentLongTapType: LongTapType?
    public var longTapView: UIView?
    public var currentEditingCellInfo: CurrentEditingCellInfo?
    
    /// AutoScroll
    public var autoScrollTimer: Timer?
    public var currentAutoScrollDirection: ScrollDirection?
    open var autoScrollSpeedRange: ClosedRange<CGFloat> { return (0.5...4.0) /* by 0.01 sec */ }
    
    public weak var delegateForLongTap: ICViewDelegate<View,Cell,Settings>?
    
    public var longTapTypes: [LongTapType] = [LongTapType]()
    public var moveTimeMinInterval: Int = 15
    public var addNewDurationMins: Int = 60
    
    public var movingCellOpacity: Float = 0.6
    
    private var isStartedLongGesture: Bool = false
    
    open var longTapTopMarginY: CGFloat {
        return layout.allDayHeaderHeight + (isHiddenTopDate ? 0 : layout.dateHeaderHeight)
    }
    open var longTapBottomMarginY: CGFloat { return frame.height }
    open var longTapLeftMarginX: CGFloat { return layout.timeHeaderWidth }
    open var longTapRightMarginX: CGFloat { return frame.width }
    
    
    public override init(parentViewController: UIViewController) {
        super.init(parentViewController: parentViewController)
        setupGestures()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
    }
    
    open func initLongTapView(selectedCell: Cell?, type: LongTapType, startDate: Date) -> UIView {
        var vm = View.VM.create(from: selectedCell?.viewModel, state: type == .addNew ? .resizing : .moving)
        
        if type == .addNew {
            vm.startDate = startDate
            vm.intraStartDate = startDate
        }
        currentEditingCellInfo?.viewModel = vm
        
        let new = Cell()
        new.frame = CGRect(origin: .zero, size: CGSize(width: layout.sectionWidth, height: layout.hourHeight))
        if let selectedCell = selectedCell {
            new.frame.size = selectedCell.frame.size
        }
        new.configure(parentVC: nil, viewModel: vm)
        
        return new
    }
    
    open func highlightTime(type: LongTapType, gesture: UILongPressGestureRecognizer) {
        guard let editingView = longTapView else { return }
        
        switch type {
        case .addNew:
            let start = layout.indexPath(forHighlightAt: editingView.frame.origin)
            let end = layout.indexPath(forHighlightAt: CGPoint(x: editingView.frame.origin.x, y: editingView.frame.origin.y+editingView.frame.height))
            currentEditingCellInfo!.highlightPath = (start, end)
        case .move:
            let highlightIndexPath = layout.indexPath(forHighlightAt: editingView.frame.origin)
            currentEditingCellInfo!.highlightPath = (highlightIndexPath, nil)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5.0, options: .curveEaseOut) {
            self.dataSource?.hightlightTimeHeader(self.currentEditingCellInfo?.highlightPath)
        } completion: { _ in }
    }
    
    // MARK: - Gesture
    private func setupGestures() {
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongTapGesture(_:)))
        longTapGesture.delegate = self
        collectionView.addGestureRecognizer(longTapGesture)
    }
    
    private func checkLongTapPosition(gesture: UILongPressGestureRecognizer) -> Bool {
        let location = gesture.location(in: self)
        let isTapDateHeader = location.y <= longTapTopMarginY
        let isTapTimeHeader = location.x <= (layout.timeHeaderWidth + layout.contentsMargin.left)
        return (!isTapDateHeader && !isTapTimeHeader) || isStartedLongGesture
    }
    
    @objc private func handleLongTapGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let gestureState = gestureRecognizer.state
        let gesturePoint = gestureRecognizer.location(in: collectionView)
        
        var currentMovingCell: Cell!
        
        if currentEditingCellInfo == nil {
            currentEditingCellInfo = CurrentEditingCellInfo()
        }
        
        guard checkLongTapPosition(gesture: gestureRecognizer) else { return }
        
        if !isLongTapping {
            if let indexPath = collectionView.indexPathForItem(at: gesturePoint), let cell = collectionView.cellForItem(at: indexPath) as? Cell {
                currentLongTapType = .move
                currentMovingCell = cell
            } else {
                currentLongTapType = .addNew
            }
            isLongTapping = true
        }
        
        switch gestureState {
        case .began:
            isStartedLongGesture = true
            handleLongTapBegan(currentMovingCell, gesture: gestureRecognizer)
        case .changed:
            guard isStartedLongGesture else { return }
            handleLongTapChanged(gesture: gestureRecognizer)
        case .cancelled:
            guard isStartedLongGesture else { return }
            handleLongTapCancelled()
        case .ended:
            guard isStartedLongGesture else { return }
            isStartedLongGesture = false
            handleLongTapEnded()
        default: break
        }
        
        if gestureState == .ended || gestureState == .cancelled {
            isLongTapping = false
            
            if currentLongTapType == .move {
                currentEditingCellInfo?.allOpacityContentViews.forEach { $0.layer.opacity = 1 }
                currentEditingCellInfo?.allOpacityContentViews.removeAll()
            }
            
            currentEditingCellInfo = nil
            return
        }
    }
    
    open func handleLongTapBegan(_ movingCell: Cell?, gesture: UILongPressGestureRecognizer) {
        guard currentEditingCellInfo != nil else { return }
        let point = gesture.location(in: collectionView)
        
        switch currentLongTapType {
        case .addNew:
            let rect: CGRect = layout.rect(forNewCellAt: point, withSpecificMinute: addNewDurationMins)
            currentEditingCellInfo!.cellRect = rect
            
            let start = layout.indexPath(forHighlightAt: rect.origin)
            let end = layout.indexPath(forHighlightAt: CGPoint(x: rect.origin.x, y: rect.origin.y+rect.height))
            currentEditingCellInfo!.highlightPath = (start, end)
        case .move:
            guard let cell = movingCell else { break }
            let cPoint = gesture.location(in: collectionView)
            let sPoint = gesture.location(in: self)
            let tapPoint = CGPoint(x: point.x - cell.frame.minX, y: point.y - cell.frame.minY)
            let editCellRect = layout.rect(
                forMoveCell: cell.frame,
                vm: cell.viewModel,
                collectionPointAt: cPoint,
                screenPointAt: sPoint,
                withPointInView: tapPoint
            )
            
            currentEditingCellInfo?.cellRect = editCellRect
            cell.frame.size = CGSize(width: cell.frame.width, height: editCellRect?.height ?? cell.frame.height)
            
            let highlightIndexPath = layout.indexPath(forHighlightAt: cell.frame.origin)
            currentEditingCellInfo?.highlightPath = (highlightIndexPath, nil)
            currentEditingCellInfo?.tapPosition = tapPoint
            
            // To display whole cell view, if cell was coverd by header
            let minY: CGFloat = collectionView.contentOffset.y + longTapTopMarginY
            if currentEditingCellInfo!.cellRect.minY < minY {
                collectionView.contentOffset = CGPoint(
                    x: collectionView.contentOffset.x,
                    y: collectionView.contentOffset.y - (minY - currentEditingCellInfo!.cellRect.minY)
                )
            }
        case .none: return
        }
        
        let longTapViewStartDate = layout.date(forCollectionViewAt: point)
        longTapView = initLongTapView(selectedCell: movingCell, type: currentLongTapType!, startDate: longTapViewStartDate)
        longTapView!.frame = currentEditingCellInfo!.cellRect
        longTapView!.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        collectionView.insertSubview(longTapView!, at: 50) // adjust zIndex for date header
        vibrateFeedback?.impactOccurred()
        
        if currentLongTapType == .move {
            currentEditingCellInfo!.viewModel = movingCell?.viewModel
            getCuurrentMovingCells().forEach {
                $0.contentView.layer.opacity = movingCellOpacity
                currentEditingCellInfo!.allOpacityContentViews.append($0.contentView)
            }
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5.0, options: .curveEaseOut) {
            self.longTapView!.transform = CGAffineTransform.identity
            self.dataSource?.hightlightTimeHeader(self.currentEditingCellInfo?.highlightPath)
        } completion: { _ in
            // Prepare autoScrollTimer to start AutoScroll on `handleLongTapChanged()`
            self.autoScrollTimer?.invalidate()
            self.autoScrollTimer = nil
        }
    }
    
    private func handleLongTapChanged(gesture: UILongPressGestureRecognizer) {
        guard let info = currentEditingCellInfo,
              let editingView = longTapView,
              let type = currentLongTapType else { return }
        
        switch type {
        case .addNew:
            updateEditingViewRect(gesture: gesture)
            highlightTime(type: .addNew, gesture: gesture)
        case .move:
            let collectionPoint = gesture.location(in: collectionView)
            let selfPoint = gesture.location(in: self)
            let section = layout.section(forCollectionViewPoint: collectionPoint, withPointInSelfView: selfPoint)
            
            // Ignore horizontal auto scrolling
            if currentAutoScrollDirection?.direction == .left || currentAutoScrollDirection?.direction == .right {
                return
            }
            
            let newOrigin: CGPoint = layout.point(forMoveTo: collectionPoint, pointInView: info.tapPosition ?? .zero, withSection: section)
            if newOrigin.x != editingView.frame.origin.x {
                vibrateFeedback?.impactOccurred(intensity: 0.4)
            }
            editingView.frame.origin = newOrigin
            highlightTime(type: .move, gesture: gesture)
        }
        
        // When called `handleLongTapChanged()` start autoScroll
        if autoScrollTimer == nil {
            autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                self.autoScroll(gesture: gesture)
            })
        }
    }
    
    private func handleLongTapCancelled() {
        autoScrollTimer?.invalidate()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.longTapView?.alpha = 0.0
        } completion: { _ in
            self.longTapView?.removeFromSuperview()
        }
        
        guard let info = currentEditingCellInfo, let editingView = longTapView else { return }
        let dateRange = layout.dateRange(forCell: editingView.frame,
                                             type: currentLongTapType,
                                             originStart: info.viewModel.startDate,
                                             originEnd: info.viewModel.endDate)
        delegateForLongTap?.icView(self, didCancel: info.viewModel, startAt: dateRange.startDate, endAt: dateRange.endDate)
    }
    
    open func handleLongTapEnded() {
        autoScrollTimer?.invalidate()
        currentAutoScrollDirection = nil
        
        guard var info = currentEditingCellInfo, let editingView = longTapView else { return }
        
        let dateRange = layout.dateRange(forCell: editingView.frame,
                                             type: currentLongTapType,
                                             originStart: info.viewModel.startDate,
                                             originEnd: info.viewModel.endDate)
        info.viewModel.startDate = dateRange.startDate
        info.viewModel.endDate = dateRange.endDate
        
        let isSmallerThan30Min = dateRange.startDate.distance(to: dateRange.endDate) < TimeInterval(30*60)
        info.viewModel.intraStartDate = dateRange.startDate
        info.viewModel.intraEndDate = isSmallerThan30Min ? dateRange.startDate.addingTimeInterval(TimeInterval(30*60)) : dateRange.endDate
        info.viewModel.editState = nil
        
        switch currentLongTapType {
        case .addNew:
            delegateForLongTap?.icView(self, didAdd: info.viewModel, startAt: dateRange.startDate, endAt: dateRange.endDate)
        case .move:
            delegateForLongTap?.icView(self, didMove: info.viewModel, startAt: dateRange.startDate, endAt: dateRange.endDate)
        case .none: break
        }
        
        longTapView?.removeFromSuperview()
        dataSource?.hightlightTimeHeader(nil)
        
        if settings.withVibrateFeedback {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 0.8)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.vibrateFeedback?.impactOccurred()
            }
        }
    }
    
    private func isOriginalMovingCell(_ cell: UICollectionViewCell) -> Bool {
        if let info = currentEditingCellInfo, let moveVM = info.viewModel, let cell = cell as? Cell, let vm = cell.viewModel {
            return moveVM.id == vm.id
        } else {
            return false
        }
    }
    
    public func getCuurrentMovingCells() -> [UICollectionViewCell] {
        var movingCells = [UICollectionViewCell]()
        for cell in collectionView.visibleCells {
            if isOriginalMovingCell(cell) {
                movingCells.append(cell)
            }
        }
        return movingCells
    }
    
    public func updateEditingViewRect(gesture: UILongPressGestureRecognizer) {
        guard let info = currentEditingCellInfo, let editingView = longTapView, info.cellRect != nil else { return }
        longTapView?.frame = layout.rect(
            forResizeBy: gesture.location(in: collectionView),
            forEditView: editingView,
            withBaseRect: info.cellRect
        )
    }
    
    open func autoScroll(gesture: UILongPressGestureRecognizer) {
        guard let tapView = longTapView else { return }
        
        let minOffsetY: CGFloat = -layout.allDayHeaderHeight
        let scrollableRange = (-layout.allDayHeaderHeight...collectionView.contentSize.height - collectionView.visibleSize.height - layout.allDayHeaderHeight + layout.contentsMargin.bottom + layout.contentsMargin.top)
        
        let newDirection = autoScrollDirection(gesture: gesture)
        if currentAutoScrollDirection?.direction != newDirection.direction {
            currentAutoScrollDirection = newDirection
        } else {
            currentAutoScrollDirection?.autoScrollOffset = newDirection.autoScrollOffset
            currentAutoScrollDirection?.interval += 1
        }
        
        switch currentAutoScrollDirection?.direction {
        case .top, .bottom:
            let offset: CGFloat = CGFloat(currentAutoScrollDirection?.autoScrollOffset ?? 0)
            let newOffsetY: CGFloat = collectionView.contentOffset.y + offset
            let condition: Bool = (currentAutoScrollDirection?.direction == .top) ? (minOffsetY < collectionView.contentOffset.y && scrollableRange.lowerBound < newOffsetY) : (scrollableRange.upperBound > newOffsetY)
            if condition {
                tapView.frame.origin = CGPoint(x: tapView.frame.origin.x, y: tapView.frame.minY + offset)
                collectionView.contentOffset.y = newOffsetY
            }
            
        case .left, .right:
            // Ignore when its not move type
            guard currentLongTapType == .move else { return }
            
            if let interval = currentAutoScrollDirection?.interval, CGFloat(interval).truncatingRemainder(dividingBy: 100) == 0 {
                let collectionPoint = gesture.location(in: collectionView)
                let selfPoint = gesture.location(in: self)
                var section = layout.section(forCollectionViewPoint: collectionPoint, withPointInSelfView: selfPoint)
                if scrollType == .pageScroll { section = section / settings.numOfDays }
                
                if currentAutoScrollDirection?.direction == .left {
                    section -= 1
                } else {
                    section = (scrollType == .pageScroll) ? section+1 : section - (settings.numOfDays-1) + 1
                }
                
                collectionView.setContentOffset(CGPoint(
                    x: (CGFloat(section) * pageWidth).toDecimal1Value(),
                    y: collectionView.contentOffset.y
                ), animated: true)
                
                vibrateFeedback?.impactOccurred(intensity: 0.6)
            }
            
            // Keep tapView position
            var keepPoint = CGPoint(
                x: (currentAutoScrollDirection?.direction == .left) ? layout.timeHeaderWidth + layout.contentsMargin.left : frame.width - layout.contentsMargin.right - tapView.frame.width,
                y: gesture.location(in: self).y - (currentEditingCellInfo?.tapPosition?.y ?? 0)
            )
            keepPoint = convert(keepPoint, to: collectionView)
            tapView.frame.origin = keepPoint
            
        default: break
        }
        
        // update time highlight
        if let type = currentLongTapType {
            highlightTime(type: type, gesture: gesture)
            
            // update view rect if creating event
            if type == .addNew { updateEditingViewRect(gesture: gesture) }
        }
    }
    
    /// Get auto scroll direction with scroll offset by finger position
    ///
    /// Each starting detact distance from each edges.
    /// ```
    ///              30%
    ///               ↑
    ///    15％ ←   Neutral   → 7%
    ///               ↓
    ///              30%
    /// ```
    public func autoScrollDirection(gesture: UILongPressGestureRecognizer) -> ScrollDirection {
        // 30%, 15%, 30%, 7%
        let startScrollInsets: UIEdgeInsets = UIEdgeInsets(top: 0.3, left: 0.15, bottom: 0.3, right: 0.07)
        
        let position = gesture.location(in: self)
        let maxY = collectionView.visibleSize.height
        let maxHeight: CGFloat = maxY - longTapTopMarginY
        
        let positionInsets: UIEdgeInsets = UIEdgeInsets(
            top: (position.y - longTapTopMarginY) / maxHeight,
            left: position.x / collectionView.frame.width,
            bottom: (maxY - position.y) / maxHeight,
            right: (collectionView.frame.width - position.x) / collectionView.frame.width
        )
        
        // (0%) autoScrollSpeedRange.lowerBound |<----------->| autoScrollSpeedRange.upperBound (100%)
        let speedRate: CGFloat = (autoScrollSpeedRange.upperBound - autoScrollSpeedRange.lowerBound) / 100
        
        if positionInsets.top <= startScrollInsets.top {
            let positionRate: CGFloat = CGFloat(Int((1.0 - (positionInsets.top / startScrollInsets.top))*100))
            let speed: CGFloat = autoScrollSpeedRange.lowerBound + (speedRate * positionRate)
            return ScrollDirection(direction: .top, autoScrollOffset: -speed)
            
        } else if positionInsets.bottom <= startScrollInsets.bottom {
            let positionRate: CGFloat = CGFloat(Int((1.0 - (positionInsets.bottom / startScrollInsets.bottom))*100))
            let speed: CGFloat = autoScrollSpeedRange.lowerBound + (speedRate * positionRate)
            return ScrollDirection(direction: .bottom, autoScrollOffset: speed)
            
        } else if positionInsets.left <= startScrollInsets.left {
            return ScrollDirection(direction: .left, autoScrollOffset: 0.0)
        } else if positionInsets.right <= startScrollInsets.right {
            return ScrollDirection(direction: .right, autoScrollOffset: 0.0)
        }
        
        return ScrollDirection(direction: .neutral, autoScrollOffset: 0)
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // TODO: ..
        return true
    }
}
