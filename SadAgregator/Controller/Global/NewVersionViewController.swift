//
//  NewVersionViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.02.2021.
//

import UIKit

class NewVersionViewController: UIViewController {
    
    @IBOutlet weak var updateView: UIView!
    @IBOutlet weak var closeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView.layer.cornerRadius = 8
        closeView.layer.cornerRadius = 8
        
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        
        if let url = URL(string: "itms-apps://apple.com/app/id1517897960") {
            UIApplication.shared.open(url)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
