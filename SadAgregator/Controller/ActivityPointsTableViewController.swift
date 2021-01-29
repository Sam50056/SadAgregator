//
//  ActivityPointsTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.01.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class ActivityPointsTableViewController: UITableViewController, TopPointsPaggingDataManagerDelegate, UISearchResultsUpdating, TopPointsPaggingSearchDataManagerDelegate, LinePointsPaggingSearchDataManagerDelegate, LinePointsPaggingDataManagerDelegate {
    
    let realm = try! Realm()
    
    var key = ""
    
    var lineId : String?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let activityController = UIActivityIndicatorView()
    
    var searchBarIsEmpty : Bool{
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
    lazy var topPointsPaggingDataManager = TopPointsPaggingDataManager()
    lazy var topPointsPaggingSearchDataManager = TopPointsPaggingSearchDataManager()
    lazy var linePointsPaggingDataManager = LinePointsPaggingDataManager()
    lazy var linePostsPaggingSearchDataManager = LinePointsPaggingSearchDataManager()
    
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
        topPointsPaggingSearchDataManager.delegate = self
        linePostsPaggingSearchDataManager.delegate = self
        linePointsPaggingDataManager.delegate = self
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.separatorStyle = .none
        
        if lineId != nil{
            linePointsPaggingDataManager.getLinePointsPaggingData(key: key, lineId: lineId!, page: page)
        }else{
            topPointsPaggingDataManager.getTopPointsPaggingData(key: key, page: page)
        }
        
        showSimpleCircleAnimation(activityController: activityController)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
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
        
        points.removeAll()
        page = 1
        
        if searchText != ""{
            
            if lineId != nil{
                linePostsPaggingSearchDataManager.getLinePostsPaggingSearchData(key: key, lineId: lineId!, query: searchText, page: page)
            }else{
                topPointsPaggingSearchDataManager.getTopPointsPaggingSearchData(key: key, query: searchText, page: page)
            }
            
        }else{
            
            if lineId != nil{
                linePointsPaggingDataManager.getLinePointsPaggingData(key: key, lineId: lineId!, page: page)
            }else{
                topPointsPaggingDataManager.getTopPointsPaggingData(key: key, page: page)
            }
            
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - TopPointsPaggingDataManager
    
    func didGetTopPointsPaggingData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            points.append(contentsOf: data["points_top"].arrayValue)
            
            tableView.reloadData()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingTopPointsPaggingDataWithError(error: String) {
        print("Error with TopPointsPaggingDataManager : \(error)")
    }
    
    //MARK: - TopPointsPaggingSearchDataManager
    
    func didGetTopPointsPaggingSearchData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            points.append(contentsOf: data["items"].arrayValue)
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingTopPointsPaggingSearchDataWithError(error: String) {
        print("Error with TopPointsPaggingSearchDataManager : \(error)")
    }
    
    //MARK: - LinePointsPaggingDataManager
    
    func didGetLinePointsPaggingData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            points.append(contentsOf: data["points_top"].arrayValue)
            
            tableView.reloadData()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingLinePointsPaggingDataWithError(error: String) {
        print("Error with LinePointsPaggingDataManager : \(error)")
    }
    
    //MARK: - LinePointsPaggingSearchDataManager
    
    func didgetLinePostsPaggingSearchData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            points.append(contentsOf: data["items"].arrayValue)
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingLinePostsPaggingSearchDataWithError(error: String) {
        print("Error with LinePointsPaggingSearchDataManager : \(error)")
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
            
            if searchController.searchBar.text! == "" || searchController.searchBar.text == nil{
                
                if lineId != nil{
                    linePointsPaggingDataManager.getLinePointsPaggingData(key: key, lineId: lineId!, page: page)
                }else{
                    topPointsPaggingDataManager.getTopPointsPaggingData(key: key, page: page)
                }
                
            }else{
                
                if lineId != nil{
                    linePostsPaggingSearchDataManager.getLinePostsPaggingSearchData(key: key, lineId: lineId!, query: searchController.searchBar.text!, page: page)
                }else {
                    
                    topPointsPaggingSearchDataManager.getTopPointsPaggingSearchData(key: key, query: searchController.searchBar.text!, page: page)
                    
                }
                
            }
            
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
