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
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var areRequests = false
    
    private var areRequestsShown = false
    private var areStatsShown = true
    
    private var pagingClientsDataManager = PagingClientsDataManager()
    private var clientsFilterDataManager = ClientsFilterDataManager()
    private lazy var clientsPayRequestsDataManager = ClientsPayRequestsDataManager()
    
    private var clientsSetActiveDataManager = ClientsSetActiveDataManager()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var balanceRequestsPage = 1
    private var balanceRequestsRowForpaggingUpdate = 15
    
    private var clientsData : JSON?
    
    private var clients = [JSON]()
    
    private var balanceRequests = [JSON]()
    
    private var stats = [StatItem]()
    
    private var searchText : String{
        return searchController.searchBar.text ?? ""
    }
    
    private var debetors : Bool = false {
        didSet{
            clients.removeAll()
            page = 1
            rowForPaggingUpdate = 15
            clientsFilterDataManager.getClientsFIlterData(key: key , query: searchText , debotors: debetors ? 1 : 0 , page : page)
        }
    }
    
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
        tableView.register(UINib(nibName: "BalanceRequestTableViewCell", bundle: nil), forCellReuseIdentifier: "balanceRequestCell")
        
        pagingClientsDataManager.delegate = self
        clientsFilterDataManager.delegate = self
        clientsPayRequestsDataManager.delegate = self
        
//        key = "part_3_test"
        
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Клиенты"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusBarButtonPressed(_:)))]
        
    }
    
}

//MARK: - Actions

extension ClientsViewController {
    
    @IBAction func plusBarButtonPressed(_ sender : UIBarButtonItem){
        
        let createClientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateClientVC") as! CreateClientViewController
        
        createClientVC.delegate = self
        
        navigationController?.pushViewController(createClientVC, animated: true)
        
    }
    
}

//MARK: - Functions

extension ClientsViewController{
    
    func makeStatsFrom(_ stat : JSON){
        
        var newStats = [StatItem]()
        
        if let clientsStat = stat["clients"].string , clientsStat != "" {
            newStats.append(StatItem(firstText: "Клиенты", secondText: clientsStat))
        }
        
        if let balancesStat = stat["balances"].string , balancesStat != "" {
            newStats.append(StatItem(firstText: "Баланс", secondText: balancesStat + " руб" , shouldBeBlue: true))
        }
        
        if let debetsStat = stat["debets"].string , debetsStat != "" , debetsStat != "0" {
            newStats.append(StatItem(firstText: "Задолженность", secondText: debetsStat + " руб" , shouldBeBlue: true))
        }
        
        stats = newStats
        
    }
    
    func goToClientVCWith(_ id : String?){
        
        let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
        
        clientVC.thisClientId = id
        
        self.navigationController?.pushViewController(clientVC, animated: true)
        
    }
    
    @objc func refresh(){
        FormDataManager(delegate: self).getFormData(key: key)
    }
    
}

//MARK: - SearchBar

extension ClientsViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text , searchText != "" {
            
            clients.removeAll()
            
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
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return (areRequests && balanceRequests.count != 0) ? 1 : 0
        case 1:
            
            if areRequests , areRequestsShown{
                return balanceRequests.count
            }else if areRequests , !areRequestsShown{
                return 0
            }else{
                return 0
            }
            
