//
//  ContainerViewController.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/03/09.
//

import UIKit

class ContainerViewController: UINavigationController {
    var completion: (() -> ())?
    
    static var target: ContainerViewController? {
        guard let root = UIApplication.shared.keyWindow?.rootViewController,
              let vc = root as? ContainerViewController else { return nil }
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
}

protocol TransitionFactory {
    var completion: (() -> ())? { get set }
}

extension ContainerViewController: TransitionFactory {
    public func execute(scene: PaceScene?, completion: (() -> ())? = nil) {
        
        guard let scene = scene else { return }
        self.completion = completion
        transition(withScene: scene)
    }
    
    private func transition(withScene scene: PaceScene?) {
        
        guard let scene = scene else { return }
        
        switch scene {
        case .home:
            
            let scenes = [scene]
            self.setViewControllers(scenes.map{ $0.viewController }, animated: true)
            completion?()
            return
            
        case .pace:
            
            if self.presentedViewController is CountViewController {
                self.presentedViewController?.present(scene.viewController, animated: true, completion: nil)
            }
            
            return
            
        case .result:
            if self.presentedViewController is CountViewController {
                self.presentedViewController?.dismiss(animated: true, completion: {
                    if self.presentedViewController is CountViewController {
                        self.presentedViewController?.dismiss(animated: false, completion: {
                            self.present(scene.viewController, animated: true, completion: nil)
                            self.completion?()
                        })
                    }
                    
                })
                
                return
            }
            
            self.present(scene.viewController, animated: true, completion: nil)
            completion?()
            return
            
        default:
            break
        }
        
        self.completion?()
    }
}
