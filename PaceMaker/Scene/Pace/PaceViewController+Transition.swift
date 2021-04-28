//
//  PaceViewController+Transition.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/28.
//

import UIKit

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let present = AnimatorForPresent()
    let dismiss = AnimationForDismiss()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return present
    }
    
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

class AnimatorForPresent: NSObject, UIViewControllerAnimatedTransitioning {
    var willPresent: (()->())?
    var didPresnet: (()->())?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.15
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let presentedView = presentedViewController.view else { return }
        presentedViewController.beginAppearanceTransition(true, animated: true)
        transitionContext.containerView.addSubview(presentedView)
        presentedView.layoutIfNeeded()
        self.willPresent?()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            self.didPresnet?()
            presentedView.layoutIfNeeded()
        }, completion: { finished in
            transitionContext.completeTransition(finished)
            presentedViewController.endAppearanceTransition()
        })
    }
}

class AnimationForDismiss: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let dismissingViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let dismissingView = dismissingViewController.view else { return }
        guard let dimmedView = dismissingView.subviews.filter({ $0.tag == 100 }).first else { return }
        guard let contentView = dismissingView.subviews.filter({ $0.tag == 200 }).first else { return }
        
        dimmedView.alpha = 0
        dismissingViewController.beginAppearanceTransition(true, animated: true)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            contentView.transform = CGAffineTransform(translationX: 0, y: transitionContext.containerView.frame.height)
        }, completion: { finished in
            dismissingView.removeFromSuperview()
            transitionContext.completeTransition(finished)
            dismissingViewController.endAppearanceTransition()
        })
    }
}
