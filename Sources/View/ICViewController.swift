//
//  ICViewController.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/26.
//

import UIKit

public class ICViewController<View: CellableView, Cell: ViewHostingCell<View>, Settings: ICSettings>: UIViewController {
    
    var calendarView: ICView<View,Cell,Settings>!
    var currentNumOfDays: Int = 0
    
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
        
        // set offset by currentTimeline
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.calendarView.collectionView.contentOffset = self.calendarView.layout.offset(forCurrentTimeline: self.calendarView.collectionView)
            if self.calendarView.collectionView.contentOffset.y > 0 {
                self.calendarView.collectionView.contentOffset.y += self.calendarView.layout.allDayHeaderHeight
            }
        }
    }
    
    func setDelegate(_ delegate: ICViewDelegate<View,Cell,Settings>) {
        calendarView.delegate = delegate /// base delegate
        calendarView.delegateForLongTap = delegate
    }
    
    func updateCalendar(events: [View.VM], settings: Settings, didTapToday: Bool) {
        let isUpdateNumOfDays: Bool = (currentNumOfDays != settings.numOfDays)
        
        calendarView.updateEvents(events)
        calendarView.updateSettings(settings)
        
        if didTapToday {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.calendarView.resetCollectionViewOffset(by: settings.initDate.startOfDay, animated: true)
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

