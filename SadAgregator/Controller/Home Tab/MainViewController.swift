//
//  ViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.11.2020.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Hero

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    var refreshControl = UIRefreshControl()
    
    let activityController = UIActivityIndicatorView()
    
    let realm = try! Realm()
    
    var key : String?
    
    var isLogged : Bool = false
    
    var imageHashSearch : String?
    var imageHashServer : String?
    
    lazy var checkKeysDataManager = CheckKeysDataManager()
    lazy var mainDataManager = MainDataManager()
    lazy var mainPaggingDataManager = MainPaggingDataManager()
    
    var mainData : JSON?
    
    var activityLineCellsArray = [JSON]()
    var activityPointCellsArray = [JSON]()
    var postsArray = [JSON]()
    
    var page = 1
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
    var selectedPointId : String?
    var selectedVendId : String?
    
    var selectedPostId = ""
    
    var searchImageHash : String?
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        checkKeysDataManager.delegate = self
        mainDataManager.delegate = self
        mainPaggingDataManager.delegate = self
        
        searchTextField.delegate = self
        
        tabBarController?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        tableView.separatorStyle = .none
        
        searchView.layer.cornerRadius = 10
        
        checkKeysDataManager.getKeysData(key: key)
        
        showSimpleCircleAnimation(activityController: activityController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        enableHero()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Clear the searchTextField
        searchTextField.text = ""
        searchTextField.endEditing(true)
        
        disableHero()
    }
    
}

//MARK: - Actions

extension MainViewController {
    
    @IBAction func photoSearchButtonPressed(_ sender : UIButton){
        
        showImagePickerController(sourceType: .photoLibrary)
        
    }
    
}

//MARK: - UITabBarControllerDelegate

extension MainViewController : UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let index = tabBarController.selectedIndex
        
        if index == 0{
            
            self.tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: true)
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension MainViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        let userDataFirst = userDataObject.first
        
        print("Key Realm: \(String(describing: userDataFirst?.key))")
        
        key = userDataFirst?.key
        isLogged = userDataFirst?.isLogged ?? false
        imageHashServer = userDataFirst?.imageHashServer
        imageHashSearch = userDataFirst?.imageHashSearch
        
    }
    
    func deleteAllDataFromDB(){
        
        //Deleting everything from DB
        do{
            
            try realm.write{
                realm.deleteAll()
            }
            
        }catch{
            print("Error with deleting all data from Realm , \(error) ERROR DELETING REALM")
        }
        
    }
    
}

//MARK: - UIImagePickerControlller

extension MainViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let safeFileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL , let imageHashServer = imageHashServer{
            
            SendFileDataManager(delegate: self).sendPhotoMultipart(urlString: imageHashServer, fileUrl: safeFileUrl)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - SendFileDataManagerDelegate

extension MainViewController : SendFileDataManagerDelegate{
    
    func didGetSendPhotoData(data: JSON) {
        
        DispatchQueue.main.async {
            
            let fullHash = data["hash"].stringValue
            
            self.searchImageHash = fullHash
            
            self.performSegue(withIdentifier: "goSearch", sender: self)
            
        }
        
    }
    
    func didFailGettingSendPhotoDataWithErorr(error: String) {
        print("Error with SendFileDataManager : \(error)")
    }
    
    
}

//MARK: - CheckKeysDataManagerDelegate stuff

extension MainViewController : CheckKeysDataManagerDelegate {
    
    func didGetCheckKeysData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if let safeKey = data["key"].string {
                
                print("Key: \(safeKey)")
                
                let userDataObject = UserData()
                
                if data["anonym"].stringValue == "0"{
                    
                    let name = data["name"].stringValue
                    
                    let code = data["code"].stringValue
                    
                    let lkVends = data["lk_vends"].stringValue
                    let lkPosts = data["lk_posts"].stringValue
                    
                    userDataObject.name = name
                    userDataObject.code = code
                    
                    userDataObject.lkPosts = lkPosts
                    userDataObject.lkVends = lkVends
                    
                    userDataObject.settings = data["settings"].stringValue
                    
                    userDataObject.isLogged = true
                    
                }else{
                    userDataObject.isLogged = false
                }
                
                userDataObject.imageHashSearch = data["img_hash_srch"].stringValue
                userDataObject.imageHashServer = data["img_hash_srv"].stringValue
                
                userDataObject.key = safeKey
                
                deleteAllDataFromDB()
                
                do{
                    try self.realm.write{
                        self.realm.add(userDataObject)
                    }
                }catch{
                    print("Error saving data to realm , \(error.localizedDescription)")
                }
                
                loadUserData()
                
                refresh(self)
                
                //Update UN token on server
                if let unToken = UserDefaults.standard.string(forKey: K.UNToken){
                    
                    //                    print("IS TOKEN SAME? : -\(unToken == data["dev_ios"].arrayValue[0].stringValue)")
                    
                    //Checking if current token is the same as saved on server
                    let devIos = data["dev_ios"].arrayValue
                    
                    if !devIos.isEmpty,unToken != devIos[0].stringValue{
                        
                        UpdateDeviceDataManager().updateDevice(key: key!, token: unToken)
                        
                    }
                    
                }
                
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
                
                present(alertController, animated: true, completion: nil)
                
            }
            
            stopSimpleCircleAnimation(activityController: activityController)
            
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
            
            self.activityPointCellsArray = data["points_top"].arrayValue
            
