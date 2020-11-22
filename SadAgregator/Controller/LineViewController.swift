//
//  LineViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.11.2020.
//

import UIKit
import SwiftyJSON

class LineViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let key = UserDefaults.standard.string(forKey: "key")!
    var thisLineId : String?
    
    lazy var activityLineDataManager = ActivityLineDataManager()
    
    var lineData : JSON? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityLineDataManager.delegate = self
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        if let safeId = thisLineId{
            activityLineDataManager.getActivityData(key: key, lineId: safeId)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

//MARK: - ActivityLineDataManagerDelegate stuff
extension LineViewController : ActivityLineDataManagerDelegate{
    
    func didGetActivityData(data: JSON) {
        DispatchQueue.main.async{
            
            self.lineData = data
            
            self.tableView.reloadData()
        }
    }
    
    func didFailGettingActivityLineData(error: String) {
        print("Error with ActivityLineDataManager: \(error)")
    }
    
}

//MARK: - UITableView Stuff
extension LineViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let lineData = lineData else {return cell}
        
        switch index {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lineSwitchCell", for: indexPath)
            
            setUpSwitchCell(cell: cell, data: lineData["arrows"])
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: lineData["activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TochkiActivityCell", for: indexPath)
            
        default:
            print("IndexPath out of switch: \(index)")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            return 126
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func setUpSwitchCell(cell : UITableViewCell, data: JSON){
        
        if let leftLabel = cell.viewWithTag(2) as? UILabel,
           let rightLabel = cell.viewWithTag(3) as? UILabel{
            
            leftLabel.text = data["name_prev"].stringValue
            rightLabel.text = data["name_next"].stringValue
            
        }
        
    }
    
    func setUpGeneralPostsPhotosCell(cell : UITableViewCell , data : JSON){
        
        if let todaysPostsLabel = cell.viewWithTag(1) as? UILabel ,
           let yesterdayPostsLabel = cell.viewWithTag(2) as? UILabel,
           let todayPhotosLabel = cell.viewWithTag(3) as? UILabel,
           let yesterdayPhotosLabel = cell.viewWithTag(4) as? UILabel {
            
            todaysPostsLabel.text = data["post_today"].stringValue
            
            yesterdayPostsLabel.text = data["post_ystd"].stringValue
            
            todayPhotosLabel.text = data["photo_today"].stringValue
            
            yesterdayPhotosLabel.text = data["photo_ystd"].stringValue
            
        }
        
    }
    
}
