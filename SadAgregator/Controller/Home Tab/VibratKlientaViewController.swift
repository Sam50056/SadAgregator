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
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var purchasesClientsSelectListDataManager = PurchasesClientsSelectListDataManager()
    
    private var clients = [DobavlenieVZakupkuViewController.KlientiCellKlientItem]()
    var selectedClientsIds = [String]()
    
    var clientSelected : ((String , String) -> ())?
    
    var isForReplace : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserData()
        key = "part_2_test"
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Быстрый поиск по именам"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        purchasesClientsSelectListDataManager.delegate = self
        
        purchasesClientsSelectListDataManager.getPurchasesClientsSelectListData(key: key, page: page, forReplace: isForReplace, isInZakupka: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Выбрать клиента"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(otmenaTapped(_:)))
        
        if !isForReplace{
            navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusBarButtonPressed(_:)))]
        }
        
    }
    
}

//MARK: - Actions

extension VibratKlientaViewController{
    
    @IBAction func otmenaTapped(_ sender : Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plusBarButtonPressed(_ sender : UIBarButtonItem){
        
        let createClientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateClientVC") as! CreateClientViewController
        
        createClientVC.delegate = self
        
        navigationController?.pushViewController(createClientVC, animated: true)
        
    }
    
}

//MARK: - Functions

extension VibratKlientaViewController {
    
    
    
}

//MARK: - SearchBar

extension VibratKlientaViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text , searchText != "" {
            
            clients.removeAll()
            
            page = 1
            rowForPaggingUpdate = 15
            
            purchasesClientsSelectListDataManager.getPurchasesClientsSelectListData(key: key, page: page, query: searchText, forReplace: isForReplace, isInZakupka: true)
            
        }else{
            
            clients.removeAll()
            
            page = 1
            rowForPaggingUpdate = 15
            
            purchasesClientsSelectListDataManager.getPurchasesClientsSelectListData(key: key, page: page, forReplace: isForReplace, isInZakupka: true)
            
        }
        
    }
    
}


//MARK: - TableView

extension VibratKlientaViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        guard !clients.isEmpty else {return cell}
        
        let client = clients[indexPath.row]
        
        cell.textLabel?.text = client.name
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let client = clients[indexPath.row]
        
        clientSelected?(client.name, client.id)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            purchasesClientsSelectListDataManager.getPurchasesClientsSelectListData(key: key, page: page, query: searchController.searchBar.text ?? "", forReplace: isForReplace, isInZakupka: true)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - PurchasesClientsSelectListDataManagerDelegate

extension VibratKlientaViewController : PurchasesClientsSelectListDataManagerDelegate{
    
    func didGetPurchasesClientsSelectListData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let jsonArray = data["clients_select"].arrayValue
                
                let structArray = jsonArray.map { jsonClient in
                    
                    return DobavlenieVZakupkuViewController.KlientiCellKlientItem(name: jsonClient["name"].stringValue, id: jsonClient["id"].stringValue, count: 1)
                    
                }
                
                if !selectedClientsIds.isEmpty{
                    
                    var lastArray = [DobavlenieVZakupkuViewController.KlientiCellKlientItem]()
                    
                    for client in structArray{
                        
                        var hasIt = false
                        
                        for selectedClientId in selectedClientsIds{
                            
                            if client.id == selectedClientId{
                                
                                hasIt = true
                                
                            }
                            
                        }
                        
                        if !hasIt{
                            lastArray.append(client)
                        }
                        
                    }
                    
                    clients.append(contentsOf: lastArray)
                    
                    tableView.reloadData()
                    
                }else{
                    
                    clients.append(contentsOf: structArray)
                    
                    tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesClientsSelectListDataWithError(error: String) {
        print("Error with PurchasesClientsSelectListDataManager : \(error)")
    }
    
}

//MARK: - CreateClientViewControllerDelegate

extension VibratKlientaViewController : CreateClientViewControllerDelegate{
    
    func didCloseVC(didCreateUser: Bool, clientId: String?, clientName : String?) {
        
        if didCreateUser{
            
            guard let clientName = clientName , let clientId = clientId else {return}
            
            clientSelected?(clientName, clientId)
            
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension VibratKlientaViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}
