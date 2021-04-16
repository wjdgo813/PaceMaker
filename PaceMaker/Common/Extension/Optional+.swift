//
//  Optional+.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/16.
//

import Foundation

public protocol Optionable {
    
    associatedtype WrappedType
    
    var isEmpty: Bool { get }
    func unwrap() -> WrappedType
}

extension Optional : Optionable {
    
    public typealias WrappedType = Wrapped
    
    public var isSome: Bool {
        return self != nil
    }
    
    public var isNone: Bool {
        return self == nil
    }
    
    public var isEmpty: Bool {
        return self == nil
    }
    
    public func unwrap() -> WrappedType {
        return self!
    }
}
