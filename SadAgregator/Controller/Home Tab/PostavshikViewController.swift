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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        vendorCardDataManager.delegate = self
        vendorLikeDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        if let safeId = thisVendorId{
            vendorCardDataManager.getVendorCardData(key: key, vendorId: safeId)
        }
        
    }
    
    
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
    
}

//MARK: - Data Manipulation Methods

extension PostavshikViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
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

//MARK: - UITableView Stuff

extension PostavshikViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
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
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: index)
            
            
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
            
            
        default:
            fatalError("Invalid Section")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            
            infoCells.append(InfoCellObject(image: UIImage(named: "vk-2")!, leftLabelText: "Страница", rightLabelText: vkLink, shouldRightLabelBeBlue: true))
            
        }
        
        return count
    }
    
    func getRevRowsCount() -> Int{
        
        var count = 0
        
        if self.isLogged {
            
            count += 3 //Three cells (rateVend , leaveARevCell and revCountCell)
            
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
           let imageCountLabel = cell.viewWithTag(9) as? UILabel
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
            
            let rating = Double(data["revs_info"]["rate"].stringValue)!
            
            if rating != 0 {
                ratingView.rating = rating
            }else{
                
                if ratingView.tag != 1{
                    
                    ratingView.isHidden = true
                    
                    let label = UILabel(frame: ratingView.frame)
                    
                    cell.addSubview(label)
                    
                    label.font = .systemFont(ofSize: 14)
                    
                    label.text = "Отзывов ещё нет"
                    
                    ratingView.tag = 1 //I put tag 1 to know that the label is already shown and when cell is rerendered , label should not be added again , it's already in there , that's why there is a check for tag above ( if ratingView.tag != 1)
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
            
        }
        
    }
    
    func setUpRevCountLabel(cell : UITableViewCell) {
        
        if let label = cell.viewWithTag(1) as? UILabel{
            
            let revsCount = vendorRevs.count
            
            var trailingText = ""
            
            if revsCount % 10 == 1{
                trailingText = "ОТЗЫВ"
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
            
            textView.text = data["text"].stringValue
            
            dateLabel.text = data["dt"].stringValue
            
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
        
        isLogged ? (cell.likeButtonImageView.isHidden = false) : (cell.likeButtonImageView.isHidden = true)
        
    }
    
}

//MARK: - InfoCellObject

struct InfoCellObject {
    
    let image : UIImage
    let leftLabelText : String
    let rightLabelText : String
    let shouldRightLabelBeBlue : Bool
    
}
