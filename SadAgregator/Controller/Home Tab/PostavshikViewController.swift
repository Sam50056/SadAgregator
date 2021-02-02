//
//  PostavshikViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.12.2020.
//

import UIKit
import SwiftyJSON
import Cosmos
import SDWebImage
import RealmSwift
import Cosmos

class PostavshikViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var likeBarButton: UIBarButtonItem!
    
    let realm = try! Realm()
    
    var key = ""
    
    var isLogged = false
    
    var thisVendorId : String?
    
    lazy var vendorCardDataManager = VendorCardDataManager()
    lazy var vendorLikeDataManager = VendorLikeDataManager()
    lazy var reviewUpdateDataManager = ReviewUpdateDataManager()
    lazy var getVendActionsDataManager = GetVendActionsDataManager()
    
    var vendorData : JSON?
    
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
    
    var vendorPhone : String? {
        return vendorData?["phone"].stringValue
    }
    
    var vendorPlace : String? {
        return vendorData?["place"].stringValue
    }
    
    var vendorPop : String? {
        return vendorData?["pop"].stringValue
    }
    
    var vendorRegDate : String? {
        return vendorData?["reg_dt"].stringValue
    }
    
    var vendorVkLink : String?{
        return vendorData?["vk_link"].stringValue
    }
    
    var vendorLikeStatus : String?
    
    var vendorRevs = [JSON]()
    
    var postsArray = [JSON]()
    
    var infoCells : [InfoCellObject] = []
    
    var refreshControl = UIRefreshControl()
    
    let activityController = UIActivityIndicatorView()
    
    var selectedPostId = ""
    var selectedPointId = ""
    
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        vendorCardDataManager.delegate = self
        vendorLikeDataManager.delegate = self
        getVendActionsDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        if let safeId = thisVendorId{
            
            vendorCardDataManager.getVendorCardData(key: key, vendorId: safeId)
            
            showSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserData()
        
        refresh(self)
        
    }
    
    //MARK: - Actions
    
    @IBAction func likeBarButtonPressed(_ sender: UIBarButtonItem) {
        
        guard let thisVendId = thisVendorId , isLogged == true else {return}
        
        var newStatus = ""
        
        if vendorLikeStatus == "0"{
            newStatus = "1"
        }else if vendorLikeStatus == "1"{
            newStatus = "0"
        }else{
            print("Error. Wrong Like Status")
            return
        }
        
        vendorLikeDataManager.getVendorLikeData(key: key, vendId: thisVendId, status: newStatus)
        
        vendorLikeStatus = newStatus
        
    }
    
    @IBAction func helpBarButtonPressed(_ sender : UIBarButtonItem){
        
        guard let thisVendorId = thisVendorId else {return}
        
        getVendActionsDataManager.getGetVendActionsData(key: key, vendId: thisVendorId)
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToReviewUpdate"{
            
            let destinationVC = segue.destination as! ReviewUpdateViewController
            
            destinationVC.key = key
            destinationVC.vendId = thisVendorId
            destinationVC.myRate = Double(vendorData!["my_rate"].stringValue)!
            
        }else if segue.identifier == "goToPoint"{
            
            let destinationVC = segue.destination as! PointViewController
            
            destinationVC.thisPointId = selectedPointId
            
        }else if segue.identifier == "goSearch" {
            
            let destinationVC = segue.destination as! SearchViewController
            
            destinationVC.searchText = searchText
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension PostavshikViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - Refresh func

extension PostavshikViewController{
    
    @objc func refresh(_ sender: AnyObject) {
        
        if let safeId = thisVendorId{
            vendorCardDataManager.getVendorCardData(key: key, vendorId: safeId)
        }
        
    }
    
}

//MARK: - VendorCardDataManagerDelegate Stuff

extension PostavshikViewController : VendorCardDataManagerDelegate{
    
    func getVendorCardData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            vendorData = data
            
            postsArray = data["posts"].arrayValue
            
            vendorRevs = data["revs_info"]["revs"].arrayValue
            
            vendorLikeStatus = data["vend_like"].string
            
            setLikeBarButtonImage()
            
            tableView.reloadData()
            
            refreshControl.endRefreshing()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingVendorCardDataWithError(error: String) {
        print("Error with VendorCardDataManager: \(error)")
    }
    
    func setLikeBarButtonImage(){
        
        DispatchQueue.main.async{ [self] in
            
            if vendorLikeStatus == "1" {
                
                likeBarButton.image = UIImage(systemName: "heart.fill")
                
            }else {
                
                likeBarButton.image = UIImage(systemName: "heart")
                
            }
            
        }
        
    }
    
}

//MARK: - VendorLikeDataManagerDelegate Stuff

extension PostavshikViewController : VendorLikeDataManagerDelegate{
    
    func didGetVendorLikeData(data: JSON) {
        
        setLikeBarButtonImage()
        
    }
    
    func didFailGettingVendorLikeDataWithError(error: String) {
        print("Error with VendorLikeDataManager : \(error)")
    }
    
}

//MARK: - GetVendActionsDataManagerDelegate Stuff

extension PostavshikViewController : GetVendActionsDataManagerDelegate{
    
    func didGetGetVendActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let actionsArray = data["actions"].arrayValue
            
            showActionsSheet(actionsArray: actionsArray) { (action) in
                
                let actionid = (action["id"].stringValue)
                
                SetVendActionsDataManager(delegate: self).getSetVendActionsData(key: key, vendId: thisVendorId!, actionId: actionid)
                
            }
            
        }
        
    }
    
    func didFailGettingGetVendActionsData(error: String) {
        print("Error with GetVendActionsDataManager : \(error)")
    }
    
}

