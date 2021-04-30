//
//  LineViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.11.2020.
//

import UIKit
import SwiftyJSON
import RealmSwift

class LineViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var refreshControl = UIRefreshControl()
    
    let activityController = UIActivityIndicatorView()
    
    var key : String = ""
    var thisLineId : String?
    
    var isLogged = false
    
    lazy var activityLineDataManager = ActivityLineDataManager()
    lazy var linePostsPaggingDataManager = LinePostsPaggingDataManager()
    
    var lineData : JSON?
    
    var activityPointCellsArray = [JSON]()
    var postsArray = [JSON]()
    
    var page : Int = 1
    var rowForPaggingUpdate : Int = 15
    
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
    
    var images : Array<[PostImage]> {
        get{
            var thisArray = Array<[PostImage]>()
            
            for post in postsArray {
                
                let jsonImagesForThisPost = post["images"].arrayValue
                
                var ImagesForThisPost = [PostImage]()
                
                for image in jsonImagesForThisPost {
                    ImagesForThisPost.append(PostImage(image: image["img"].stringValue, imageId: image["img_id"].stringValue))
                }
                
                thisArray.append(ImagesForThisPost)
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
    var selectedVendId : String?
    
    var selectedPostId = ""
    
    var searchText = ""
    
    var thisPeerId = ""
    
    var doneArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Линия"
        
        loadUserData()
        
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
        
        navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserData()
        
        //Setting back button
        navigationItem.backBarButtonItem = nil
        
    }
    
}

//MARK: - Data Manipulation Methods

extension LineViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - ActivityLineDataManagerDelegate stuff

extension LineViewController : ActivityLineDataManagerDelegate{
    
    func didGetActivityData(data: JSON) {
        
        DispatchQueue.main.async{ [self] in
            
            lineData = data
            
            navigationItem.title = data["capt"].stringValue
            
            activityPointCellsArray = data["points_top"].arrayValue
            
            postsArray = data["posts"].arrayValue
            
            tableView.reloadData()
            
            refreshControl.endRefreshing()
            
            stopSimpleCircleAnimation(activityController: activityController)
        }
        
    }
    
    func didFailGettingActivityLineData(error: String) {
        print("Error with ActivityLineDataManager: \(error)")
    }
    
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        if let safeId = thisLineId{
            
            activityLineDataManager.getActivityData(key: key, lineId: safeId)
            
            showSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
}

//MARK: - LinePostsPaggingDataManagerDelegate Stuff

extension LineViewController : LinePostsPaggingDataManagerDelegate {
    
    func didGetLinePostsPaggingData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            postsArray.append(contentsOf: data["posts"].arrayValue)
            
            tableView.reloadSections([5], with: .none)
            
        }
        
    }
    
    func didFailGettingLinePostsPaggingDataWithError(error: String) {
        print("Error with LinePostsPaggingDataManager: \(error)")
    }
    
}


