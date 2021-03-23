//
//  StoryBoard+.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit

extension UIStoryboard {
    enum Storyboard: String {
        case main   = "Main"
        case result = "Result"
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T {
        guard let vc = instantiateViewController(withIdentifier: T.className) as? T else {
            fatalError("Could not locate viewcontroller with with identifier \(T.className) in storyboard.")
        }
        return vc
    }
    
    func instantiateNavigationController(name: String) -> UINavigationController {
        guard let nc = instantiateViewController(withIdentifier: name) as? UINavigationController else {
            fatalError("Could not locate viewcontroller with with identifier \(name) in storyboard.")
        }
        return nc
    }
    
    func instantiateNavigationController(withTitle title: String, name: String) -> UINavigationController {
        guard let nc = instantiateViewController(withIdentifier: name) as? UINavigationController else {
            fatalError("Could not locate viewcontroller with with identifier \(name) in storyboard.")
        }
        
        nc.title = title
        return nc
    }
}
