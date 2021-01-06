//
//  ActivityPointsTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.01.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class ActivityPointsTableViewController: UITableViewController, TopPointsPaggingDataManagerDelegate, UISearchResultsUpdating {
    
    let realm = try! Realm()
    
    var key = ""
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchBarIsEmpty : Bool{
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
    lazy var topPointsPaggingDataManager = TopPointsPaggingDataManager()
    
    var points = [JSON](){
        didSet{
            filteredPoints = points
        }
    }
    var filteredPoints = [JSON]()
    
    var page = 1
    var rowForPaggingUpdate = 15
    
    var selectedPointId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        topPointsPaggingDataManager.delegate = self
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.separatorStyle = .none
        
        topPointsPaggingDataManager.getTopPointsPaggingData(key: key, page: page)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
        //Setting back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        
        searchController.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
    //MARK: - Search Controller Stuff
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text!
        
        if searchText != ""{
            
            filteredPoints = points.filter({ (point) -> Bool in
                
                return point["capt"].stringValue.lowercased().contains(searchText.lowercased())
                
            })
            
        }else{
            filteredPoints = points
        }
        
        tableView.reloadSections([0], with: .automatic)
        
    }
    
    //MARK: - TopPointsPaggingDataManager
    
    func didGetTopPointsPaggingData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            points.append(contentsOf: data["points_top"].arrayValue)
            
            tableView.reloadSections([0], with: .automatic)
            
        }
        
    }
    
    func didFailGettingTopPointsPaggingDataWithError(error: String) {
        print("Error with TopPointsPaggingDataManager : \(error)")
    }
    
    // MARK: - Table View Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredPoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityPointCell", for: indexPath)
        
        setUpActivityPointCell(cell: cell, data: points[indexPath.row])
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedPointId = points[indexPath.row]["point_id"].stringValue
        
        self.performSegue(withIdentifier: "goToPoint", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            topPointsPaggingDataManager.getTopPointsPaggingData(key: key, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
    //MARK: - Cells SetUp
    
    func setUpActivityPointCell(cell : UITableViewCell , data : JSON){
        
        if let mainLabel = cell.viewWithTag(1) as? UILabel ,
           let lastActLabel = cell.viewWithTag(2) as? UILabel ,
           let postCountLabel = cell.viewWithTag(3) as? UILabel {
            
            mainLabel.text = data["capt"].stringValue
            
            lastActLabel.text = data["last_act"].stringValue
            
            postCountLabel.text = data["posts"].stringValue
            
        }
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! PointViewController
        
        destinationVC.thisPointId = selectedPointId
        
    }
    
}
