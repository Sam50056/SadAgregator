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
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var key : String?
    var vendId : String?
    var myRate : Double?
    
    lazy var reviewUpdateDataManager = ReviewUpdateDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        textView.text = ""
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray.cgColor
        
        textView.layer.cornerRadius = 5
        
        saveButton.layer.cornerRadius = 5
        
        if let myRate = myRate {
            
            ratingView.rating = myRate
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let myRate = myRate else {return}
       
        self.navigationItem.title = myRate == 0 ? "ОСТАВИТЬ ОТЗЫВ" : "РЕДАКТИРОВАТЬ ОТЗЫВ"
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars < 400;
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        
        guard let key = key , let vendId = vendId else {return}
        
        if !textView.text.contains("\\"){
            
            reviewUpdateDataManager.getReviewUpdateData(key: key, vendId: vendId, rating: Int(ratingView.rating), title: titleTextField.text!, text: textView.text)
            
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    
}
