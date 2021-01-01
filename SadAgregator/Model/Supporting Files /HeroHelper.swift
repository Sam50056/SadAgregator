//
//  HeroHelper.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.12.2020.
//


import UIKit
import Hero

extension UIViewController {
    
    // call this in viewWillDisappear(animated:) in the destination view controller when you leave the SHero enabled view controller and you want to disable SHero
    // already added in SViewController
    func disableHero() {
        navigationController?.hero.isEnabled = false
    }
    
    // call this in viewWillAppear(animated:) if you're coming from a view controller that has SHero disabled into a view controller that needs SHero enabled
    // needed if you can navigate back to this view controller with the navigationItem back button
    // already added in SViewController
    func enableHero() {
        hero.isEnabled = true
        navigationController?.hero.isEnabled = true
    }
    
    func showHero(_ viewController: UIViewController, navigationAnimationType: HeroDefaultAnimationType = .autoReverse(presenting: .slide(direction: .leading))) {
        viewController.hero.isEnabled = true
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = navigationAnimationType
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentHero(_ viewController : UIViewController , navigationAnimationType: HeroDefaultAnimationType){
        
        viewController.hero.isEnabled = true
        
        viewController.modalPresentationStyle = .fullScreen
        
        viewController.heroModalAnimationType = navigationAnimationType
        
        present(viewController, animated: true, completion: nil)
        
    }
    
}

extension UINavigationController {
    func show(_ viewController: UIViewController, navigationAnimationType: HeroDefaultAnimationType = .autoReverse(presenting: .slide(direction: .leading))) {
        viewController.hero.isEnabled = true
        hero.isEnabled = true
        hero.navigationAnimationType = navigationAnimationType
        pushViewController(viewController, animated: true)
    }
}
