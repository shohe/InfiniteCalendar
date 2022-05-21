//
//  WeakTimer.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/04/19.
//

import Foundation

final class WeakTimer {
    fileprivate weak var timer: Timer?
    fileprivate weak var target: AnyObject?
    fileprivate let action: (Timer) -> Void
    
    fileprivate init(timeInterval: TimeInterval, target: AnyObject, repeats: Bool, action: @escaping (Timer)->Void) {
        self.target = target
        self.action = action
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(fire(timer:)), userInfo: nil, repeats: repeats)
    }
    
    class func scheduleTimer(timeInterval: TimeInterval, target: AnyObject, repeats: Bool, action: @escaping (Timer)->Void) -> Timer {
        return WeakTimer(timeInterval: timeInterval, target: target, repeats: repeats, action: action).timer!
    }
    
    @objc fileprivate func fire(timer: Timer) {
        if target != nil {
            action(timer)
        } else {
            timer.invalidate()
        }
    }
}