        case 2:
            return stats.isEmpty ? 0 : 1
        case 3:
            return areStatsShown ? stats.count : 0
        case 4:
            return clients.isEmpty ? 0 : 1
        case 5:
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
               let hideLabelImageView = cell.viewWithTag(2) as? UIImageView,
               let firstLabel = cell.viewWithTag(3) as? UILabel{
                
                firstLabel.text = "Пополнение баланса"
                
                hideLabel.text = areRequestsShown ? "Скрыть" : "Показать"
                
                hideLabelImageView.image = areRequestsShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
                
            }
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "balanceRequestCell", for: indexPath)
            
            let request = balanceRequests[indexPath.row]
            
            (cell as! BalanceRequestTableViewCell).firstLabel.text = request["dt"].stringValue
            
            (cell as! BalanceRequestTableViewCell).clientName = request["client_name"].stringValue
            (cell as! BalanceRequestTableViewCell).summ = request["summ"].string
            
            (cell as! BalanceRequestTableViewCell).rightView.isHidden = request["img"].stringValue == ""
            (cell as! BalanceRequestTableViewCell).rightViewImageView.image = UIImage(systemName: "newspaper")
            
            (cell as! BalanceRequestTableViewCell).rightButtonCallback = { [weak self] in
                
                ClientsSetPayRequestStatusDataManager().getClientsSetPayRequestStatusData(key: self!.key, status: "0", id: request["id"].stringValue) { data, error in
                    
                    if let error = error , data == nil{
                        print("Error with ClientsSetPayRequestStatusDataManager : \(error)")
                        return
                    }
                    
                    if data!["result"].intValue == 1{
                        DispatchQueue.main.async {
                            self?.balanceRequests.remove(at: indexPath.row)
                            if self!.balanceRequests.isEmpty{
                                self?.tableView.reloadSections([0,1], with: .automatic)
                            }else{
                                self?.tableView.reloadSections([1], with: .automatic)
                            }
                            self?.refresh()
                        }
                    }
                    
                }
                
            }
            
            (cell as! BalanceRequestTableViewCell).leftButtonCallbak = { [weak self] in
                
                ClientsSetPayRequestStatusDataManager().getClientsSetPayRequestStatusData(key: self!.key, status: "1", id: request["id"].stringValue) { data, error in
                    
                    if let error = error , data == nil{
                        print("Error with ClientsSetPayRequestStatusDataManager : \(error)")
                        return
                    }
                    
                    if data!["result"].intValue == 1{
                        DispatchQueue.main.async {
                            self?.balanceRequests.remove(at: indexPath.row)
                            if self!.balanceRequests.isEmpty{
                                self?.tableView.reloadSections([0,1], with: .automatic)
                            }else{
                                self?.tableView.reloadSections([1], with: .automatic)
                            }
                            self?.refresh()
                        }
                    }
                    
                }
                
            }
            
            (cell as! BalanceRequestTableViewCell).rightViewButtonCallback = { [weak self] in
                
                guard let img = request["img"].string , !img.isEmpty else {return}
                
                self?.previewImage(img)
                
            }
            
            (cell as! BalanceRequestTableViewCell).clientNameTapped = {[weak self] in
                self?.goToClientVCWith(request["client_id"].stringValue)
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalStatisticsCell", for: indexPath)
            
            if let hideLabel = cell.viewWithTag(1) as? UILabel,
               let hideLabelImageView = cell.viewWithTag(2) as? UIImageView,
               let firstLabel = cell.viewWithTag(3) as? UILabel{
                
                firstLabel.text = "Общая статистика"
                
                hideLabel.text = areStatsShown ? "Скрыть" : "Показать"
                
                hideLabelImageView.image = areStatsShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
                
            }
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "statCell", for: indexPath)
            
            if let firstLabel = cell.viewWithTag(1) as? UILabel ,
               let secondLabel = cell.viewWithTag(2) as? UILabel{
                
                let stat = stats[indexPath.row]
                
                firstLabel.text = stat.firstText
                
                secondLabel.text = stat.secondText
                
                secondLabel.textColor = stat.shouldBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                
            }
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
        case 5:
            
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
            
        default:
            return cell
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 5{
            
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
        
        if section == 0{
            
            areRequestsShown.toggle()
            
            tableView.reloadSections([1], with: .automatic)
            
            (tableView.cellForRow(at: indexPath)?.viewWithTag(1) as? UILabel)?.text = areRequestsShown ? "Скрыть" : "Показать"
            (tableView.cellForRow(at: indexPath)?.viewWithTag(2) as? UIImageView)?.image = areRequestsShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            
            UIView.animate(withDuration: 0.3){ [self] in
                view.layoutIfNeeded()
            }
            
        }else if section == 2{
            
            areStatsShown.toggle()
            
            tableView.reloadSections([3], with: .top)
            
            (tableView.cellForRow(at: indexPath)?.viewWithTag(1) as? UILabel)?.text = areStatsShown ? "Скрыть" : "Показать"
            (tableView.cellForRow(at: indexPath)?.viewWithTag(2) as? UIImageView)?.image = areStatsShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            
            UIView.animate(withDuration: 0.3){ [self] in
                view.layoutIfNeeded()
            }
            
        }else if section == 3{
            
            if stats[indexPath.row].firstText == "Баланс"{
                
                let paymentsHistoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentHistoryVC") as! PaymentHistoryViewController
                
                navigationController?.pushViewController(paymentsHistoryVC, animated: true)
                
            }else if stats[indexPath.row].firstText == "Задолженность" {
                
                debetors.toggle()
                
            }
            
        }else if section == 5{
            
            let id = clients[indexPath.row]["client_id"].string ?? clients[indexPath.row]["id"].string
            
            goToClientVCWith(id)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 5{
            
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
            
        }else if indexPath.section == 1{
            
            if indexPath.row == balanceRequestsRowForpaggingUpdate{
                
                balanceRequestsPage += 1
                
                balanceRequestsRowForpaggingUpdate += 16
                
                clientsPayRequestsDataManager.getClientsPayRequestsData(key: key, page: balanceRequestsPage)
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 5{
            
            let client = clients[indexPath.row]
            
            if client["in_process"].stringValue != "" , client["in_process"].stringValue != "0"{
                return 85
            }
            
            return 85 - 20
        }else if indexPath.section == 1{
            return 135
        }
        return K.simpleHeaderCellHeight
    }
    
}

//MARK: - Statistics Item struct

extension ClientsViewController{
    
    private struct StatItem {
        
        let firstText : String
        let secondText : String
        
        var shouldBeBlue : Bool = false
        
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
                
                tableView.reloadData()
                
                if data["pay_reqs"]["cnt"].stringValue != "" , data["pay_reqs"]["cnt"].stringValue != "0" , clientsData == nil{
                    clientsPayRequestsDataManager.getClientsPayRequestsData(key: key, page: balanceRequestsPage)
                }
                
                clientsData = data
                
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
                
                clients.append(contentsOf: data["clients"].arrayValue)
                
                tableView.reloadData()
                
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
                
                clients.append(contentsOf: data["clients"].arrayValue)
                
                tableView.reloadData()
                
            }else{
                print("Error with getting ClientsFilterData , result : 0")
            }
            
        }
        
    }
    
    func didFailGettingClientsFIlterDataWithError(error: String) {
        print("Error with ClientsFilterDataManager : \(error)")
    }
    
}

//MARK: - CreateClientViewControllerDelegate

extension ClientsViewController : CreateClientViewControllerDelegate{
    
    func didCloseVC(didCreateUser: Bool, clientId: String?, clientName : String?) {
        
        if didCreateUser{
            
            let alertController = UIAlertController(title: "Клиент создан!", message: nil, preferredStyle: .alert)
            
            let doneAction = UIAlertAction(title: "Готово", style: .cancel) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            let openAction = UIAlertAction(title: "Открыть", style: .default) { [self] (_) in
                goToClientVCWith(clientId)
            }
            
            alertController.addAction(doneAction)
            alertController.addAction(openAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
}

//MARK: -  ClientsPayRequestsDataManager

extension ClientsViewController : ClientsPayRequestsDataManagerDelegate{
    
    func didGetClientsPayRequestsData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.areRequests = true
                
                self?.balanceRequests.append(contentsOf: data["pay_reqs"].arrayValue)
                
                self?.tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientsPayRequestsDataWithError(error: String) {
        print("Error with ClientsPayRequestsDataManager : \(error)")
    }
    
}
