//
//  ScrollViewAnimator.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI

class ScrollViewAnimator {
    
    weak var scrollView: UIScrollView?
    let timingFunction: ScrollTimingFunction
    
    var closure: (() -> Void)?
    
    var startTime: TimeInterval = 0
    var startOffset: CGPoint = .zero
    var destinationOffset: CGPoint = .zero
    var duration: TimeInterval = 0
    var runTime: TimeInterval = 0
    
    var timer: CADisplayLink?
    
    init(scrollView: UIScrollView, timingFunction: ScrollTimingFunction) {
        self.scrollView = scrollView
        self.timingFunction = timingFunction
    }
    
    func setContentOffset(_ contentOffset: CGPoint, duration: TimeInterval) {
        guard let scrollView = scrollView else {
            return
        }
        startTime = Date().timeIntervalSince1970
        startOffset = scrollView.contentOffset
        destinationOffset = contentOffset
        self.duration = duration
        runTime = 0
        guard self.duration > 0 else {
            scrollView.setContentOffset(contentOffset, animated: false)
            return
        }
        if timer == nil {
            timer = CADisplayLink(target: self, selector: #selector(animtedScroll))
            timer?.add(to: .main, forMode: .common)
        }
    }
    
    func setContentOffset(_ contentOffset: CGPoint, velocity: CGPoint) {
        guard let scrollView = scrollView else {
            return
        }
        startTime = Date().timeIntervalSince1970
        startOffset = scrollView.contentOffset
        destinationOffset = contentOffset
        self.duration = getAdequatelyDuration(velocity)
        runTime = 0
        guard self.duration > 0 else {
            scrollView.setContentOffset(contentOffset, animated: false)
            return
        }
        if timer == nil {
            timer = CADisplayLink(target: self, selector: #selector(animtedScroll))
            timer?.add(to: .main, forMode: .common)
        }
    }
    
    private func getAdequatelyDuration(_ velocity: CGPoint) -> TimeInterval {
        guard velocity.length() > 0 else { return 0 }
        let decelerationRate: UIScrollView.DecelerationRate = scrollView?.decelerationRate ?? .normal
        let threshold = (decelerationRate == .normal) ? 0.5 : 0.05 / UIScreen.main.scale
        let dCoeff = 1000 * log(decelerationRate.rawValue)
        return TimeInterval(log(-dCoeff * threshold / velocity.length()) / dCoeff)
    }
    
    @objc
    func animtedScroll() {
        guard let timer = timer else { return }
        guard let scrollView = scrollView else { return }
        runTime += timer.duration
        if runTime >= duration {
            scrollView.setContentOffset(destinationOffset, animated: false)
            timer.invalidate()
            self.timer = nil
            closure?()
            return
        }
        
        var offset = scrollView.contentOffset
        offset.x = timingFunction.compute(CGFloat(runTime), startOffset.x, destinationOffset.x - startOffset.x, CGFloat(duration))
        offset.y = timingFunction.compute(CGFloat(runTime), startOffset.y, destinationOffset.y - startOffset.y, CGFloat(duration))
        scrollView.setContentOffset(offset, animated: false)
    }
    
}
