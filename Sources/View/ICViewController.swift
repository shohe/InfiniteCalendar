//
//  ICViewController.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/26.
//

import SwiftUI

open class ICViewController<View: CellableView, Cell: ViewHostingCell<View>, Settings: ICSettings>: UIViewController {
    
    public var calendarView: ICView<View,Cell,Settings>!
    public var currentNumOfDays: Int = 0
    
    private var isUpdated: Bool = false
    private var updateWorkItem: DispatchWorkItem?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // TODO: Support device orientation change
    }
    
    open func setupCalendarView(events: [View.VM], settings: Settings) {
        calendarView = ICView(parentViewController: self)
        calendarView.setupCalendar(events: events, settings: settings)
        currentNumOfDays = settings.numOfDays
        self.view = calendarView
        
        // set initialize offset by currentTimeline with animate
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { [weak self] in
            guard let self = self else { return }
            var initOffset = self.calendarView.layout.offset(forCurrentTimeline: self.calendarView.collectionView)
            initOffset.y += initOffset.y > 0 ? self.calendarView.layout.allDayHeaderHeight : 0
            self.calendarView.collectionView.setContentOffset(initOffset, animated: true)
        }
    }
    
    public func setDelegate(_ delegate: ICViewDelegate<View,Cell,Settings>) {
        calendarView.delegate = delegate /// base delegate
        calendarView.delegateForLongTap = delegate
    }
    
    public func updateCalendar(events: [View.VM], settings: Settings, targetDate: Date?) {
        guard !isUpdated else { return }
        isUpdated = true
        updateWorkItem?.cancel()
        updateWorkItem = DispatchWorkItem { self.isUpdated = false }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: updateWorkItem!)
        
        let isUpdateNumOfDays: Bool = (currentNumOfDays != settings.numOfDays)
        
        calendarView.updateEvents(events)
        calendarView.updateSettings(settings)
        
        if let targetDate {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.calendarView.resetCollectionViewOffset(by: targetDate.startOfDay, animated: true)
            }
        }
        
        if isUpdateNumOfDays {
            currentNumOfDays = settings.numOfDays
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.calendarView.resetCollectionViewOffset(by: self.calendarView.currentDate.startOfDay, animated: false)
            }
        }
    }
}

