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
    
    let realm = try! Realm()
    
    var key = ""
    
    var hideLabel :  UILabel?
    var hideLabelImageView : UIImageView?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var areStatsShown = true
    
    var pagingClientsDataManager = PagingClientsDataManager()
    
    var page = 1
    var rowForPaggingUpdate : Int = 15
    
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
        
        pagingClientsDataManager.delegate = self
        
        pagingClientsDataManager.getPagingClientsData(key: key, page: page)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Клиенты"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: nil) , UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: nil)]
        
    }
    
}

//MARK: - SearchBar

extension ClientsViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
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
            return areStatsShown ? 3 : 0
        case 2:
            return 1
        case 3:
            return 2
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
                
                firstLabel.text = "Клиенты"
                
                secondLabel.text = "3"
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
            
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
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3{
            return 78
        }
        return K.simpleHeaderCellHeight
    }
    
}

//MARK: - PagingClientsDataManagerDelegate

extension ClientsViewController : PagingClientsDataManagerDelegate{
    
    func didGetPagingClientsData(data: JSON) {
        DispatchQueue.main.async { [self] in
            
            
            
        }
    }
    
    func didFailGettingPagingClientsDataWithErorr(error: String) {
        print("Error with PagingClientsDataManager : \(error)")
    }
    
}

