//
//  PaymentHistoryViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class PaymentHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let realm = try! Realm()
    
    private var key = ""
    
    private var clientsPaymentsDataManager = ClientsPaymentsDataManager()
    
    private var payments = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserData()
        key = "part_2_test"
        
        clientsPaymentsDataManager.delegate = self
        
        navigationItem.title = "История платежей"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Быстрый поиск по комментариям"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        clientsPaymentsDataManager.getClientsPaymentsData(key: key)
        
    }
    
}


//MARK: - SearchBar

extension PaymentHistoryViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        
        
    }
    
}

//MARK: - Data Manipulation Methods

extension PaymentHistoryViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - ClientsPaymentsDataManagerDelegate

extension PaymentHistoryViewController : ClientsPaymentsDataManagerDelegate{
    
    func didGetClientsPaymentsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            payments = data["payments"].arrayValue
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingClientsPaymentsDataWithError(error: String) {
        print("Error with ClientsPaymentsDataManager : \(error)")
    }
    
}

//MARK: - TableView

extension PaymentHistoryViewController : UITableViewDataSource , UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        
        cell.payment = payments[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
}