//MARK: - UITableView Stuff
extension LineViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return activityPointCellsArray.count
        case 4:
            return 1
        case 5:
            return postsArray.count
        default:
            fatalError("Invalid Section: \(section)")
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let lineData = lineData else {return cell}
        
        switch indexPath.section {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lineSwitchCell", for: indexPath)
            
            setUpSwitchCell(cell: cell, data: lineData["arrows"])
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: lineData["activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TochkiActivityCell", for: indexPath)
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityPointCell", for: indexPath)
            
            let activityLine = activityPointCellsArray[index]
            
            setUpActivityLineCell(cell: cell, data: activityLine)
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
        case 5:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let post = postsArray[index]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index, export: lineData["export"])
            
        default:
            print("IndexPath out of switch: \(index)")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        
        case 1:
            return 126
        case 2:
            return K.simpleHeaderCellHeight
        case 4:
            return K.simpleHeaderCellHeight
        case 5:
            return K.postHeight
        default:
            return K.simpleCellHeight
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        if indexPath.section == 2{
            
            performSegue(withIdentifier: "goToActivityPoints", sender: self)
            
        }else if indexPath.section == 3 {
            
            let cellData = activityPointCellsArray[index]
            
            selectedPointId = cellData["point_id"].stringValue
            
            self.performSegue(withIdentifier: "goToPoint", sender: self)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 5 {
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                linePostsPaggingDataManager.getLinePostsPaggingData(key: key, lineId: thisLineId!, page: page)
                
                print("Done a request for page: \(page)")
                
            }
            
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
        
        thisLineId = nextLineId
        
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
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int, export : JSON?){
        
        cell.delegate = self
        
        cell.key = key
        
        let postId = data["id"].stringValue
        
        cell.id = postId
        
        let like = data["like"].stringValue
        cell.like = like
        
        like == "0" ? (cell.likeButtonImageView.image = UIImage(systemName: "heart")) : (cell.likeButtonImageView.image = UIImage(systemName: "heart.fill"))
        
        cell.vkLinkUrlString = data["vk_post"].stringValue
        
        cell.soobshitButtonCallback = { [self] in
            
            GetPostActionsDataManager(delegate: self).getGetPostActionsData(key: key, postId: postId)
            
            selectedPostId = postId
            
        }
        
        cell.vendorLabelButtonCallBack = { [self] in
            
            selectedPointId = data["point_id"].stringValue
            
            self.performSegue(withIdentifier: "goToPoint", sender: self)
            
        }
        
        cell.byLabelButtonCallback = { [self] in
            
            selectedVendId = data["vendor_id"].stringValue
            
            self.performSegue(withIdentifier: "goToVend", sender: self)
            
        }
        
        cell.peerButtonCallback = { [self] in
            
            guard isLogged else {
                
                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                
                return
            }
            
            showSimpleCircleAnimation(activityController: activityController)
            
            ExportPeersDataManager(delegate: self).getExportPeersData(key: key)
            
        }
        
        if thisPeerId != cell.peerId {
            cell.vigruzitLabel.text = "Выгрузить"
            cell.peerId = thisPeerId
            doneArray.removeAll()
        }
        
        if doneArray.contains(postId){
            cell.vigruzitLabel.text = "Готово"
        }else{
            cell.vigruzitLabel.text = "Выгрузить"
        }
        
        cell.vigruzitButtonCallback = { [self] in
            
            guard isLogged else {
                
                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                
                return
            }
            
            if lineData!["export"]["fast"].intValue == 0{
                
                let editVigruzkaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditVigruzkaVC") as! EditVigruzkaViewController
                
                editVigruzkaVC.thisPostId = postId
                
                editVigruzkaVC.toExpQueueDataManagerCallback = {
                    
                    cell.vigruzitLabel.text = "Готово"
                    doneArray.append(postId)
                   
                }
                
                present(editVigruzkaVC, animated: true, completion: nil)
                
            }else{
                
                ToExpQueueDataManager().getToExpQueueData(key: key, postId: postId, completionHandler: { data , error in
                    
                    DispatchQueue.main.async {
                        
                        if error != nil , data == nil {
                            print("Error with ToExpQueueDataManager : \(error!)")
                            return
                        }
                        
                        if data!["result"].intValue == 1{
                            
                            cell.vigruzitLabel.text = "Готово"
                            doneArray.append(postId)
                            
                            print("ToExpQueueDataManager Request Sent")
                            
                        }else{
                            
                            showSimpleAlertWithOkButton(title: "Ошибка отправки запроса", message: nil, dismissButtonText: "Закрыть")
                            
                        }
                        
                    }
                    
                })
                
            }
            
        }
        
        if let export = export{
            
            let exportType = export["type"].stringValue
            
            cell.vigruzitImageView.image = exportType == "vk" ? UIImage(named: "vk") : UIImage(named: "odno")
            
        }
        
        cell.showDescription = false
        
        cell.postDescription = data["text"].stringValue != "" ?  data["text"].stringValue : nil
        
        cell.vendorLabel.text = data["vendor_capt"].stringValue
        
        cell.byLabel.text = data["by"].stringValue
        
        let price = data["price"].stringValue
        cell.priceLabel.text = "\(price == "0" ? "" : price + " руб")"
        
        cell.postedLabel.text = data["posted"].stringValue
        
        let sizesArray = sizes[index]
        let optionsArray = options[index]
        let imagesArray = images[index]
        
        cell.sizes = sizesArray
        cell.options = optionsArray
        cell.images = imagesArray
        
        isLogged ? (cell.likeButtonImageView.isHidden = false) : (cell.likeButtonImageView.isHidden = true)
        
        !isLogged ? (cell.vigruzitView.alpha = 0.6) : (cell.vigruzitView.alpha = 1)
        
    }
    
}

//MARK: - PostCellCollectionViewActionsDelegate stuff

extension LineViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnOptionCell(option: String) {
        
        searchText = option
        
        performSegue(withIdentifier: "goSearch", sender: self)
        
    }
    
    func didTapOnImageCell(index: Int, images: [PostImage], sizes : [String]) {
        
        let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        galleryVC.selectedImageIndex = index
        
        galleryVC.images = images
        
        galleryVC.sizes = sizes
        
        let navVC = UINavigationController(rootViewController: galleryVC)
        
        presentHero(navVC, navigationAnimationType: .fade)
        
    }
    
}

//MARK: -  GetPostActionsDataManagerDelegate Stuff

extension LineViewController : GetPostActionsDataManagerDelegate{
    
    func didGetGetPostActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let actionsArray = data["actions"].arrayValue
            
            showActionsSheet(actionsArray: actionsArray) { (action) in
                
                let actionid = (action["id"].stringValue)
                
                SetPostActionsDataManager(delegate: self).getSetPostActionsData(key: key, actionId: actionid, postId: selectedPostId)
                
            }
            
        }
        
    }
    
    func didFailGettingGetPostActionsDataWithError(error: String) {
        print("Error with  GetPostActionsDataManager : \(error)")
    }
    
}

//MARK: - SetPostActionsDataManagerDelegate

extension LineViewController : SetPostActionsDataManagerDelegate{
    
    func didGetSetPostActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            dismiss(animated: true, completion: nil)
            
            if let message = data["msg"].string{
                
                showSimpleAlertWithOkButton(title: message, message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingSetPostActionsDataWithError(error: String) {
        print("Error with SetPostActionsDataManager : \(error)")
    }
    
}

//MARK: - ExportPeersDataManager

extension LineViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            stopSimpleCircleAnimation(activityController: activityController)
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType , newPeerId) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        lineData!["export"]["type"].stringValue = newType
                        
                        thisPeerId = newPeerId
                        
                        tableView.reloadData()
                        
                    }
                    
                }
                
                present(peerVC, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingExportPeersDataWithError(error: String) {
        print("Error with ExportPeersDataManager : \(error)")
    }
    
}

//MARK: - Segue Stuff

extension LineViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPoint" {
            
            let destinationVC = segue.destination as! PointViewController
            
            destinationVC.thisPointId = selectedPointId
            
        }else if segue.identifier == "goToActivityPoints"{
            
            let destinationVC = segue.destination as! ActivityPointsTableViewController
            
            destinationVC.lineId = thisLineId
            
        }else if segue.identifier == "goToVend"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
        }else if segue.identifier == "goSearch" {
            
            let destinationVC = segue.destination as! SearchViewController
            
            destinationVC.searchText = searchText
            
        }
        
    }
}
