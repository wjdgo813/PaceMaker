//
//  VCFactorable.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/29.
//

import UIKit


public protocol VCFactorable: class {
    static var storyboardIdentifier : String { get }
    static var vcIdentifier: String { get }
    associatedtype Dependency
    func bindData(value: Dependency)
}

extension VCFactorable {
    public static func createInstance(_ initial: Self.Dependency) -> Self {
        let bundle = Bundle.main
        let vcinitialized = UIStoryboard(name: self.storyboardIdentifier, bundle: bundle).instantiateViewController(withIdentifier: self.vcIdentifier) as! Self
        vcinitialized.bindData(value: initial)
        return vcinitialized
    }
}
