//
//  Extensions.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI

public extension Date {
    func add(component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self)!
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return self.set(hour: 23, minute: 59, second: 59)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    static func daysBetween(start: Date, end: Date, ignoreHours: Bool) -> Int {
        let startDate = ignoreHours ? start.startOfDay : start
        let endDate = ignoreHours ? end.startOfDay : end
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
    }
    
    /// return difference time of second
    static func timeBetween(start: Date, end: Date, ignoreDate: Bool) -> Int {
        if ignoreDate {
            let d = (start.hour*3600) + (start.minute*60) + start.second
            let c = (end.hour*3600) + (end.minute*60) + end.second
            return c - d
        }
        return Calendar.current.dateComponents([.second], from: start, to: end).second!
    }
    
    
    
    static let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .weekday]
    private var dateComponents: DateComponents {
        return  Calendar.current.dateComponents(Date.components, from: self)
    }
    var year: Int { return dateComponents.year! }
    var month: Int { return dateComponents.month! }
    var day: Int { return dateComponents.day! }
    var hour: Int { return dateComponents.hour! }
    var minute: Int { return dateComponents.minute! }
    var second: Int { return dateComponents.second! }
    var weekday: Int { return dateComponents.weekday! }
    
    func getDayOfWeek() -> WeekDay {
        let weekDayNum = Calendar.current.component(.weekday, from: self)
        let weekDay = WeekDay(rawValue: weekDayNum)!
        return weekDay
    }
    
    func set(year: Int?=nil, month: Int?=nil, day: Int?=nil, hour: Int?=nil, minute: Int?=nil, second: Int?=nil, tz: String?=nil) -> Date {
        let timeZone = Calendar.current.timeZone
        let year = year ?? self.year
        let month = month ?? self.month
        let day = day ?? self.day
        let hour = hour ?? self.hour
        let minute = minute ?? self.minute
        let second = second ?? self.second
        let dateComponents = DateComponents(timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        let date = Calendar.current.date(from: dateComponents)
        return date!
    }
}

public extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

public extension View {
    static var structName: String {
        return String(describing: type(of: self))
    }
}

public extension UICollectionView {
    func setContentOffsetWithoutDelegate(_ contentOffset: CGPoint, animated: Bool) {
        let tempDelegate = self.delegate
        self.delegate = nil
        self.setContentOffset(contentOffset, animated: animated)
        self.delegate = tempDelegate
    }
}

public extension CGFloat {
    func toDecimal1Value() -> CGFloat {
        return (self * 10).rounded() / 10
    }
}

public extension CGPoint {
    /**
    * Returns the length (magnitude) of the vector described by the CGPoint.
    */
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
}

public extension UIScrollView {
    
    private struct AssociatedKeys {
        static var animator: String = "animator"
    }
    
    private var animator: ScrollViewAnimator? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.animator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.animator) as? ScrollViewAnimator
        }
    }
    
    func setContentOffset(_ contentOffset: CGPoint, duration: TimeInterval, timingFunction: ScrollTimingFunction = .linear, completion: (() -> Void)? = nil) {
        if animator == nil {
            animator = ScrollViewAnimator(scrollView: self, timingFunction: timingFunction)
        }
        animator!.closure = { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.animator = nil
            }
            completion?()
        }
        animator!.setContentOffset(contentOffset, duration: duration)
    }
    
    func setContentOffset(_ contentOffset: CGPoint, velocity: CGPoint, timingFunction: ScrollTimingFunction = .linear, completion: (() -> Void)? = nil) {
        if animator == nil {
            animator = ScrollViewAnimator(scrollView: self, timingFunction: timingFunction)
        }
        animator!.closure = { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.animator = nil
            }
            completion?()
        }
        animator!.setContentOffset(contentOffset, velocity: velocity)
    }
    
}

// Anchor Constraints from JZiOSFramework
public extension UIView {

    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, centerXAnchor: NSLayoutXAxisAnchor?=nil, centerYAnchor: NSLayoutYAxisAnchor?=nil) {

        self.translatesAutoresizingMaskIntoConstraints = false

        if let width = widthAnchor {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = heightAnchor {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        if let centerX = centerXAnchor {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }

        if let centerY = centerYAnchor {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }

    // bottomAnchor & trailingAnchor should be negative
    func setAnchorConstraintsEqualTo(widthAnchor: CGFloat? = nil, heightAnchor: CGFloat? = nil,
                                     topAnchor: (NSLayoutYAxisAnchor, CGFloat)? = nil, bottomAnchor: (NSLayoutYAxisAnchor, CGFloat)? = nil,
                                     leadingAnchor: (NSLayoutXAxisAnchor, CGFloat)? = nil, trailingAnchor: (NSLayoutXAxisAnchor, CGFloat)? = nil) {

        self.translatesAutoresizingMaskIntoConstraints = false

        if let width = widthAnchor {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = heightAnchor {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        if let topY = topAnchor {
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }

        if let botY = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: botY.0, constant: botY.1).isActive = true
        }

        if let leadingX = leadingAnchor {
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }

        if let trailingX = trailingAnchor {
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }

    func setAnchorCenterVerticallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, leadingAnchor: (NSLayoutXAxisAnchor, CGFloat)?=nil, trailingAnchor: (NSLayoutXAxisAnchor, CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false

        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerYAnchor: view.centerYAnchor)

        if let leadingX = leadingAnchor {
            self.leadingAnchor.constraint(equalTo: leadingX.0, constant: leadingX.1).isActive = true
        }

        if let trailingX = trailingAnchor {
            self.trailingAnchor.constraint(equalTo: trailingX.0, constant: trailingX.1).isActive = true
        }
    }

    func setAnchorCenterHorizontallyTo(view: UIView, widthAnchor: CGFloat?=nil, heightAnchor: CGFloat?=nil, topAnchor: (NSLayoutYAxisAnchor, CGFloat)?=nil, bottomAnchor: (NSLayoutYAxisAnchor, CGFloat)?=nil) {
        self.translatesAutoresizingMaskIntoConstraints = false

        setAnchorConstraintsEqualTo(widthAnchor: widthAnchor, heightAnchor: heightAnchor, centerXAnchor: view.centerXAnchor)

        if let topY = topAnchor {
            self.topAnchor.constraint(equalTo: topY.0, constant: topY.1).isActive = true
        }

        if let botY = bottomAnchor {
            self.bottomAnchor.constraint(equalTo: botY.0, constant: botY.1).isActive = true
        }
    }

    func setAnchorConstraintsFullSizeTo(view: UIView, padding: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
    }

    func addSubviews(_ views: [UIView]) {
        views.forEach({ self.addSubview($0)})
    }
}
