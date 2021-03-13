//
//  ClientsViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.03.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class ClientsViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    private var hideLabel :  UILabel?
    private var hideLabelImageView : UIImageView?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var areStatsShown = true
    
    private var pagingClientsDataManager = PagingClientsDataManager()
    private var clientsFilterDataManager = ClientsFilterDataManager()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var clients = [JSON]()
    
    private var stats = [StatItem]()
    
    private var searchText : String{
        return searchController.searchBar.text ?? ""
    }
    
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
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Set up table view
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ClientTableViewCell", bundle: nil), forCellReuseIdentifier: "clientCell")
        
        pagingClientsDataManager.delegate = self
        clientsFilterDataManager.delegate = self
        
        FormDataManager(delegate: self).getFormData(key: key)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Клиенты"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: nil) , UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: nil)]
        
    }
    
}

//MARK: - Functions

extension ClientsViewController{
    
    func makeStatsFrom(_ stat : JSON){
        
        if let clientsStat = stat["clients"].string , clientsStat != "" {
            stats.append(StatItem(firstText: "Клиенты", secondText: clientsStat))
        }
        
        if let balancesStat = stat["balances"].string , balancesStat != "" {
            stats.append(StatItem(firstText: "Баланс", secondText: balancesStat))
        }
        
        if let debetsStat = stat["debets"].string , debetsStat != "" {
            stats.append(StatItem(firstText: "Задолженность", secondText: debetsStat))
        }
        
    }
    
}

//MARK: - SearchBar

extension ClientsViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text , searchText != "" {
            
            clientsFilterDataManager.getClientsFIlterData(key: key , query: searchText)
            
        }else{
            
            clients.removeAll()
            
            page = 1
            rowForPaggingUpdate = 15
            
            pagingClientsDataManager.getPagingClientsData(key: key, page: page)
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension ClientsViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - TableView

extension ClientsViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return areStatsShown ? stats.count : 0
        case 2:
            return clients.isEmpty ? 0 : 1
        case 3:
            return clients.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let section = indexPath.section
        
        switch section{
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalStatisticsCell", for: indexPath)
            
            if let hideLabel = cell.viewWithTag(1) as? UILabel,
               let hideLabelImageView = cell.viewWithTag(2) as? UIImageView{
                
                hideLabel.text = areStatsShown ? "Скрыть" : "Показать"
                
                hideLabelImageView.image = areStatsShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
                
                self.hideLabel = hideLabel
                
                self.hideLabelImageView = hideLabelImageView
                
            }
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "statCell", for: indexPath)
            
            if let firstLabel = cell.viewWithTag(1) as? UILabel ,
               let secondLabel = cell.viewWithTag(2) as? UILabel{
                
                firstLabel.text = stats[indexPath.row].firstText
                
                secondLabel.text = stats[indexPath.row].secondText
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
        case 3:
            
            guard !clients.isEmpty else {return cell}
            
            cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath) as! ClientTableViewCell
            
            (cell  as! ClientTableViewCell).client = clients[indexPath.row]
            
        default:
            return cell
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 0{
            
            areStatsShown.toggle()
            
            tableView.reloadSections([1], with: .top)
            
            hideLabel?.text = areStatsShown ? "Скрыть" : "Показать"
            hideLabelImageView?.image = areStatsShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            
            UIView.animate(withDuration: 0.3){ [self] in
                view.layoutIfNeeded()
            }
            
        }else if section == 3{
            
            let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
            
            clientVC.thisClientId = clients[indexPath.row]["client_id"].string
            
            self.navigationController?.pushViewController(clientVC, animated: true)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                if searchText != ""{
                    
                    clientsFilterDataManager.getClientsFIlterData(key: key , query: searchText , page: page)
                    
                }else{
                    
                    pagingClientsDataManager.getPagingClientsData(key: key, page: page)
                    
                }
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3{
            return 85 - 20
        }
        return K.simpleHeaderCellHeight
    }
    
}

//MARK: - Statistics Item struct

extension ClientsViewController{
    
    private struct StatItem {
        
        let firstText : String
        let secondText : String
        
    }
    
}

//MARK: - FormDataManagerDelegate

extension ClientsViewController : FormDataManagerDelegate{
    
    func didGetFormData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let stat = data["stat"]
                
                makeStatsFrom(stat)
                
                clients = data["clients"].arrayValue
                
                tableView.reloadSections([1,2,3], with: .automatic)
                
            }else{
                print("Error with getting FormData , result : 0")
            }
            
        }
        
    }
    
    func didFailGettingFormDataWithError(error: String) {
        print("Error with FormDataManager : \(error)")
    }
    
}

//MARK: - PagingClientsDataManagerDelegate

extension ClientsViewController : PagingClientsDataManagerDelegate{
    
    func didGetPagingClientsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                clients += data["clients"].arrayValue
                
                tableView.reloadSections([3], with: .automatic)
                
            }else{
                print("Error with getting PagingClientsData , result : 0")
            }
            
        }
        
    }
    
    func didFailGettingPagingClientsDataWithErorr(error: String) {
        print("Error with PagingClientsDataManager : \(error)")
    }
    
}

//MARK: - ClientsFilterDataManager

extension ClientsViewController : ClientsFilterDataManagerDelegate{
    
    func didGetClientsFIlterData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                clients += data["clients"].arrayValue
                
                tableView.reloadSections([3], with: .automatic)
                
            }else{
                print("Error with getting ClientsFilterData , result : 0")
            }
            
        }
        
    }
    
    func didFailGettingClientsFIlterDataWithError(error: String) {
        print("Error with ClientsFilterDataManager : \(error)")
    }
        
}
