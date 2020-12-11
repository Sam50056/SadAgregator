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
    
    var refreshControl = UIRefreshControl()
    
    let key = UserDefaults.standard.string(forKey: "key")!
    var thisLineId : String?
    
    lazy var activityLineDataManager = ActivityLineDataManager()
    lazy var linePostsPaggingDataManager = LinePostsPaggingDataManager()
    
    var lineData : JSON?
    
    var activityPointCellsArray = [JSON]()
    var postsArray = [JSON]()
    
    var page : Int = 1
    var rowForPaggingUpdate : Int = 17
    
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
    
    var nextLineId : String?{
        return lineData?["arrows"]["id_next"].string
    }
    
    var previousLineId : String? {
        return lineData?["arrows"]["id_prev"].string
    }
    
    var selectedPointId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Линия"
        
        activityLineDataManager.delegate = self
        linePostsPaggingDataManager.delegate = self
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        refresh(self)
        
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
            
            self.navigationItem.title = data["capt"].stringValue
            
            self.activityPointCellsArray = data["points_top"].arrayValue
            
            self.postsArray = data["posts"].arrayValue
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
    }
    
    func didFailGettingActivityLineData(error: String) {
        print("Error with ActivityLineDataManager: \(error)")
    }
    
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        if let safeId = thisLineId{
            activityLineDataManager.getActivityData(key: key, lineId: safeId)
        }
        
    }
    
}

//MARK: - LinePostsPaggingDataManagerDelegate Stuff

extension LineViewController : LinePostsPaggingDataManagerDelegate {
    
    func didGetLinePostsPaggingData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.postsArray.append(contentsOf: data["posts"].arrayValue)
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingLinePostsPaggingDataWithError(error: String) {
        print("Error with LinePostsPaggingDataManager: \(error)")
    }
    
}


//MARK: - UITableView Stuff
extension LineViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + activityPointCellsArray.count + 1 + postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let lineData = lineData else {return cell}
        
        let maxIndexForActivityPointCells = 3 + activityPointCellsArray.count - 1 ///Max index (indexPath.row) for Activity point cells. So that 3 is because we have 3 static cells , then an array of activity point cells which is not static. So we do 3 + count of the array -1 (because array indexing starts from 0)  and get the max index we can put into switch. And what we'll put there will be 3..<array.count-1 This means that from 3rd index to 3 + array.count-1  all the cells will be "activityPointCell".
        
        let maxIndexForPosts = maxIndexForActivityPointCells + 1 + postsArray.count
        
        switch index {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lineSwitchCell", for: indexPath)
            
            setUpSwitchCell(cell: cell, data: lineData["arrows"])
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: lineData["activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TochkiActivityCell", for: indexPath)
            
        case 3...maxIndexForActivityPointCells:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityPointCell", for: indexPath)
            
            let index = indexPath.row - 3 // We do minus three , still that 3 (count of static cells)
            
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
        
        let maxIndexForActivityTochkaCells = 3 + activityPointCellsArray.count - 1
        let maxIndexForPosts = maxIndexForActivityTochkaCells + 1 + postsArray.count
        
        if indexPath.row == 1 {
            return 126
        }else if indexPath.row >= maxIndexForActivityTochkaCells + 2 && indexPath.row <= maxIndexForPosts{
            
            return 460
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        let maxIndexForActivityTochkaCells = 3 + activityPointCellsArray.count - 1
        let maxIndexForPosts = maxIndexForActivityTochkaCells + 1 + postsArray.count
        
        if index >= 3 && index <= maxIndexForActivityTochkaCells{
            
            let indexForCell = index - 3
            
            let cellData = activityPointCellsArray[indexForCell]
            
            selectedPointId = cellData["point_id"].stringValue
            
            self.performSegue(withIdentifier: "goToTochka", sender: self)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 9
            
            linePostsPaggingDataManager.getLinePostsPaggingData(key: key, lineId: thisLineId!, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
    //MARK: - Switch Cells Funcs
    
    @IBAction func leftSwitchButtonPressed(sender : UIButton){
        
        guard let previousLineId = previousLineId else {return}
        
        thisLineId = previousLineId
        
        refresh(self)
        
    }
    
    @IBAction func rightSwitchButtonPressed(sender : UIButton){
        
        guard let nextLineId = nextLineId else {return}
        
        thisLineId = previousLineId
        
        refresh(self)
        
    }
    
    //MARK: - Cells SetUp
    
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

//MARK: - Segue Stuff

extension LineViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToTochka" {
            
            let destinationVC = segue.destination as! PointViewController
            
            destinationVC.thisPointId = selectedPointId
            
        }
        
    }
}
