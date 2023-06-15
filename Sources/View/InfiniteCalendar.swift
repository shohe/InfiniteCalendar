//
//  InfiniteCalendar.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI


public struct InfiniteCalendar<View: CellableView, Cell: ViewHostingCell<View>, Settings: ICSettings>: UIViewControllerRepresentable {
    @Binding var events: [View.VM]
    @ObservedObject var settings: Settings
    @Binding var targetDate: Date?
    
    // Option parameters for delegate
    private var onCurrentDateChanged: ((Date) -> Void)?
    private var onItemSelected: ((View.VM) -> Void)?
    private var onEventAdded: ((View.VM) -> Void)?
    private var onEventMoved: ((View.VM) -> Void)?
    private var onEventCanceled: ((View.VM) -> Void)?
    
    
    public init(events: Binding<[View.VM]>, settings: Settings, targetDate: Binding<Date?>) {
        self._events = events
        self.settings = settings
        self._targetDate = targetDate
    }
    
    public func makeUIViewController(context: Context) -> ICViewController<View, Cell, Settings> {
        let vc = ICViewController<View, Cell, Settings>()
        vc.setupCalendarView(events: events, settings: settings)
        vc.setDelegate(context.coordinator.delegate)
        return vc
    }

    public func updateUIViewController(_ icViewController: ICViewController<View, Cell, Settings>, context: Context) {
        icViewController.updateCalendar(events: events, settings: settings, targetDate: targetDate)
        
        // This line is important for keep currentDate state.
        DispatchQueue.main.async {
            targetDate = nil
        }
    }
    
    
    // MARK: - Coordinator
    public class Coordinator: NSObject {
        var parent: InfiniteCalendar
        var delegate: ICViewDelegate<View, Cell, Settings>
        var provider = LongTapViewDelegateProvider()
        
        init(_ parent: InfiniteCalendar) {
            self.parent = parent
            self.delegate = ICViewDelegate<View, Cell, Settings>(provider)
        }
        
        // MARK: Delegate
        /// Providing delegate method for SwiftUI
        class LongTapViewDelegateProvider: ICViewDelegateProvider {
            // Base delegate
            var onCurrentDateChanged: ((Date) -> Void)?
            var onItemSelected: ((View.VM) -> Void)?
            
            // Delegate for long tap
            var onEventAdded: ((View.VM) -> Void)?
            var onEventMoved: ((View.VM) -> Void)?
            var onEventCanceled: ((View.VM) -> Void)?
            
            
            func icView(_ icView: ICView<View, Cell, Settings>, didAdd event: View.VM, startAt startDate: Date, endAt endDate: Date) {
                self.onEventAdded?(event)
            }
            
            func icView(_ icView: ICView<View, Cell, Settings>, didMove event: View.VM, startAt startDate: Date, endAt endDate: Date) {
                self.onEventMoved?(event)
            }
            
            func icView(_ icView: ICView<View, Cell, Settings>, didCancel event: View.VM, startAt startDate: Date, endAt endDate: Date) {
                self.onEventCanceled?(event)
            }
            
            func didUpdateCurrentDate(_ date: Date) {
                self.onCurrentDateChanged?(date)
            }
            
            func didSelectItem(_ item: View.VM) {
                self.onItemSelected?(item)
            }
        }
    }
    
    public func makeCoordinator() -> InfiniteCalendar.Coordinator {
        let coordinator = InfiniteCalendar.Coordinator(self)
        coordinator.provider.onCurrentDateChanged = onCurrentDateChanged
        coordinator.provider.onItemSelected = onItemSelected
        coordinator.provider.onEventAdded = onEventAdded
        coordinator.provider.onEventMoved = onEventMoved
        coordinator.provider.onEventCanceled = onEventCanceled
        return coordinator
    }
}


// MARK: - SwiftUIInfiniteCalendar + Buildable
extension InfiniteCalendar: Buildable {
    /// Adds a callback to react when initDate changes
    ///
    /// - Parameter callback: block too be called when initDate changes. `initDate` is passed as argument
    public func onCurrentDateChanged(_ callback: ((Date) -> Void)?) -> Self {
        mutating(keyPath: \.onCurrentDateChanged, value: callback)
    }
    
    public func onItemSelected(_ callback: ((View.VM) -> Void)?) -> Self {
        mutating(keyPath: \.onItemSelected, value: callback)
    }
    
    public func onEventAdded(_ callback: ((View.VM) -> Void)?) -> Self {
        mutating(keyPath: \.onEventAdded, value: callback)
    }
    
    public func onEventMoved(_ callback: ((View.VM) -> Void)?) -> Self {
        mutating(keyPath: \.onEventMoved, value: callback)
    }
    
    public func onEventCanceled(_ callback: ((View.VM) -> Void)?) -> Self {
        mutating(keyPath: \.onEventCanceled, value: callback)
    }
}
