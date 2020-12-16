//
//  ReviewUpdateViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 16.12.2020.
//

import UIKit
import Cosmos
import IQKeyboardManagerSwift

class ReviewUpdateViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var RatingView: CosmosView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        textView.text = ""
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        
        textView.layer.cornerRadius = 5
        
        saveButton.layer.cornerRadius = 5
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars < 400;
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        
        
    }
    
}
