//
//  ContainerViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/09.
//

import UIKit

class ContainerViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setTabBar()
    }
    
    private func setTabBar() {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: view.frame.width, height: tabBar.frame.height), cornerRadius: 15)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        tabBar.layer.mask = mask
        
        var frame = tabBar.frame
        frame.origin.y += 200
        tabBar.frame = frame
    }
}
