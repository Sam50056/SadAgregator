//
//  ZakupkiConfirmViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.11.2021.
//

import UIKit

class ZakupkiConfirmViewController: UIViewController {

    @IBOutlet weak var otmenaButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    var text : String?
    
    var accepted : (() -> Void)?
    var cancelled : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = text ?? ""
        
        otmenaButton.layer.cornerRadius = 8
        acceptButton.layer.cornerRadius = 8
        
    }

    @IBAction func otmenaButtonPressed(_ sender: UIButton) {
        cancelled?()
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        accepted?()
    }
    
}
