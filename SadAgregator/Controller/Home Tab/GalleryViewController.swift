//
//  GalleryViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.12.2020.
//

import UIKit
import Hero
import SDWebImage

class GalleryViewController: UIViewController {
    
    var imageView = UIImageView()
    
    var imageURL = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = view.bounds
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        
        view.addSubview(imageView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableHero()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableHero()
        
    }
    
}
