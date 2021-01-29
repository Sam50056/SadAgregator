//
//  ActivityLinesTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.01.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class ActivityLinesTableViewController: UITableViewController, TopLinesDataManagerDelegate {
    
    let activityController = UIActivityIndicatorView()
    
    let realm = try! Realm()
    
    var key = "" 
    
    lazy var topLinesDataManager = TopLinesDataManager()
    
    var lines = [JSON]()
    
    var selectedLineId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        topLinesDataManager.delegate = self
        
        tableView.separatorStyle = .none
        
        topLinesDataManager.getTopLinesData(key: "")
        
        showSimpleCircleAnimation(activityController: activityController)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
    //MARK: - TopLinesDataManagerDelegate
    
    func didGetTopLinesData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            lines = data["lines_act_top"].arrayValue
            
            tableView.reloadSections([0], with: .automatic)
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingTopLinesDataWithError(error: String) {
        print("Error with  TopLinesDataManager : \(error)")
    }
    
    
    // MARK: - Table View Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return lines.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityLineCell", for: indexPath)
        
        setUpActivityLineCell(cell: cell, data: lines[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedLineId = lines[indexPath.row]["line_id"].stringValue
        
        performSegue(withIdentifier: "goToLine", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.simpleCellHeight
    }
    
    //MARK: - Cell SetUp
    
    func setUpActivityLineCell(cell : UITableViewCell , data : JSON) {
        
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
        
        let destinationVC = segue.destination as! LineViewController
        
        destinationVC.thisLineId = selectedLineId
        
    }
    
}
