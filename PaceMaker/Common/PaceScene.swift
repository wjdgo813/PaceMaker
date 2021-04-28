//
//  PaceScene.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/23.
//

import UIKit

enum PaceScene {
    case home
    case pace(walkingTime: Int)
    case calendar
    case setting
    case result(Record)
}

extension PaceScene {
    init(scene: PaceScene) {
        self = scene
    }
    
    var viewController: UIViewController {
        switch self {
        case .home:
            let vc: HomeViewController = UIStoryboard.init(storyboard: .main).instantiateViewController()
            return vc
            
        case .pace(let walkingCount):
            let vc: PaceViewController = PaceViewController.createInstance(walkingCount)
            return vc
            
        case .result(let record):
            let record = Record(date: record.date,
                                distance: record.distance,
                                duration: record.duration,
                                walking: record.walking,
                                pace: record.pace)
            
            let vc: ResultViewController = ResultViewController.createInstance(record)
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