extension PostavshikViewController : SetVendActionsDataManagerDelegate{
    
    func didGetSetVendActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            dismiss(animated: true, completion: nil)
            
            if let message = data["msg"].string{
                
                showSimpleAlertWithOkButton(title: message, message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingSetVendActionsDataWithError(error: String) {
        print("Error with SetVendActionsDataManager : \(error)")
    }
    
}

//MARK: - UITableView Stuff

extension PostavshikViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case 0:
            
            return 1
            
        case 1:
            
            return getInfoRowsCount()
            
        case 2:
            
            return getRevRowsCount()
            
        case 3:
            
            return vendorRevs.count
            
        case 4:
            
            if vendorData?["alert_text"].stringValue != "" || vendorData?["altert_text"].stringValue != "" {
                return 1
            }else {
                return 0
            }
            
        case 5:
            
            return postsArray.isEmpty ? 0 : 1
            
        case 6:
            
            return postsArray.count
            
        case 7:
            
            return postsArray.isEmpty ? 0 : 1
            
        default:
            fatalError("Invalid section")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard let vendorData = self.vendorData else {return cell}
        
        switch indexPath.section {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postavshikTopCell", for: indexPath)
            
            setUpPostavshikTopCell(cell: cell, data: vendorData)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            setUpInfoCell(cell: cell, data: vendorData, index: indexPath.row)
            
        case 2:
            
            if indexPath.row == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "rateVend", for: indexPath)
                
                setUpRateVend(cell: cell, data: vendorData)
                
            }else if indexPath.row == 1 {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "leaveARevCell", for: indexPath)
                
