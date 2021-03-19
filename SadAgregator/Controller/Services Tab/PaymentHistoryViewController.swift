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
    
    var thisClientId : String?
    
    private var clientsPaymentsDataManager = ClientsPaymentsDataManager()
    private var paggingPaymentsByClientDataManager = PaggingPaymentsByClientDataManager()
    private var clientsPagingPaymentsDataManager = ClientsPagingPaymentsDataManager()
    
    private var payments = [JSON]()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserData()
        key = "part_2_test"
        
        clientsPaymentsDataManager.delegate = self
        paggingPaymentsByClientDataManager.delegate = self
        clientsPagingPaymentsDataManager.delegate = self
        
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
        
        if let thisClientId = thisClientId {
            paggingPaymentsByClientDataManager.getPaggingPaymentsByClientData(key: key, clientId: thisClientId)
        }else{
            clientsPaymentsDataManager.getClientsPaymentsData(key: key)
        }
        
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
            
            if data["result"].intValue == 1{
                
                payments = data["payments"].arrayValue
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientsPaymentsDataWithError(error: String) {
        print("Error with ClientsPaymentsDataManager : \(error)")
    }
    
}

//MARK: - PaggingPaymentsByClientDataManagerDelegate

extension PaymentHistoryViewController : PaggingPaymentsByClientDataManagerDelegate{
    
    func didGetPaggingPaymentsByClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                payments += data["payments"].arrayValue
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingPaggingPaymentsByClientDataWithError(error: String) {
        print("Error with PaggingPaymentsByClientDataManager : \(error)")
    }
    
}

//MARK: - ClientsPagingPaymentsDataManagerDelegate

extension PaymentHistoryViewController : ClientsPagingPaymentsDataManagerDelegate{
    
    func didGetClientsPagingPaymentsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                payments += data["payments"].arrayValue
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientsPagingPaymentsDataWithError(error: String) {
        print("Error with ClientsPagingPaymentsDataManager : \(error)")
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            if let thisClientId = thisClientId {
                paggingPaymentsByClientDataManager.getPaggingPaymentsByClientData(key: key, clientId: thisClientId,page: page)
            }else{
                clientsPagingPaymentsDataManager.getClientsPagingPaymentsData(key: key, page: page)
            }
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}