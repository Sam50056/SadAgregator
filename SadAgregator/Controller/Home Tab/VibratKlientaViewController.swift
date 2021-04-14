//
//  VibratKlientaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.04.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class VibratKlientaViewController: UITableViewController{
    
    private let realm = try! Realm()
    
    private var key = ""
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var clients = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserData()
        key = "part_2_test"
        
        PurchasesClientsSelectListDataManager(delegate : self).getPurchasesClientsSelectListData(key: key, page: page)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Выбрать клиента"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(otmenaTapped(_:)))
        
    }
    
}

//MARK: - Actions

extension VibratKlientaViewController{
    
    @IBAction func otmenaTapped(_ sender : Any){
        dismiss(animated: true, completion: nil)
    }
    
}


//MARK: - TableView

extension VibratKlientaViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let client = clients[indexPath.row]
        
        let cell = UITableViewCell()
        
        cell.textLabel?.text = client["name"].stringValue
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            PurchasesClientsSelectListDataManager(delegate : self).getPurchasesClientsSelectListData(key: key, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - PurchasesClientsSelectListDataManagerDelegate

extension VibratKlientaViewController : PurchasesClientsSelectListDataManagerDelegate{
    
    func didGetPurchasesClientsSelectListData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                clients.append(contentsOf: data["clients_select"].arrayValue)
                
                tableView.reloadData()
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesClientsSelectListDataWithError(error: String) {
        print("Error with PurchasesClientsSelectListDataManager : \(error)")
    }
    
}
