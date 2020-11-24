//
//  ViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.11.2020.
//

import UIKit
import SwiftyJSON

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl = UIRefreshControl()
    
    var key = UserDefaults.standard.string(forKey: "key")
    
    lazy var checkKeysDataManager = CheckKeysDataManager()
    lazy var mainDataManager = MainDataManager()
    
    var mainData : JSON?
    
    var activityLineCellsArray = [JSON]()
    var postavshikActivityCellsArray = [JSON]()
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
    
    var selectedLineId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkKeysDataManager.delegate = self
        mainDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        tableView.separatorStyle = .none
        
        searchView.layer.cornerRadius = 8
        
        checkKeysDataManager.getKeysData(key: key)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        //Setting back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
    }
    
}

//MARK: - CheckKeysDataManagerDelegate stuff

extension MainViewController : CheckKeysDataManagerDelegate {
    
    func didGetCheckKeysData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if let safeKey = data["key"].string {
                
                print("Key: \(safeKey)")
                
                UserDefaults.standard.set(safeKey, forKey: "key") //Saving the key to UserDefaults
                
                self.key = safeKey
                
                self.mainDataManager.getMainData(key: safeKey)
                
            }
            
            //Message field from api
            let message = data["message"]
            
            //Checking if it is there or not
            if message.exists() {
                
                guard let id = message["id"].int ,
                      let title = message["title"].string,
                      let msg = message["msg"].string else {
                    return
                }
                
                let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Закрыть", style: .cancel) { (_) in
                    
                    guard let key = self.key else {return}
                    
                    MessageReadedDataManager().getMessageReadedData(key: key, messageId: String(id))
                    
                    alertController.dismiss(animated: true, completion: nil)
                    
                }
                
                alertController.addAction(action)
                
            }
        }
    }
    
    func didFailGettingCheckKeysData(error: String) {
        print("Error with CheckKeysDataManager: \(error)")
    }
    
}

//MARK: - MainDataManagerDelegate stuff

extension MainViewController : MainDataManagerDelegate{
    
    func didGetMainData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.mainData = data //Saving main page data from api to this var
            
            self.activityLineCellsArray = data["lines_act_top"].arrayValue
            
            self.postavshikActivityCellsArray = data["points_top"].arrayValue
            
            self.postsArray = data["posts"].arrayValue
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
    }
    
    func didFailGettingMainData(error: String) {
        print("Error with MainDataManager: \(error)")
    }
    
}

//MARK: - UITableView stuff

extension MainViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + activityLineCellsArray.count + 1 + 1 + postavshikActivityCellsArray.count + postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard let mainPageData = mainData else {
            return cell
        }
        
        let maxIndexForActivityLineCells = 3 + activityLineCellsArray.count - 1 ///Max index (indexPath.row) for Activity line cells. So that 3 is because we have 3 static cells , then an array of activity line cells which is not static. So we do 3 + count of the array -1 (because array indexing starts from 0)  and get the max index we can put into switch. And what we'll put there will be 3..<array.count-1 This means that from 3rd index to 3 + array.count-1  all the cells will be "activityLineCell".
        
        let maxIndexForPostavshikActivityCells = maxIndexForActivityLineCells + 1 + postavshikActivityCellsArray.count  /// We take maxIndexForActivityLineCells and do + 1 because there is "postavshikiActivityCell" , then do + 1 again to get the index after that cell and that is the stating point for  postavshikActivityCellsArray. And for getting the maxIndexForPostavshikActivityCells , we add to that starting point or stating index the count of postavshikActivityCellsArray.
        
        let maxIndexForPosts = maxIndexForPostavshikActivityCells + 1 + postsArray.count
        
        switch indexPath.row {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath)
            
            if let label = cell.viewWithTag(1) as? UILabel {
                label.text = mainPageData["activity"].stringValue
            }
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: mainPageData["total_activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "linesActivityCell", for: indexPath)
            
        case 3...maxIndexForActivityLineCells:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityLineCell", for: indexPath)
            
            let index = indexPath.row - 3 // We do minus three , still that 3 (count of static cells)
            
            let activityLine = activityLineCellsArray[index]
            
            setUpActivityLineCell(cell: cell, data: activityLine)
            
        case maxIndexForActivityLineCells + 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postavshikiActivityCell", for: indexPath)
            
        case maxIndexForActivityLineCells + 2...maxIndexForPostavshikActivityCells:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postavshikActivityCell", for: indexPath)
            
            let index = indexPath.row - (maxIndexForActivityLineCells + 2)
            
            let postavshikActivityLCell = postavshikActivityCellsArray[index]
            
            setUpPostavshikCell(cell: cell, data: postavshikActivityLCell)
            
        case maxIndexForPostavshikActivityCells + 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
        case maxIndexForPostavshikActivityCells + 2...maxIndexForPosts:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let index = indexPath.row - (maxIndexForPostavshikActivityCells + 2)
            
            let post = postsArray[index]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index)
            
        default:
            print("Error with indexPath (Got out of switch)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let maxIndexForActivityLineCells = 3 + activityLineCellsArray.count - 1
        let maxIndexForPostavshikActivityCells = maxIndexForActivityLineCells + 1 + postavshikActivityCellsArray.count
        let maxIndexForPosts = maxIndexForPostavshikActivityCells + 1 + postsArray.count
        
        if indexPath.row == 1 {
            return 126
        }else if indexPath.row >= maxIndexForPostavshikActivityCells + 2 && indexPath.row <= maxIndexForPosts{
            
            let index = indexPath.row - (maxIndexForPostavshikActivityCells + 2)
            
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
        
        let maxIndexForActivityLineCells = 3 + activityLineCellsArray.count - 1
        let maxIndexForPostavshikActivityCells = maxIndexForActivityLineCells + 1 + postavshikActivityCellsArray.count
        let maxIndexForPosts = maxIndexForPostavshikActivityCells + 1 + postsArray.count
        
        if index >= 3 && index <= maxIndexForActivityLineCells{
            
            let indexForCell = index - 3
            
            let cellData = activityLineCellsArray[indexForCell]
            
            selectedLineId = cellData["line_id"].stringValue
            
            self.performSegue(withIdentifier: "goToLine", sender: self)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        guard let key = key else {
            return
        }
        
        mainDataManager.getMainData(key: key)
    }
    
    
    //MARK: - Cells Setup
    
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
    
    func setUpPostavshikCell(cell : UITableViewCell , data : JSON){
        
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

//MARK: - Segue Stuff

extension MainViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToLine"{
            
            let destinationVC = segue.destination as! LineViewController
            
            destinationVC.thisLineId = selectedLineId
            
        }
        
    }
    
}