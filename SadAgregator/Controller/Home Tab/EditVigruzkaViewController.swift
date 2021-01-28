//
//  EditVigruzkaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.01.2021.
//

import UIKit

class EditVigruzkaViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.layer.cornerRadius = 8
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
    }
    
}
