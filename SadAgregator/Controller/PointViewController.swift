//
//  TochkaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.11.2020.
//

import UIKit
import SwiftyJSON

class PointViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var key = UserDefaults.standard.string(forKey: "key")!
    var thisPointId : String?
    
    lazy var activityPointDataManager = ActivityPointDataManager()
    
    var pointData : JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityPointDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        if let safeId = thisPointId{
            activityPointDataManager.getActivityPointData(key: key, pointId: safeId)
        }
    }
    
}

extension PointViewController : ActivityPointDataManagerDelegate {
    
    func didGetActivityPointData(data: JSON) {
        DispatchQueue.main.async {
            
            self.pointData = data
            
            self.tableView.reloadData()
            
        }
    }
    
    func didFailGettingActivityPointDataWithError(error: String) {
        print("Error with ActivityPointDataManager: \(error)")
    }
    
}

//MARK: - UITableView

extension PointViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let tochkaData = pointData else {return cell}
        
        switch index {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "pointSwitchCell", for: indexPath)
            
            setUpSwitchCell(cell: cell, data: tochkaData["arrows"])
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: tochkaData["activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "agregatorsCell", for: indexPath)
            
        default:
            print("IndexPath out of switch: \(index)")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 126 : 50
    }
    
    //MARK: - Cell Setup
    
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
