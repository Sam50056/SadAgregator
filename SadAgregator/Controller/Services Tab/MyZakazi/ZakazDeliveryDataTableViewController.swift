//
//  ZakazDeliveryDataTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.01.2022.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ZakazDeliveryDataTableViewController: UITableViewController {
    
    private var key = ""
    
    private let realm = try! Realm()
    
    private var options = [JSON]()
    
    var zakazId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        update()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Данные отправки"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
        
    }
    
    //MARK: - Actions
    
    @objc func closeButtonTapped(_ sender : Any?){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Functions
    
    func update(){
        
        guard let thisZakazId = zakazId else {return}
        
        NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchases.GetDeliveryInfo?AKEY=\(key)&APurSYSID=\(thisZakazId)") { data, error in
            
            DispatchQueue.main.async { [weak self] in
                
                if let error = error{
                    print("Error with Get Delivery Info : \(error)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    self?.options = data!["options"].arrayValue
                    
                    self?.tableView.reloadData()
                    
                }else{
                    
                    if let errorText = data!["msg"].string , errorText != ""{
                        self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorText, dismissButtonText: "Ок") { [weak self] in
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let label1 = cell.viewWithTag(1) as? UILabel ,
              let label2 = cell.viewWithTag(2) as? UILabel
        else {return cell}
        
        let thisOption = options[indexPath.row]
        
        label1.text = thisOption["capt"].stringValue
        label2.text = thisOption["value"].stringValue
        
        return cell
        
    }
    
}

//MARK: - Data Manipulation Methods

extension ZakazDeliveryDataTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
