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
    var activityPointCellsArray = [JSON]()
    var postsArray = [JSON]()
    
    var sizes : Array<[String]> {
        get{
            var thisArray = Array<[String]>()
            
            for post in postsArray {
                
                let sizesForThisPost = post["sizes"].arrayValue
                
                var stringSizesForThisPost = [String]()
                
                for size in sizesForThisPost {
                    stringSizesForThisPost.append(size.stringValue)
                }
                
                thisArray.append(stringSizesForThisPost)
            }
            
            return thisArray
        }
    }
    
    var options : Array<[String]> {
        get{
            var thisArray = Array<[String]>()
            
            for post in postsArray {
                
                let optionsForThisPost = post["options"].arrayValue
                
                var stringOptionsForThisPost = [String]()
                
                for option in optionsForThisPost {
                    stringOptionsForThisPost.append(option.stringValue)
                }
                
                thisArray.append(stringOptionsForThisPost)
            }
            
            return thisArray
        }
    }
    
    var images : Array<[String]> {
        get{
            var thisArray = Array<[String]>()
            
            for post in postsArray {
                
                let imagesForThisPost = post["images"].arrayValue
                
                var stringImagesForThisPost = [String]()
                
                for image in imagesForThisPost {
                    stringImagesForThisPost.append(image["img"].stringValue)
                }
                
                thisArray.append(stringImagesForThisPost)
            }
            
            return thisArray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityPointDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "VendTableViewCell", bundle: nil), forCellReuseIdentifier: "vendCell")
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        self.navigationItem.title = "Точка"
        
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
            
            self.navigationItem.title = data["capt"].stringValue
            
            self.vendsArray = data["vends"].arrayValue
            
            self.activityPointCellsArray = data["points_top"].arrayValue
            
            self.postsArray = data["posts"].arrayValue
            
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
        return 3 + 1 + vendsArray.count + activityPointCellsArray.count + 1 + postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let tochkaData = pointData else {return cell}
        
        let maxIndexForVendCells = 3 + vendsArray.count - 1
        let maxIndexForActivityPointCells = 1 + maxIndexForVendCells + activityPointCellsArray.count
        let maxIndexForPosts = maxIndexForActivityPointCells + 1 + postsArray.count
        
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
            
        case maxIndexForVendCells + 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TochkiActivityCell", for: indexPath)
            
        case maxIndexForVendCells + 2...maxIndexForActivityPointCells:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityPointCell", for: indexPath)
            
            let index = indexPath.row - (maxIndexForVendCells + 2) // We do minus three , still that 3 (count of static cells)
            
            let activityLine = activityPointCellsArray[index]
            
            setUpActivityLineCell(cell: cell, data: activityLine)
            
        case maxIndexForActivityPointCells + 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
        case maxIndexForActivityPointCells + 2...maxIndexForPosts:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let index = indexPath.row - (maxIndexForActivityPointCells + 2)
            
            let post = postsArray[index]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index)
            
        default:
            print("IndexPath out of switch: \(index)")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let maxIndexForVendCells = 3 + vendsArray.count - 1
        let maxIndexForActivityPointCells = 1 + maxIndexForVendCells + activityPointCellsArray.count
        let maxIndexForPosts = maxIndexForActivityPointCells + 1 + postsArray.count
        
        if indexPath.row == 1 {
            return 126
        }else if indexPath.row >= 3 && indexPath.row <= maxIndexForVendCells && indexPath.row <= maxIndexForVendCells {
            return 115
        }else if indexPath.row >= maxIndexForActivityPointCells + 2 && indexPath.row <= maxIndexForPosts{
            
            let index = indexPath.row - (maxIndexForActivityPointCells + 2)
            
            if options[index].count > 4{
                return 500
            }
            
            if options.count > 6 {
                return 560
            }
            
            return 460
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
        
        cell.data = data
        
        cell.nameLabel.text = data["name"].stringValue
        
        cell.actLabel.text = data["act"].stringValue
        
        let peoples = data["peoples"].stringValue
        
        if peoples == "0"{
            cell.peoplesLabel.text = ""
            cell.peoplesImageView.isHidden = true
        }else{
            cell.peoplesLabel.text = peoples
            cell.peoplesImageView.isHidden = false
        }
        
        let rev = data["revs"].intValue
        
        if rev == 0{
            cell.revLabel.text = ""
            cell.revImageView.isHidden = true
        }else{
            cell.revLabel.text = String(rev)
            cell.revImageView.isHidden = false
        }
        
        let phone = data["ph"].stringValue
        let pop = data["pop"].intValue
        let rating = data["rate"].stringValue
        
        cell.rating = rating == "0" ? nil : rating
        cell.phone = phone == "" ? nil : phone
        cell.pop = pop == 0 ? "Нет уникального контента" : "Охват ~\(String(pop)) чел/сутки"
        
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
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int){
        
        cell.vendorLabel.text = data["vendor_capt"].stringValue
        
        cell.byLabel.text = data["by"].stringValue
        
        cell.priceLabel.text = "\(data["price"].stringValue) руб"
        
        let sizesArray = sizes[index]
        let optionsArray = options[index]
        let imagesArray = images[index]
        
        cell.sizes = sizesArray
        cell.options = optionsArray
        cell.images = imagesArray
        
    }
    
}
