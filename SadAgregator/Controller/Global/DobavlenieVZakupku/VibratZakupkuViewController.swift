//
//  VibratVikupViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.04.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class VibratZakupkuViewController: UITableViewController {
    
    private let realm = try! Realm()
    
    private var key = ""
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var purs = [JSON]()
    
    var purSelected : ((String, String) -> ())?
    
    let activityController = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        //        key = "part_2_test"
        
        showSimpleCircleAnimation(activityController: activityController)
        PurchasesPursListDataManager(delegate: self).getPurchasesPursListData(key: key, page: page)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Выбрать закупку"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(otmenaTapped(_:)))
        
    }
    
}

//MARK: - Actions

extension VibratZakupkuViewController{
    
    @IBAction func otmenaTapped(_ sender : Any){
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - TableView

extension VibratZakupkuViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "purCell", for: indexPath)
        
        let pur = purs[indexPath.row]
        
        guard let label1 = cell.viewWithTag(1) as? UILabel,
              let label2 = cell.viewWithTag(2) as? UILabel
        else {return cell}
        
        label1.text = pur["pur_name"].stringValue
        label2.text = pur["pur_date"].stringValue
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pur = purs[indexPath.row]
        
        purSelected?(pur["pur_sys_id"].stringValue, pur["pur_name"].stringValue)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            PurchasesPursListDataManager(delegate: self).getPurchasesPursListData(key: key, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - PurchasesPursListDataManager

extension VibratZakupkuViewController : PurchasesPursListDataManagerDelegate{
    
    func didGetPurchasesPursListData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.stopSimpleCircleAnimation(activityController: self!.activityController)
            
            if data["result"].intValue == 1{
                
                self?.purs.append(contentsOf: data["purs"].arrayValue)
                
                self?.tableView.reloadData()
                
            }else{
                
                if let errorMessage = data["msg"].string , errorMessage != ""{
                    self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorMessage, dismissAction: {
                        self?.dismiss(animated: true, completion: nil)
                    })
                }
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesPursListDataWithError(error: String) {
        print("Error with PurchasesPursListDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension VibratZakupkuViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}
