//
//  AboveViewControllerPresentationController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.02.2021.
//


import UIKit

class AboveViewControllerPresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    var height : CGFloat?
    
    var navBarHeightY : CGFloat?
    var navBarHeight : CGFloat?
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(x: 0, y: navBarHeightY ?? 0),
               size: CGSize(width: self.containerView!.frame.width, height: ((height ?? 430) - (navBarHeight ?? 0))))
    }
    
    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0.5
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.bottomLeft, .bottomRight], radius: 22)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        let containerViewRect = containerView!.bounds
        blurEffectView.frame = CGRect(x: containerViewRect.minX, y: navBarHeightY ?? 0, width: containerViewRect.width, height: containerViewRect.height)
    }
    
    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
