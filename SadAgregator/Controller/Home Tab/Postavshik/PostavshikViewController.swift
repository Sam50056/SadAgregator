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
    
    var thisPeerId = ""
    
    var doneArray = [String]()
    
    var showTerms = false
    
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
        tableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "revCell")
        tableView.register(UINib(nibName: "RatingTableViewCellWithImages", bundle: nil), forCellReuseIdentifier: "revCellWithImages")
        
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
        return 11
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case 0:
            
            if vendorData?["alert_text"].stringValue != "" || vendorData?["altert_text"].stringValue != "" {
                return 1
            }else {
                return 0
            }
            
        case 1:
            
            return 1
            
        case 2:
            
            return vendorData?["terms"].stringValue != "" ? 1 : 0
            
        case 3:
            
            return showTerms ? 1 : 0
            
        case 4:
            
            return getInfoRowsCount()
            
        case 5:
            
            return 2
            
        case 6:
            
            return vendorRevs.count != 0 ? 1 : 0
                
            
        case 7:
            
            return vendorRevs.count < 3 ? vendorRevs.count : 3
            
        case 8:
            
            return postsArray.isEmpty ? 0 : 1
            
        case 9:
            
            return postsArray.count
            
        case 10:
            
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
            
            cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath)
            
            setUpAlertCell(cell: cell, data: vendorData)
        
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postavshikTopCell", for: indexPath)
            
            setUpPostavshikTopCell(cell: cell, data: vendorData)
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "uslCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel,
                  let imgView = cell.viewWithTag(2) as? UIImageView
            else {return cell}
            
            label.text = "Условия сотрудничества"
            
            label.font = UIFont.systemFont(ofSize: 18)
            
            imgView.image = UIImage(systemName: showTerms ? "chevron.up" : "chevron.down")
            
            cell.contentView.backgroundColor = .systemGray6
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath)
            
            guard let textView = cell.viewWithTag(1) as? UITextView else {return cell}
            
            cell.contentView.backgroundColor = .systemGray6
            
            textView.text = vendorData["terms"].string?.replacingOccurrences(of: "<br>", with: "\n")
            
            textView.font = UIFont.systemFont(ofSize: 17)
            
            textView.backgroundColor = .systemGray6
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            setUpInfoCell(cell: cell, data: vendorData, index: indexPath.row)
            
        case 5:
            
            if indexPath.row == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "rateVend", for: indexPath)
                
                setUpRateVend(cell: cell, data: vendorData)
                
            }else if indexPath.row == 1 {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "leaveARevCell", for: indexPath)
                
                setUpLeaveARevCell(cell: cell, data: vendorData)
                
            }
            
        case 6:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "revCountLabel", for: indexPath)
            
            setUpRevCountLabel(cell: cell)
            
        case 7:
            
            let rev = vendorRevs[indexPath.row]
            
            let imgs = rev["imgs"].arrayValue
            
            if imgs.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "revCell", for: indexPath)
                
                setUpRevCell(cell: cell as! RatingTableViewCell, data: rev)
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "revCellWithImages", for: indexPath)
                
                setUpRevCell(cell: cell as! RatingTableViewCellWithImages, data: rev)
                
            }
            
        case 8:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "lastPostsCell", for: indexPath)
            
        case 9:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let index = indexPath.row
            
            let post = postsArray[index]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index, export: vendorData["export"])
            
        case 10:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "allPostsCell", for: indexPath)
            
        default:
            print("Index Path Section out of switch : \(indexPath.section)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2{
            
            showTerms.toggle()
            
            tableView.reloadSections([2,3], with: .automatic)
            
        }else if indexPath.section == 5, indexPath.row == 1{
            
            if !isLogged{
                
                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                
            }else{
                
                self.performSegue(withIdentifier: "goToReviewUpdate", sender: self)
                
            }
            
        }else if indexPath.section == 6{
            
            if vendorRevs.count >= 3 {
                
                let vendorRevsVC = VendorBrokerRevsViewController()
                
                vendorRevsVC.thisVendId = thisVendorId
                
                navigationController?.pushViewController(vendorRevsVC, animated: true)
                
            }
            
        }else if indexPath.section == 8 || indexPath.section == 10{
            
            let vendorPostsVc = VendorPostsTableViewController()
            
            vendorPostsVc.thisVendId = thisVendorId
            
            self.navigationController?.pushViewController(vendorPostsVc, animated: true)
            
        }else if indexPath.section == 4{
            
            let selectedInfoCell = infoCells[indexPath.row]
            
            if selectedInfoCell.image == UIImage(named: "vk-3"){
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
            
            infoCells.append(InfoCellObject(image: UIImage(named: "vk-3")!, leftLabelText: leftLabelText, rightLabelText: vkLink, shouldRightLabelBeBlue: true))
            
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
            let revsCountString = data["revs_info"]["cnt"].stringValue
            let revsArray = data["revs_info"]["revs"].arrayValue
            let rev = revsArray.count
            
            if rev == 0{
                revLabel.text = ""
                revImageView.isHidden = true
            }else{
                revLabel.text = revsCountString
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
                
                if isLogged{
                    
                    RateUpdateDataManager().getRateUpdateData(key: key, vendId: thisVendorId!, rate: Int(rating))
                    
                }else{
                    
                    showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                    
                    ratingView.rating = userRating
                    
                }
                
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
        
        if let label = cell.viewWithTag(1) as? UILabel,
           let smVseLabel = cell.viewWithTag(2) as? UILabel,
           let smVseImageView = cell.viewWithTag(3) as? UIImageView{
            
            let revsCountString = vendorData!["revs_info"]["cnt"].stringValue
            let revsCount = Int(revsCountString)!
            
            var trailingText = ""
            
            if revsCountString.count == 2 && revsCountString[revsCountString.startIndex] == "1"{
                trailingText = "ОТЗЫВОВ"
            }else if revsCount % 10 == 1{
                trailingText = "ОТЗЫВ"
            }else if revsCount % 10 == 2 || revsCount % 10 == 3 || revsCount % 10 == 4{
                trailingText = "ОТЗЫВА"
            }else{
                trailingText = "ОТЗЫВОВ"
            }
            
            label.text = "\(revsCount) \(trailingText)"
            
            if vendorRevs.count >= 3{
                smVseLabel.isHidden = false
                smVseImageView.isHidden = false
            }else{
                smVseLabel.isHidden = true
                smVseImageView.isHidden = true
            }
            
        }
        
    }
    
    func setUpRevCell(cell : RatingTableViewCell, data : JSON){
        
        cell.authorLabel.text = data["author"].stringValue
        
        cell.ratingView.rating = Double(data["rate"].stringValue)!
        
        let rateText = data["text"].stringValue
        
        let rateTextWithoutBr = rateText.replacingOccurrences(of: "<br>", with: "\n")
        
        cell.textView.text = rateTextWithoutBr
        
        cell.dateLabel.text = data["dt"].stringValue
        
    }
    
    func setUpRevCell(cell : RatingTableViewCellWithImages, data : JSON){
        
        cell.authorLabel.text = data["author"].stringValue
        
        cell.ratingView.rating = Double(data["rate"].stringValue)!
        
        let rateText = data["text"].stringValue
        
        let rateTextWithoutBr = rateText.replacingOccurrences(of: "<br>", with: "\n")
        
        cell.textView.text = rateTextWithoutBr
        
        cell.dateLabel.text = data["dt"].stringValue
        
        let images =  data["imgs"].arrayValue.map({ jsonImage in
            return jsonImage.stringValue
        })
        
        cell.images = images
        
        cell.imageSelected = { [weak self] index in
            
            let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
            
            galleryVC.selectedImageIndex = index
            
            galleryVC.images = images.map({ img in
                PostImage(image: img, imageId: "")
            })
            
            galleryVC.sizes = []
            
            galleryVC.simplePreviewMode = true
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self?.presentHero(navVC, navigationAnimationType: .fade)
            
            
        }
        
    }
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int, export : JSON?){
        
        cell.key = key
        
        let postId = data["id"].stringValue
        
        cell.id = postId
        
        let like = data["like"].stringValue
        cell.like = like
        
        like == "0" ? (cell.likeButtonImageView.image = UIImage(systemName: "heart")) : (cell.likeButtonImageView.image = UIImage(systemName: "heart.fill"))
        
        cell.vkLinkUrlString = data["vk_post"].stringValue
        
        cell.didTapOnImageCell = { [weak self] index, images , sizes in
            
            let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
            
            galleryVC.selectedImageIndex = index
            
            galleryVC.images = images
            
            galleryVC.sizes = sizes
            
            galleryVC.key = self?.key ?? ""
            
            galleryVC.price = data["price"].stringValue
            
            galleryVC.point = data["vendor_capt"].stringValue
            
            galleryVC.forceClosed = { [weak self] in
                self?.tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: true)
            }
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self?.presentHero(navVC, navigationAnimationType: .fade)
            
        }
        
        cell.didTapOnOptionCell = { [weak self] option in
            
            self?.searchText = option
            
            self?.performSegue(withIdentifier: "goSearch", sender: self)
            
        }
        
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
            
            if vendorData!["export"]["fast"].intValue == 0{
                
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
                
                peerVC.setPeerCallback = { (newType , newPeerId) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        vendorData!["export"]["type"].stringValue = newType
                        
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

//MARK: - InfoCellObject

struct InfoCellObject {
    
    let image : UIImage
    let leftLabelText : String
    let rightLabelText : String
    let shouldRightLabelBeBlue : Bool
    
}