            self.postsArray = data["posts"].arrayValue
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
    }
    
    func didFailGettingMainData(error: String) {
        print("Error with MainDataManager: \(error)")
    }
    
}

//MARK: - MainPaggingDataManagerDelegate Stuff

extension MainViewController : MainPaggingDataManagerDelegate{
    
    func didGetMainPaggingData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.postsArray.append(contentsOf: data["posts"].arrayValue)
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingMainPaggingDataWithError(error: String) {
        print("Error with MainPaggingDataManager: \(error)")
    }
    
}

//MARK: - UITextField Stuff

extension MainViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != ""{
            self.performSegue(withIdentifier: "goSearch", sender: self)
        }
        
        return true
        
    }
    
}

//MARK: - UITableView stuff

extension MainViewController : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
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
            return activityLineCellsArray.count
        case 4:
            return 1
        case 5:
            return activityPointCellsArray.count
        case 6:
            return 1
        case 7:
            return postsArray.count
        default:
            fatalError("Invalid Section")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard let mainPageData = mainData else {
            return cell
        }
        
        switch indexPath.section {
        
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
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityLineCell", for: indexPath)
            
            let index = indexPath.row
            
            let activityLine = activityLineCellsArray[index]
            
            setUpActivityLineCell(cell: cell, data: activityLine)
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postavshikiActivityCell", for: indexPath)
            
        case 5:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "activityPointCell", for: indexPath)
            
            let index = indexPath.row
            
            let activityPointCell = activityPointCellsArray[index]
            
            setUpActivityPointCell(cell: cell, data: activityPointCell)
            
        case 6:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
        case 7:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let index = indexPath.row
            
            let post = postsArray[index]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index, export: mainData?["export"])
            
        default:
            print("Invalid Section")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            return 126
        }else if indexPath.section == 7{
            
            return K.postHeight
            
        }else if indexPath.section == 0 || indexPath.section == 2 || indexPath.section == 4 || indexPath.section == 6{
            
            return K.simpleHeaderCellHeight
            
        }
        
        return K.simpleCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        if indexPath.section == 2{
            
            self.performSegue(withIdentifier: "goToActivityLines", sender: self)
            
        }else if indexPath.section == 3{
            
            let indexForCell = index
            
            let cellData = activityLineCellsArray[indexForCell]
            
            selectedLineId = cellData["line_id"].stringValue
            
            self.performSegue(withIdentifier: "goToLine", sender: self)
            
        }else if indexPath.section == 4{
            
            self.performSegue(withIdentifier: "goToActivityPoints", sender: self)
            
        }else if indexPath.section == 5{
            
            let indexForCell = index
            
            let cellData = activityPointCellsArray[indexForCell]
            
            selectedPointId = cellData["point_id"].stringValue
            
            self.performSegue(withIdentifier: "goToPoint", sender: self)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 7{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                mainPaggingDataManager.getMainPaggingData(key: key!, page: page)
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
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
    
    func setUpActivityPointCell(cell : UITableViewCell , data : JSON){
        
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
            
            GetPostActionsDataManager(delegate: self).getGetPostActionsData(key: key!, postId: postId)
            
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
            
            ExportPeersDataManager(delegate: self).getExportPeersData(key: key!)
            
        }
        
        if let export = export{
            
            let exportType = export["type"].stringValue
            
            cell.vigruzitImageView.image = exportType == "vk" ? UIImage(named: "vk") : UIImage(named: "odno")
            
        }
        
        cell.showDescription = false
        
        cell.postDescription = data["text"].stringValue == "" ?  nil : data["text"].stringValue
        
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

extension MainViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnImageCell(index: Int, images: [String]) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        vc.selectedImageIndex = index
        
        vc.images = images
        
        presentHero(vc, navigationAnimationType: .fade)
        
    }
    
    func didTapOnOptionCell(option: String) {
        
        searchTextField.text = option
        
        self.performSegue(withIdentifier: "goSearch", sender: self)
        
    }
    
}

//MARK: -  GetPostActionsDataManagerDelegate Stuff

extension MainViewController : GetPostActionsDataManagerDelegate{
    
    func didGetGetPostActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let actionsArray = data["actions"].arrayValue
            
            showActionsSheet(actionsArray: actionsArray) { (action) in
                
                let actionid = (action["id"].stringValue)
                
                SetPostActionsDataManager(delegate: self).getSetPostActionsData(key: key!, actionId: actionid, postId: selectedPostId)
                
            }
            
        }
        
    }
    
    func didFailGettingGetPostActionsDataWithError(error: String) {
        print("Error with  GetPostActionsDataManager : \(error)")
    }
    
}

//MARK: - SetPostActionsDataManagerDelegate

extension MainViewController : SetPostActionsDataManagerDelegate{
    
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

extension MainViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        mainData!["export"]["type"].stringValue = newType
                        
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

extension MainViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToLine"{
            
            let destinationVC = segue.destination as! LineViewController
            
            destinationVC.thisLineId = selectedLineId
            
        }else if segue.identifier == "goToPoint"{
            
            let destinationVC = segue.destination as! PointViewController
            
            destinationVC.thisPointId = selectedPointId
            
        }else if segue.identifier == "goSearch" {
            
            let destinationVC = segue.destination as! SearchViewController
            
            destinationVC.searchText = searchTextField.text!
            
            destinationVC.imageHashText = searchImageHash
            
        }else if segue.identifier == "goToVend"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
        }
        
    }
    
}
