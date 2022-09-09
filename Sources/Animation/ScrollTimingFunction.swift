//
//  ScrollTimingFunction.swift
//  InfiniteCalendarView
//
//  Created by Shohe Ohtani on 2022/03/23.
//

import SwiftUI

public enum ScrollTimingFunction {
    case linear
    case quadIn
    case quadOut
    case quadInOut
    case cubicIn
    case cubicOut
    case cubicInOut
    case quartIn
    case quartOut
    case quartInOut
    case quintIn
    case quintOut
    case quintInOut
    case sineIn
    case sineOut
    case sineInOut
    case expoIn
    case expoOut
    case expoInOut
    case circleIn
    case circleOut
    case circleInOut
}

extension ScrollTimingFunction {
    /// - Parameters:
    ///   - t: time
    ///   - b: begin
    ///   - c: change
    ///   - d: duration
    func compute(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> CGFloat {
        var t = t
        switch self {
        case .linear:
            return c * t / d + b
        case .quadIn:
            t /= d
            return c * t * t + b
        case .quadOut:
            t /= d
            return -c * t * (t - 2) + b
        case .quadInOut:
            t /= d / 2
            if (t < 1) {
                return c / 2 * t * t + b
            }
            t -= 1
            return -c / 2 * (t * (t - 2) - 1) + b;
        case .cubicIn:
            t /= d
            return c * t * t * t + b
        case .cubicOut:
            t = t / d - 1
            return c * (t * t * t + 1) + b
        case .cubicInOut:
            t /= d / 2
            if (t < 1) {
                return c / 2 * t * t * t + b
            }
            t -= 2
            return c / 2 * (t * t * t + 2) + b
        case .quartIn:
            t /= d
            return c * t * t * t * t + b
        case .quartOut:
            t = t / d - 1
            return -c * (t * t * t * t - 1) + b
        case .quartInOut:
            t /= d / 2
            if (t < 1) {
                return c / 2 * t * t * t * t + b
            }
            t -= 2
            return -c / 2 * (t * t * t * t - 2) + b
        case .quintIn:
            t /= d
            return c * t * t * t * t * t + b
        case .quintOut:
            t = t / d - 1
            return c * ( t * t * t * t * t + 1) + b
        case .quintInOut:
            t /= d / 2
            if (t < 1) {
                return c / 2 * t * t * t * t * t + b
            }
            t -= 2
            return c / 2 * (t * t * t * t * t + 2) + b
        case .sineIn:
            return -c * cos(t / d * (CGFloat.pi / 2)) + c + b
        case .sineOut:
            return c * sin(t / d * (CGFloat.pi / 2)) + b
        case .sineInOut:
            return -c / 2 * (cos(CGFloat.pi * t / d) - 1) + b
        case .expoIn:
            return (t == 0) ? b : c * pow(2, 10 * (t / d - 1)) + b
        case .expoOut:
            return (t == d) ? b + c : c * (-pow(2, -10 * t / d) + 1) + b
        case .expoInOut:
            if (t == 0) {
                return b
            }
            if (t == d) {
                return b + c
            }
            t /= d / 2
            if (t < 1) {
                return c / 2 * pow(2, 10 * (t - 1)) + b
            }
            t -= 1
            return c / 2 * (-pow(2, -10 * t) + 2) + b
        case .circleIn:
            t /= d
            return -c * (sqrt(1 - t * t) - 1) + b
        case .circleOut:
            t = t / d - 1
            return c * sqrt(1 - t * t) + b
        case .circleInOut:
            t /= d / 2
            if (t < 1) {
                return -c / 2 * (sqrt(1 - t * t) - 1) + b
            }
            t -= 2
            return c / 2 * (sqrt(1 - t * t) + 1) + b
        }
    }
}
