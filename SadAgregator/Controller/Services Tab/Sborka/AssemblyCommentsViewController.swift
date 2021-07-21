//
//  AssemblyCommentsViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.07.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class AssemblyCommentsViewController: UIViewController {
    
    @IBOutlet weak var orgCommentTextField: UITextView!
    @IBOutlet weak var orgCommentLabel: UILabel!
    
    @IBOutlet weak var commentForIspTextField: UITextView!
    @IBOutlet weak var commentForIspLabel: UILabel!
    
    @IBOutlet weak var commentFromIspTextField: UITextView!
    @IBOutlet weak var commentFromIspLabel: UILabel!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var thisTovarId : String?
    
    private var purchasesGetItemCommentsDataManager = PurchasesGetItemCommentsDataManager()
    private lazy var purchasesAddItemCommentDataManager = PurchasesAddItemCommentDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        purchasesGetItemCommentsDataManager.delegate = self
        
        orgCommentTextField.text.removeAll()
        commentForIspTextField.text.removeAll()
        commentFromIspTextField.text.removeAll()
        
        orgCommentTextField.delegate = self
        commentForIspTextField.delegate = self
        commentFromIspTextField.delegate = self
        
        guard let thisTovarId = thisTovarId else {
            return
        }
        
        purchasesGetItemCommentsDataManager.getPurchasesGetItemCommentsData(key: key, id: thisTovarId)
        
    }
    
}

//MARK: - UITextView

extension AssemblyCommentsViewController : UITextViewDelegate{
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let thisTovarId = thisTovarId else {return}
        
        if textView == orgCommentTextField{
            
            purchasesAddItemCommentDataManager.getPurchasesAddItemCommentData(key: key, purItemId: thisTovarId, comType: "1", comment: textView.text)
            
        }else if textView == commentForIspTextField{
            
            purchasesAddItemCommentDataManager.getPurchasesAddItemCommentData(key: key, purItemId: thisTovarId, comType: "0", comment: textView.text)
            
        }else if textView == commentFromIspTextField{
            
            purchasesAddItemCommentDataManager.getPurchasesAddItemCommentData(key: key, purItemId: thisTovarId, comType: "", comment: textView.text)
            
        }
        
    }
    
}

//MARK: - PurchasesGetItemCommentsDataManagerDelegate

extension AssemblyCommentsViewController : PurchasesGetItemCommentsDataManagerDelegate{
    
    func didGetPurchasesGetItemCommentsData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.orgCommentTextField.text = data["priv_com"].stringValue
                self?.commentForIspTextField.text = data["handle_com"].stringValue
                self?.commentFromIspTextField.text = data["by_handle_com"].stringValue
                
                self?.orgCommentTextField.isEditable = data["priv_com_ch"].intValue == 1
                self?.commentForIspTextField.isEditable = data["handle_com_ch"].intValue == 1
                self?.commentFromIspTextField.isEditable = data["by_handle_com_ch"].intValue == 1
                
            }else{
                
                self?.showSimpleAlertWithOkButton(title: "Ошибка", message: data["msg"].string)
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesGetItemCommentsDataWithError(error: String) {
        print("Error with PurchasesGetItemCommentsDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension AssemblyCommentsViewController {
    
    func loadUserData (){
        
        let userDataObjects = realm.objects(UserData.self)
        
        key = userDataObjects.first!.key
        
    }
    
}
