//
//  MyZakupkiClientsListViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.10.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class MyZakupkiClientsListViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var thisPur : String?
    
    private var clients = [JSON]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchText : String{
        return searchController.searchBar.text ?? ""
    }
    
    private var debetors : Bool = false {
        didSet{
            clients.removeAll()
            page = 1
            rowForPaggingUpdate = 15
            update()
        }
    }
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var clientsCliensListByPurchaseDataManager = ClientsCliensListByPurchaseDataManager()
    private var clientsSetActiveDataManager = ClientsSetActiveDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Быстрый поиск по именам"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Set up table view
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ClientTableViewCell", bundle: nil), forCellReuseIdentifier: "clientCell")
        
        clientsCliensListByPurchaseDataManager.delegate = self
        
        refresh()
        
    }
    
}

//MARK: - Functions

extension MyZakupkiClientsListViewController{
    
    @objc func refresh(){
        
        clients.removeAll()
        page = 1
        rowForPaggingUpdate = 15
        
        update()
        
    }
    
    func update(){
        
        guard let thisPur = thisPur else {return}
        
        clientsCliensListByPurchaseDataManager.getClientsCliensListByPurchaseData(key: key, pur: thisPur, query: searchText, debotors: debetors ? 1 : 0)
        
    }
    
    func goToClientVCWith(_ id : String?){
        
        let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
        
        clientVC.thisClientId = id
        
        self.navigationController?.pushViewController(clientVC, animated: true)
        
    }
    
}

//MARK: - Actions

extension MyZakupkiClientsListViewController{
    
    @objc func debetorsButtonTapped(_ sender : UIButton){
        
        debetors.toggle()
        
    }
    
}

//MARK: - TableView

extension MyZakupkiClientsListViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return clients.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        var cell = UITableViewCell()
        
        if section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel ,
                  let button = cell.viewWithTag(2) as? UIButton
            else {return cell}
            
            label.text = "Клиенты"
            
            button.setTitle( debetors ? "Показать всех" : "Показать должников", for: .normal)
            
            button.addTarget(self, action: #selector(debetorsButtonTapped(_:)), for: .touchUpInside)
            
        }else if section == 1{
            
            guard !clients.isEmpty else {return cell}
            
            let client = clients[indexPath.row]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath) as! ClientTableViewCell
            
            (cell as! ClientTableViewCell).clientBalance = client["balance"].stringValue
            (cell as! ClientTableViewCell).clientInProcess = client["in_process"].stringValue
            (cell as! ClientTableViewCell).clientName = client["name"].stringValue
            
            if client["active"].stringValue == "1"{
                (cell  as! ClientTableViewCell).bgColor = UIColor(named: "whiteblack")
                (cell  as! ClientTableViewCell).tableView.reloadData()
                (cell  as! ClientTableViewCell).tableView.backgroundColor = UIColor(named: "whiteblack")
            }else{
                (cell  as! ClientTableViewCell).bgColor = .systemGray5
                (cell  as! ClientTableViewCell).tableView.reloadData()
                (cell  as! ClientTableViewCell).tableView.backgroundColor = .systemGray5
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1{
            
            let client = clients[indexPath.row]
            
            let isActive = client["active"].stringValue == "1" ? true : false
            
            let action = UIContextualAction(style: .normal, title: (isActive ? "Не активен" : "Активен")) { [self] (action, view, completion) in
                
                clientsSetActiveDataManager.getClientsSetActiveData(key: key, clientId: client["client_id"].stringValue, state: isActive ? 0 : 1) { data , error in
                    
                    DispatchQueue.main.async { [self] in
                        
                        
                        if error != nil , data == nil {
                            print("Error with ToExpQueueDataManager : \(error!)")
                            return
                        }
                        
                        if data!["result"].intValue == 1{
                            
                            clients[indexPath.row]["active"].stringValue = isActive ? "0" : "1"
                            
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                            
                        }
                        
                    }
                    
                }
                
                completion(true)
                
            }
            
            action.backgroundColor = isActive ? .gray : .systemGreen
            
            return UISwipeActionsConfiguration(actions: [action])
            
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 1{
            
            let id = clients[indexPath.row]["client_id"].string ?? clients[indexPath.row]["id"].string
            
            goToClientVCWith(id)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                update()
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 , !clients.isEmpty{
            
            let client = clients[indexPath.row]
            
            if client["in_process"].stringValue != "" , client["in_process"].stringValue != "0"{
                return 85
            }
            
            return 85 - 20
        }
        return K.simpleHeaderCellHeight
    }
    
}

extension MyZakupkiClientsListViewController : ClientsCliensListByPurchaseDataManagerDelegate{
    
    func didGetClientsCliensListByPurchaseData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.clients.append(contentsOf: data["clients"].arrayValue)
                
                self?.tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientsCliensListByPurchaseDataWithError(error: String) {
        print("Error with ClientsCliensListByPurchaseDataManager : \(error)")
    }
    
}

//MARK: - SearchBar

extension MyZakupkiClientsListViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text , searchText != "" {
            
            refresh()
            
        }else{
            
            refresh()
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension MyZakupkiClientsListViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
