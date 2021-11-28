//
//  AlertWithTextFieldViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.11.2021.
//

import UIKit

class AlertWithTextFieldViewController: UIViewController {
    
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var cancelButton : UIButton!
    @IBOutlet weak var doneButton : UIButton!
    
    var labelText : String? = nil
    var doneButtonTitle = "Готово"
    
    var cancelTapped : (() -> Void)?
    var doneTapped : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = labelText
        
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        bgView.layer.cornerRadius = 8
        
        cancelButton.layer.cornerRadius = 8
        doneButton.layer.cornerRadius = 8
        
        doneButton.backgroundColor = .systemBlue
        
        doneButton.setTitle(doneButtonTitle, for: .normal)
        
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        
        textView.text = ""
        
        textView.layer.cornerRadius = 8
        
        Timer.scheduledTimer(withTimeInterval: 0.5 , repeats: false) { _ in
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.view.backgroundColor = .black.withAlphaComponent(0.1)
            }
            
        }
        
    }
    
    @IBAction func cancelButtonTapped(){
        
        UIView.animate(withDuration: 0) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(0)
        }
        self.dismiss(animated: true, completion: nil)
        cancelTapped?()
        
    }
    
    @IBAction func doneButtonTapped(){
        
        UIView.animate(withDuration: 0) { [weak self] in
            self?.view.backgroundColor = .black.withAlphaComponent(0)
        }
        self.dismiss(animated: true, completion: nil)
        
        guard let text = textView.text else {return}
        
        doneTapped?(text)
        
    }
    
}
