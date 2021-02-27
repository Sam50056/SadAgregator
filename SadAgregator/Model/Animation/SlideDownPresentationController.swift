//
//  SlideDownPresentationController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.02.2021.
//

import UIKit

class SlideDownPresentationController: NSObject {
    
    // MARK: - Properties
    
    let isPresentation: Bool
    
    // MARK: - Initializers
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension SlideDownPresentationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning) {
        // 1
        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
        
        guard let controller = transitionContext.viewController(forKey: key)
        else { return }
        
        // 2
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        // 3
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        
        dismissedFrame.origin.y = -presentedFrame.height
        
        // 4
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        // 5
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                controller.view.frame = finalFrame
            }, completion: { finished in
                if !self.isPresentation {
                    controller.view.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
            })
    }
    
}