                setUpLeaveARevCell(cell: cell, data: vendorData)
                
            }else if indexPath.row == 2{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "revCountLabel", for: indexPath)
                
                setUpRevCountLabel(cell: cell)
                
            }
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "revCell", for: indexPath)
            
            let rev = vendorRevs[indexPath.row]
            
            setUpRevCell(cell: cell, data: rev)
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath)
            
            setUpAlertCell(cell: cell, data: vendorData)
            
        case 5:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
        case 6:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let index = indexPath.row
            
            let post = postsArray[index]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index, export: vendorData["export"])
            
        case 7:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "allPostsCell", for: indexPath)
            
        default:
            print("Index Path Section out of switch : \(indexPath.section)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        
        case 0:
            
            return 92
            
        case 1:
            
            return 50
            
        case 2:
            
            return 50
            
        case 3:
            
            return 150
            
        case 4:
            
            return 50
            
        case 5:
            
            return 50
            
        case 6:
            
            return K.postHeight
            
        case 7:
            
            return 50
            
        default:
            fatalError("Invalid Section")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2, indexPath.row == 1{
            
            self.performSegue(withIdentifier: "goToReviewUpdate", sender: self)
            
        }else if indexPath.section == 5 || indexPath.section == 7{
            
            let vendorPostsVc = VendorPostsTableViewController()
            
            vendorPostsVc.thisVendId = thisVendorId
            
            self.navigationController?.pushViewController(vendorPostsVc, animated: true)
            
        }else if indexPath.section == 1{
            
            let selectedInfoCell = infoCells[indexPath.row]
            
            if selectedInfoCell.image == UIImage(named: "vk-2"){
                let urlString = "https://vk.com/\((vendorData!["vk_link"].stringValue).dropFirst())"
                if let url = URL(string: urlString){
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                }
                
            }else if selectedInfoCell.image == UIImage(systemName: "paperplane.fill"){
                
                selectedPointId = vendorData!["place_id"].stringValue
                
                self.performSegue(withIdentifier: "goToPoint", sender: self)
                
            }else if selectedInfoCell.image == UIImage(systemName: "phone.fill") {
                
                if let url = URL(string: "tel://\(vendorPhone!)") {
                    
                    UIApplication.shared.open(url ,  options: [:], completionHandler: nil)
                    
                }
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Row Count Stuff
    
    func getInfoRowsCount() -> Int{
        
        var count = 0
        
        guard let phone = vendorPhone , let pop = vendorPop, let place = vendorPlace , let regDate = vendorRegDate , let vkLink = vendorVkLink else {return count}
        
        if phone != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "phone.fill")!, leftLabelText: "Номер телефона", rightLabelText: phone, shouldRightLabelBeBlue: false))
            
        }
        
        if pop != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "person.2.fill")!, leftLabelText: "Охват", rightLabelText: pop, shouldRightLabelBeBlue: false))
            
        }
        
        if place != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "paperplane.fill")!, leftLabelText: "Контейнер", rightLabelText: place, shouldRightLabelBeBlue: true))
            
        }
        
        if regDate != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "calendar")!, leftLabelText: "Дата регистрации VK", rightLabelText: regDate, shouldRightLabelBeBlue: false))
            
        }
        
        if vkLink != "" {
            count += 1
            
            var leftLabelText = "Страница"
            
            if vkLink.contains("@club"){
                leftLabelText = "Группа"
            }
            
            infoCells.append(InfoCellObject(image: UIImage(named: "vk-2")!, leftLabelText: leftLabelText, rightLabelText: vkLink, shouldRightLabelBeBlue: true))
            
        }
        
        return count
    }
    
    func getRevRowsCount() -> Int{
        
        var count = 0
        
        if self.isLogged {
            
            count += 2 //Two cells (rateVend , leaveARevCell)
            
            if vendorRevs.count != 0{
                count += 1 // revCountCell should not be shown when there are no revs
            }
            
        }
        
        return count
    }
    
    //MARK: - Cells SetUp
    
    func setUpPostavshikTopCell(cell : UITableViewCell, data : JSON) {
        //   let revsCountLabel = cell.viewWithTag(4) as? UILabel
        if let imageView = cell.viewWithTag(1) as? UIImageView,
           let ratingView = cell.viewWithTag(3) as? CosmosView,
           let nameLabel = cell.viewWithTag(2) as? UILabel,
           let peoplesImageView = cell.viewWithTag(4) as? UIImageView,
           let peoplesLabel = cell.viewWithTag(5) as? UILabel,
           let revImageView = cell.viewWithTag(6) as? UIImageView,
           let revLabel = cell.viewWithTag(7) as? UILabel,
           let imageCountImageView = cell.viewWithTag(8) as? UIImageView,
           let imageCountLabel = cell.viewWithTag(9) as? UILabel,
           let ratingLabel = cell.viewWithTag(10) as? UILabel
        {
            
            //Set up the name
            nameLabel.text = data["name"].stringValue
            
            //Set up peoples label, imageView
            let peoples = data["peoples"].stringValue
            
            if peoples == "0"{
                peoplesLabel.text = ""
                peoplesImageView.isHidden = true
            }else{
                peoplesLabel.text = peoples
                peoplesImageView.isHidden = false
            }
            
            let imgsCount = data["revs_info"]["imgs_cnt"].stringValue
            
            if imgsCount == "0"{
                imageCountLabel.text = ""
                imageCountImageView.isHidden = true
            }else{
                imageCountLabel.text = imgsCount
                imageCountImageView.isHidden = false
            }
            
            //Set up revs
            let revsArray = data["revs_info"]["revs"].arrayValue
            let rev = revsArray.count
            
            if rev == 0{
                revLabel.text = ""
                revImageView.isHidden = true
            }else{
                revLabel.text = String(rev)
                revImageView.isHidden = false
            }
            
            //Set up image view
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
            imageView.sd_setImage(with: URL(string: data["img"].stringValue))
            
            //Set up the rating
            
            let ratingString = data["revs_info"]["rate"].stringValue
            
            guard let rating = Double(ratingString) else {return}
            
            if rating != 0 {
                ratingView.rating = rating
                ratingLabel.text = ratingString
            }else{
                
                if ratingView.tag != 1{
                    
                    ratingView.isHidden = true
                    
                    let label = UILabel(frame: ratingView.frame)
                    
                    cell.addSubview(label)
                    
                    label.font = .systemFont(ofSize: 14)
                    
                    label.text = "Отзывов ещё нет"
                    
                    ratingView.tag = 1 //I put tag 1 to know that the label is already shown and when cell is rerendered , label should not be added again , it's already in there , that's why there is a check for tag above ( if ratingView.tag != 1)
                    
                    ratingLabel.isHidden = true
                }
                
            }
            
        }
        
    }
    
    func setUpInfoCell(cell : UITableViewCell, data : JSON, index : Int){
        
        if let imageView = cell.viewWithTag(1) as? UIImageView,
           let leftLabel = cell.viewWithTag(2) as? UILabel ,
           let rightLabel = cell.viewWithTag(3) as? UILabel{
            
            let thisInfoCellObject = infoCells[index]
            
            imageView.image = thisInfoCellObject.image
            
            leftLabel.text = thisInfoCellObject.leftLabelText
            
            rightLabel.text = thisInfoCellObject.rightLabelText
            
            thisInfoCellObject.shouldRightLabelBeBlue ? (rightLabel.textColor = .systemBlue) : (rightLabel.textColor = #colorLiteral(red: 0.3666185141, green: 0.3666757345, blue: 0.3666060269, alpha: 1))
            
        }
        
    }
    
    func setUpAlertCell(cell : UITableViewCell, data: JSON){
        
        if let label = cell.viewWithTag(1) as? UILabel{
            
            label.text = data["alert_text"].stringValue != "" ? data["alert_text"].stringValue : data["altert_text"].stringValue
            
        }
        
    }
    
    func setUpRateVend(cell : UITableViewCell, data : JSON){
        
        if let ratingView = cell.viewWithTag(1) as? CosmosView,
           let userRating = Double(data["my_rate"].stringValue){
            
            ratingView.rating = userRating
            
            ratingView.didFinishTouchingCosmos = { [self] rating in
                
                RateUpdateDataManager().getRateUpdateData(key: key, vendId: thisVendorId!, rate: Int(rating))
                
            }
            
        }
        
    }
    
    func setUpLeaveARevCell(cell : UITableViewCell, data: JSON){
        
        if let label = cell.viewWithTag(1) as? UILabel,
           let userRating = Double(data["my_rate"].stringValue){
            
            label.text = userRating == 0 ? "ОСТАВИТЬ ОТЗЫВ" : "РЕДАКТИРОВАТЬ ОТЗЫВ"
            
        }
        
    }
    
    func setUpRevCountLabel(cell : UITableViewCell) {
        
        if let label = cell.viewWithTag(1) as? UILabel{
            
            let revsCount = vendorRevs.count
            
            var trailingText = ""
            
            if revsCount % 10 == 1{
                trailingText = "ОТЗЫВ"
            }else if revsCount % 10 == 2 || revsCount % 10 == 3 || revsCount % 10 == 4{
                trailingText = "ОТЗЫВА"
            }else{
                trailingText = "ОТЗЫВОВ"
            }
            
            label.text = "\(revsCount) \(trailingText)"
            
        }
        
    }
    
    func setUpRevCell(cell : UITableViewCell, data : JSON){
        
        if let authorLabel = cell.viewWithTag(1) as? UILabel,
           let ratingView = cell.viewWithTag(2) as? CosmosView,
           let textView = cell.viewWithTag(3) as? UITextView,
           let dateLabel = cell.viewWithTag(4) as? UILabel{
            
            authorLabel.text = data["author"].stringValue
            
            ratingView.rating = Double(data["rate"].stringValue)!
            
            let rateText = data["text"].stringValue
            
            let rateTextWithoutBr = rateText.replacingOccurrences(of: "<br>", with: "\n")
            
            textView.text = rateTextWithoutBr
            
            dateLabel.text = data["dt"].stringValue
            
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
            
            refresh(self)
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
        }
        
        cell.peerButtonCallback = { [self] in
            
            showSimpleCircleAnimation(activityController: activityController)
            
            ExportPeersDataManager(delegate: self).getExportPeersData(key: key)
            
        }
        
        cell.vigruzitButtonCallback = { [self] in
            
            if vendorData!["export"]["fast"].intValue == 0{
                
                let editVigruzkaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditVigruzkaVC") as! EditVigruzkaViewController
                
                editVigruzkaVC.thisPostId = selectedPostId
                
                present(editVigruzkaVC, animated: true, completion: nil)
                
            }else{
                
                ToExpQueueDataManager(delegate: self).getToExpQueueData(key: key, postId: selectedPostId)
                
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

extension PostavshikViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnOptionCell(option: String) {
        
        searchText = option
        
        performSegue(withIdentifier: "goSearch", sender: self)
        
    }
    
    func didTapOnImageCell(index: Int, images: [String]) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        vc.selectedImageIndex = index
        
        vc.images = images
        
        presentHero(vc, navigationAnimationType: .fade)
        
    }
    
}

//MARK: - GetPostActionsDataManagerDelegate Stuff

extension PostavshikViewController : GetPostActionsDataManagerDelegate{
    
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

extension PostavshikViewController : SetPostActionsDataManagerDelegate{
    
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

extension PostavshikViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            stopSimpleCircleAnimation(activityController: activityController)
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        vendorData!["export"]["type"].stringValue = newType
                        
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

//MARK: - ToExpQueueDataManagerDelegate

extension PostavshikViewController : ToExpQueueDataManagerDelegate{
    
    func didGetToExpQueueData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                print("ToExpQueueDataManager Request Sent")
                
            }else{
                
                showSimpleAlertWithOkButton(title: "Ошибка отправки запроса", message: nil, dismissButtonText: "Закрыть")
                
            }
            
        }
        
    }
    
    func didFailGettingToExpQueueDataWithError(error: String) {
        print("Error with ToExpQueueDataManager : \(error)")
    }
    
}


//MARK: - InfoCellObject

struct InfoCellObject {
    
    let image : UIImage
    let leftLabelText : String
    let rightLabelText : String
    let shouldRightLabelBeBlue : Bool
    
}
