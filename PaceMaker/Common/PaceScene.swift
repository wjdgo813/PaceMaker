//
//  PaceScene.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit

enum PaceScene {
    case home
    case pace
    case calendar
    case setting
    case result
}

extension PaceScene {
    init(scene: PaceScene) {
        self = scene
    }
    
    var viewController: UIViewController {
        switch self {
        case .home:
            let vc: ViewController = UIStoryboard.init(storyboard: .main).instantiateViewController()
            return vc
            
        case .pace:
            let vc: PaceViewController = UIStoryboard.init(storyboard: .main).instantiateViewController()
            return vc
            
        default:
            return UIViewController()
        }
    }
}

extension PaceScene : Equatable {
    static func ==(lhs: PaceScene, rhs: PaceScene) -> Bool {
        return (lhs.viewController.className == rhs.viewController.className)
    }
}
