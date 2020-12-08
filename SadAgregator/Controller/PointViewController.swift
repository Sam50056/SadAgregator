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
    
    var refreshControl = UIRefreshControl()
    
    var key = UserDefaults.standard.string(forKey: "key")!
    
    var thisPointId : String?
    
    lazy var activityPointDataManager = ActivityPointDataManager()
    
    lazy var pointPostsPaggingDataManager = PointPostsPaggingDataManager()
    
    var pointData : JSON?
    
    var vendsArray = [JSON]()
    var activityPointCellsArray = [JSON]()
    var postsArray = [JSON]()
    
    var page : Int = 1
    var rowForPaggingUpdate : Int!
    
    var nextPointId : String?{
        return pointData?["arrows"]["id_next"].string
    }
    
    var previousPointId : String? {
        return pointData?["arrows"]["id_prev"].string
    }
    
    var selectedVendId : String?
    
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
        pointPostsPaggingDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        tableView.register(UINib(nibName: "VendTableViewCell", bundle: nil), forCellReuseIdentifier: "vendCell")
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        self.navigationItem.title = "Точка"
        
        refresh(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        if let safeId = thisPointId{
            activityPointDataManager.getActivityPointData(key: key, pointId: safeId)
        }
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPostavshik"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
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
            
            self.rowForPaggingUpdate = 5 + self.vendsArray.count + 10
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
            
        }
    }
    
    func didFailGettingActivityPointDataWithError(error: String) {
        print("Error with ActivityPointDataManager: \(error)")
    }
    
}

//MARK: - PointPostsPaggingDataManagerDelegate

extension PointViewController : PointPostsPaggingDataManagerDelegate {
    
    func didGetPointPostsPaggingData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.postsArray.append(contentsOf: data["posts"].arrayValue)
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingPointPostsPaggingDataWithError(error: String) {
        print("Error with PointPostsPaggingDataManager: \(error)")
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
            
            let index = indexPath.row - 3
            
            let vend = vendsArray[index]
            
            return makeHeightForVendCell(vend: vend)
            
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
        
        let index = indexPath.row
        
        let maxIndexForVendCells = 3 + vendsArray.count - 1
        let maxIndexForActivityPointCells = 1 + maxIndexForVendCells + activityPointCellsArray.count
        let maxIndexForPosts = maxIndexForActivityPointCells + 1 + postsArray.count
        
        if index >= 3 && index <= maxIndexForVendCells {
            
            let indexForVends = index - 3
            
            selectedVendId = vendsArray[indexForVends]["id"].stringValue
            
            self.performSegue(withIdentifier: "goToPostavshik", sender: self)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func makeHeightForVendCell(vend : JSON) -> CGFloat {
        
        var height = 90
        
        let phone = vend["ph"].stringValue
        let pop = vend["pop"].intValue
        let rating = vend["rate"].stringValue
        
        if rating != "0" {
            height += 10
        }
        
        if phone != "" {
            height += 10
        }
        
        if pop != 0 {
            height += 10
        }
        
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if rowForPaggingUpdate == nil {return}
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 9
            
            pointPostsPaggingDataManager.getPointPostsPaggingData(key: key, pointId: thisPointId!, page: page)
            
            print("Done a request for page: \(page)")
            
        }
    }
    
    //MARK: - Switch Cells Funcs
    
    @IBAction func leftSwitchButtonPressed(sender : UIButton){
        
        guard let previousPointId = previousPointId else {return}
        
        thisPointId = previousPointId
        
        refresh(self)
        
    }
    
    @IBAction func rightSwitchButtonPressed(sender : UIButton){
        
        guard let nextPointId = nextPointId else {return}
        
        thisPointId = nextPointId
        
        refresh(self)
        
    }
    
    
    //MARK: - Cell Setup
    
    func setUpSwitchCell(cell : UITableViewCell, data: JSON){
        
        if let leftLabel = cell.viewWithTag(2) as? UILabel,
           let rightLabel = cell.viewWithTag(3) as? UILabel,
           let leftButtton = cell.viewWithTag(1) as? UIButton,
           let rightButton = cell.viewWithTag(4) as? UIButton{
            
            leftLabel.text = data["name_prev"].stringValue
            rightLabel.text = data["name_next"].stringValue
            
            rightButton.addTarget(self, action: #selector(rightSwitchButtonPressed(sender:)), for: .touchUpInside)
            
            leftButtton.addTarget(self, action: #selector(leftSwitchButtonPressed(sender:)), for: .touchUpInside)
            
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
        
        let price = data["price"].stringValue
        cell.priceLabel.text = "\(price == "0" ? "" : price + "руб")"
        
        cell.postedLabel.text = data["posted"].stringValue
        
        let sizesArray = sizes[index]
        let optionsArray = options[index]
        let imagesArray = images[index]
        
        cell.sizes = sizesArray
        cell.options = optionsArray
        cell.images = imagesArray
        
    }
    
}
