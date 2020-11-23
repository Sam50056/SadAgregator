//
//  TochkaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.11.2020.
//

import UIKit
import SwiftyJSON
import Cosmos

class PointViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var key = UserDefaults.standard.string(forKey: "key")!
    var thisPointId : String?
    
    lazy var activityPointDataManager = ActivityPointDataManager()
    
    var pointData : JSON?
    
    var vendsArray = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityPointDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(VendTableViewCell.self, forCellReuseIdentifier: "vendCell")
        
        if let safeId = thisPointId{
            activityPointDataManager.getActivityPointData(key: key, pointId: safeId)
        }
    }
    
}

//MARK: - ActivityPointDataManagerDelegate Stuff

extension PointViewController : ActivityPointDataManagerDelegate {
    
    func didGetActivityPointData(data: JSON) {
        DispatchQueue.main.async {
            
            self.pointData = data
            
            self.vendsArray = data["vends"].arrayValue
            
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
        return 3 + vendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let tochkaData = pointData else {return cell}
        
        let maxIndexForVendCells = 3 + vendsArray.count - 1
        
        switch index {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "pointSwitchCell", for: indexPath)
            
            setUpSwitchCell(cell: cell, data: tochkaData["arrows"])
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: tochkaData["activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "agregatorsCell", for: indexPath)
            
        case 3...maxIndexForVendCells:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "vendCell", for: indexPath)
            
            let index = indexPath.row - 3 // We do minus three , still that 3 (count of static cells)
            
            let vend = vendsArray[index]
            
            setUpVendCell(cell: cell as! VendTableViewCell, data: vend)
            
        default:
            print("IndexPath out of switch: \(index)")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let maxIndexForVendCells = 3 + vendsArray.count - 1
        //        let maxIndexForPosts = maxIndexForActivityTochkaCells + 1 + postsArray.count
        
        if indexPath.row == 1 {
            return 126
        }else if indexPath.row >= 3 && indexPath.row <= maxIndexForVendCells && indexPath.row <= maxIndexForVendCells {
            return 115
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    func setUpVendCell(cell: VendTableViewCell , data : JSON){
        
        let nameLabel = UILabel() //UILabel(frame: CGRect(x: 8, y: 8, width: 50, height: 20))
        let ratingView = CosmosView()
        
        nameLabel.font = UIFont(name: "Arial", size: 15)
        
        //        nameLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 8).isActive = true
        //        nameLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 8).isActive = true
        //        nameLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8).isActive = true
        //
        nameLabel.text = data["name"].stringValue
        
        cell.addSubview(nameLabel)
        
        ratingView.settings.filledColor = .lightGray
        ratingView.settings.filledBorderColor = .lightGray
        ratingView.settings.emptyBorderColor = .lightGray
        //            cell.frame = CGRect(x: 5, y: 5, width: 30, height: 15)
        //
        //        ratingView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        //        ratingView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 10).isActive = true
        //        ratingView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8).isActive = true
        //
        //
        cell.addSubview(ratingView)
    }
    
}
