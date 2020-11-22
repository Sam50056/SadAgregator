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
    
    var activityTochkaCellsArray = [JSON]()
    
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
            
            self.activityTochkaCellsArray = data["points_top"].arrayValue
            
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
        return 3 + activityTochkaCellsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let lineData = lineData else {return cell}
        
        let maxIndexForActivityTochkaCells = 3 + activityTochkaCellsArray.count - 1 ///Max index (indexPath.row) for Activity tochka cells. So that 3 is because we have 3 static cells , then an array of activity tochka cells which is not static. So we do 3 + count of the array -1 (because array indexing starts from 0)  and get the max index we can put into switch. And what we'll put there will be 3..<array.count-1 This means that from 3rd index to 3 + array.count-1  all the cells will be "activityTochkaCell".
        
        switch index {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lineSwitchCell", for: indexPath)
            
            setUpSwitchCell(cell: cell, data: lineData["arrows"])
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: lineData["activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TochkiActivityCell", for: indexPath)
            
        case 3...maxIndexForActivityTochkaCells:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityTochkaCell", for: indexPath)
            
            let index = indexPath.row - 3 // We do minus three , still that 3 (count of static cells)
            
            let activityLine = activityTochkaCellsArray[index]
            
            setUpActivityLineCell(cell: cell, data: activityLine)
        
        case maxIndexForActivityTochkaCells + 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
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
    
    func setUpActivityLineCell(cell : UITableViewCell , data : JSON) {
        
        if let mainLabel = cell.viewWithTag(1) as? UILabel ,
           let lastActLabel = cell.viewWithTag(2) as? UILabel ,
           let postCountLabel = cell.viewWithTag(3) as? UILabel {
            
            mainLabel.text = data["capt"].stringValue
            
            lastActLabel.text = data["last_act"].stringValue
            
            postCountLabel.text = data["posts"].stringValue
            
        }
        
    }
    
}
