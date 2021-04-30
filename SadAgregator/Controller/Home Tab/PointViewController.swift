//
//  TochkaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.11.2020.
//

import UIKit
import SwiftyJSON
import Cosmos
import RealmSwift

class PointViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var refreshControl = UIRefreshControl()
    
    let activityController = UIActivityIndicatorView()
    
    var key = ""
    
    var isLogged = false 
    
    var thisPointId : String?
    
    lazy var activityPointDataManager = ActivityPointDataManager()
    
    lazy var pointPostsPaggingDataManager = PointPostsPaggingDataManager()
    
    lazy var getPointActionsDataManager = GetPointActionsDataManager()
    
    var pointData : JSON?
    
    var vendsArray = [JSON]()
    var activityPointCellsArray = [JSON]()
    var postsArray = [JSON]()
    
    var page : Int = 1
    var rowForPaggingUpdate = 15
    
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
    
    var selectedPostId = ""
    
    var searchText = ""
    
    var thisPeerId = ""
    
    var doneArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        activityPointDataManager.delegate = self
        pointPostsPaggingDataManager.delegate = self
        getPointActionsDataManager.delegate = self
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserData()
    }
    
    //MARK: - Actions
    
    @IBAction func helpBarButtonTapped(_ sender : UIBarButtonItem){
        
        guard let thisPointId = thisPointId else {return}
        
        getPointActionsDataManager.getGetPointActionsData(key: key, pointId: thisPointId)
        
    }
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        if let safeId = thisPointId{
            
            activityPointDataManager.getActivityPointData(key: key, pointId: safeId)
            
            showSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToVend"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
        }else if segue.identifier == "goSearch" {
            
            let destinationVC = segue.destination as! SearchViewController
            
            destinationVC.searchText = searchText
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension PointViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}


//MARK: - ActivityPointDataManagerDelegate Stuff

extension PointViewController : ActivityPointDataManagerDelegate {
    
    func didGetActivityPointData(data: JSON) {
        DispatchQueue.main.async { [self] in
            
            pointData = data
            
            navigationItem.title = data["capt"].stringValue
            
            vendsArray = data["vends"].arrayValue
            
            activityPointCellsArray = data["points_top"].arrayValue
            
            postsArray = data["posts"].arrayValue
            
            tableView.reloadData()
            
            refreshControl.endRefreshing()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
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
            
            self.tableView.reloadSections([8], with: .none)
            
        }
        
    }
    
    func didFailGettingPointPostsPaggingDataWithError(error: String) {
        print("Error with PointPostsPaggingDataManager: \(error)")
    }
    
}

//MARK: - GetPointActionsDataManagerDelegate Stuff

extension PointViewController : GetPointActionsDataManagerDelegate{
    
    func didGetGetPointActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let actionsArray = data["actions"].arrayValue
            
            showActionsSheet(actionsArray: actionsArray) { (action) in
                
                let actionid = (action["id"].stringValue)
                
                SetPointActionsDataManager(delegate: self).getSetPointActionsData(key: key, pointId: thisPointId!, actionId: actionid)
                
            }
            
        }
        
    }
    
    func didFailGettingGetPointActionsDataWithError(error: String) {
        print("Error with GetPointActionsDataManager : \(error)")
    }
    
}

extension PointViewController : SetPointActionsDataManagerDelegate{
    
    func didGetSetPointActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            dismiss(animated: true, completion: nil)
            
            if let message = data["msg"].string{
                
                showSimpleAlertWithOkButton(title: message, message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingSetPointActionsDataWithError(error: String) {
        print("Error with SetPointActionsDataManager : \(error)")
    }
    
}

//MARK: - UITableView

extension PointViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            
            if pointData?["alert_text"].stringValue != "" || pointData?["altert_text"].stringValue != "" {
                return 1
            }else {
                return 0
            }
            
        case 3:
            return 1
        case 4:
            return vendsArray.count
        case 5:
            return 1
        case 6:
            return activityPointCellsArray.count
        case 7:
            return 1
        case 8:
            return postsArray.count
        default:
            fatalError("Invalid section: \(section)")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        guard let pointData = pointData else {return cell}
        
        switch indexPath.section {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "pointSwitchCell", for: indexPath)
            
            setUpSwitchCell(cell: cell, data: pointData["arrows"])
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
            
            setUpGeneralPostsPhotosCell(cell: cell, data: pointData["activity"])
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath)
            
            setUpAlertCell(cell: cell, data: pointData)
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "agregatorsCell", for: indexPath)
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "vendCell", for: indexPath)
            
            let index = indexPath.row
            
            let vend = vendsArray[index]
            
            setUpVendCell(cell: cell as! VendTableViewCell, data: vend)
            
        case 5:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "TochkiActivityCell", for: indexPath)
            
        case 6:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityPointCell", for: indexPath)
            
            let index = indexPath.row
            
            let activityLine = activityPointCellsArray[index]
            
            setUpActivityLineCell(cell: cell, data: activityLine)
            
        case 7:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
        case 8:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let index = indexPath.row
            
            let post = postsArray[index]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index, export: pointData["export"])
            
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
            return 80
        case 3:
            return K.simpleHeaderCellHeight
        case 4:
            
            let index = indexPath.row
            
            let vend = vendsArray[index]
            
            return K.makeHeightForVendCell(vend: vend)
        case 5:
            return K.simpleHeaderCellHeight
        case 7:
            return K.simpleHeaderCellHeight
        case 8:
            
            return K.postHeight
            
        default:
            return K.simpleCellHeight
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        if indexPath.section == 4 {
            
            selectedVendId = vendsArray[index]["id"].stringValue
            
            self.performSegue(withIdentifier: "goToVend", sender: self)
            
        }else if indexPath.section == 6{
            
            self.thisPointId = activityPointCellsArray[indexPath.row]["point_id"].stringValue
            
            self.page = 1
            
            self.refresh(self)
            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if rowForPaggingUpdate == nil {return}
        
        if indexPath.section == 8{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                pointPostsPaggingDataManager.getPointPostsPaggingData(key: key, pointId: thisPointId!, page: page)
                
                print("Done a request for page: \(page)")
                
            }
            
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
    
    func setUpAlertCell(cell : UITableViewCell, data: JSON){
        
        if let label = cell.viewWithTag(1) as? UILabel{
            
            label.text = data["alert_text"].stringValue != "" ? data["alert_text"].stringValue : data["altert_text"].stringValue
            
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
            
            let newPointId = data["point_id"].stringValue
            
            thisPointId = newPointId
            
            refresh(self)
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
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
            
            if pointData!["export"]["fast"].intValue == 0{
                
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

extension PointViewController : PostCellCollectionViewActionsDelegate{
    
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

extension PointViewController : GetPostActionsDataManagerDelegate{
    
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

extension PointViewController : SetPostActionsDataManagerDelegate{
    
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

extension PointViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            stopSimpleCircleAnimation(activityController: activityController)
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType , newPeerId) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        pointData!["export"]["type"].stringValue = newType
                        
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
