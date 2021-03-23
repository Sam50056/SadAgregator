//
//  CreateClientViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.03.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON

class CreateClientViewController: UIViewController {
    
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var phoneTextField : UITextField!
    @IBOutlet weak var vkTextField : UITextField!
    @IBOutlet weak var okTextField : UITextField!
    @IBOutlet weak var balanceTextField : UITextField!
    
    @IBOutlet weak var doneButton : UIButton!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key = "part_2_test"
        
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        
    }
    
    //MARK: - Actions
    
    @IBAction func doneButtonTapped(_ sender : UIButton){
        
        if let nameValue = nameTextField.text, nameValue != ""{
            
            let vkTextFieldText = vkTextField.text ?? ""
            let okTextFieldText = okTextField.text ?? ""
            
            var vkValue = ""
            var okValue = ""
            
            if let _ = URL(string: vkTextFieldText) , vkTextFieldText.contains("vk.com"){
                vkValue = vkTextFieldText
            }
            
            if let _ = URL(string: okTextFieldText) , okTextFieldText.contains("ok.ru"){
                okValue = okTextFieldText
            }
            
            CreateNewClientDataManager(delegate: self).getCreateNewClientData(key: key, name: nameValue, phone: phoneTextField.text ?? "", vk: vkValue, ok: okValue)
            
        }else{
            
            showSimpleAlertWithOkButton(title: "Ошибка", message: "Необходимо ввести имя")
            
        }
        
    }
    
}

//MARK: - CreateNewClientDataManagerDelegate

extension CreateClientViewController : CreateNewClientDataManagerDelegate{
    
    func didGetCreateNewClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let clientId = data["client_id"].stringValue
                
                if let balanceValue = balanceTextField.text , balanceValue.replacingOccurrences(of: " ", with: "") != "" , let balanceIntValue = Int(balanceValue){
                    
                    ClientsChangeBalanceDataManager(delegate: self).getClientsChangeBalanceData(key: key, clientId: clientId, summ: balanceIntValue, comment: "")
                    
                }else{
                    
                    navigationController?.popViewController(animated: true)
                    
                }
                
            }else{
                
                
                
            }
            
        }
        
    }
    
    func didFailGettingCreateNewClientDataWithError(error: String) {
        print("Error with CreateNewClientDataManager : \(error)")
    }
    
}

//MARK: - ClientsChangeBalanceDataManagerDelegate

extension CreateClientViewController : ClientsChangeBalanceDataManagerDelegate{
    
    func didGetClientsChangeBalanceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                navigationController?.popViewController(animated: true)
                
            }
            
        }
        
    }
    
    func didFailGettingClientsChangeBalanceDataWithError(error: String) {
        print("Error with ClientsChangeBalanceDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension CreateClientViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}
