//
//  EditVigruzkaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.01.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON

class EditVigruzkaViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var textView : UITextView!
    
    let realm = try! Realm()
    
    var key = ""
    
    var thisPostId : String?
    
    var doneButtonCallback : (() -> ())?
    var toExpQueueDataManagerCallback : (() -> ())?
    
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        textView.text = ""
        
        doneButton.layer.cornerRadius = 8
        
        guard let postId = thisPostId else { return }
        
        GetForExportDataManager(delegate: self).getGetForExportData(key: key, postId: postId)
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        guard let thisPostId = thisPostId else { return }
        
        let textWithBr = textView.text.replacingOccurrences(of: "\n", with: "<br>")
        let textWithPersent = textWithBr.replacingOccurrences(of: "%", with: "<persent>")
        
        ToExpQueueDataManager(delegate: self).getToExpQueueData(key: key, postId: thisPostId, text: textWithPersent)
        
        doneButtonCallback?()
        
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - GetForExportDataManagerDelegate

extension EditVigruzkaViewController : GetForExportDataManagerDelegate{
    
    func didGetGetForExportData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let newText = data["text"].stringValue
                
                let newTextWithoutBr = newText.replacingOccurrences(of: "<br>", with: "\n")
                
                let newTextWithoutPersent = newTextWithoutBr.replacingOccurrences(of: "<persent>", with: "%")
                
                text = newTextWithoutPersent
                
                textView.text = text
                
            }else{
                
                dismiss(animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingGetForExportDataWithError(error: String) {
        print("Error with GetForExportDataManager : \(error)")
    }
    
}

//MARK: - ToExpQueueDataManagerDelegate

extension EditVigruzkaViewController : ToExpQueueDataManagerDelegate{
    
    func didGetToExpQueueData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                dismiss(animated: true, completion: nil)
                
                toExpQueueDataManagerCallback?()
                
            }else{
                
                showSimpleAlertWithOkButton(title: "Ошибка отправки запроса", message: nil, dismissButtonText: "Закрыть")
                
            }
            
        }
        
    }
    
    func didFailGettingToExpQueueDataWithError(error: String) {
        print("Error with ToExpQueueDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension EditVigruzkaViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}

