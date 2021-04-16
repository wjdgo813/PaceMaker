//
//  NSObject+.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import Foundation

extension NSObject {
    
    public static var className: String {
        return String(describing: self)
    }
    
    public var className: String {
        return String(describing: type(of: self).className)
    }
}

extension Double {
    func toKiloMeter() -> String {
        return String(format: "%.1f", (self / 1000))
    }
    
    func secondsToSeconds () -> String {
        return String(format: "%.2f", self)
    }
}

extension Int {
    func toMinutes() -> String {
        return "\(self/60)"
    }
    
    func toSeconds() -> String {
        let seconds: Int = self % 60
        let minutes: Int = (self / 60) % 60
        return String(format: "%2d:%02d", minutes, seconds)
     }
}

extension String {
    public func format(parameters: CVarArg...) -> String {
        return String(format: self, arguments: parameters)
    }
}
