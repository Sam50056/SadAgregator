//
//  BrokerCardTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.08.2021.
//

import UIKit
import SwiftyJSON
import Cosmos
import RealmSwift

class BrokerCardTableViewController: UITableViewController {
    
    private let realm = try! Realm()
    
    private var key = ""
    private var isLogged = false
    
    var thisBrokerId : String?
    
    private var likeBarButton: UIBarButtonItem!
    
    private var brokersBrokerCardDataManager = BrokersBrokerCardDataManager()
    private lazy var brokersBrokerLikeDataManager = BrokersBrokerLikeDataManager()
    
    private var brokerData : JSON?
    
    private var balanceCellItems = [BalanceCellItem]()
    private var infoCells : [InfoCellObject] = []
    private var brokerRevs = [JSON]()
    private var brokerLikeStatus : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        brokersBrokerCardDataManager.delegate = self
        brokersBrokerLikeDataManager.delegate = self
        
        likeBarButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(likeBarButtonPressed))
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Посредник"
        
        navigationItem.rightBarButtonItems = [likeBarButton]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserData()
        
        refresh(nil)
        
    }
    
}

//MARK: - Actions

extension BrokerCardTableViewController {
    
    @IBAction func likeBarButtonPressed() {
        
        guard let thisBrokerId = thisBrokerId , let _ = brokerData , isLogged == true else {return}
        
        var newStatus = ""
        
        let brokerLikeStatus = brokerLikeStatus
        
        if brokerLikeStatus == "0"{
            newStatus = "1"
        }else if brokerLikeStatus == "1"{
            newStatus = "0"
        }else{
            print("Error. Wrong Like Status")
            return
        }
        
        self.brokerLikeStatus = newStatus
        
        brokersBrokerLikeDataManager.getBrokersBrokerLikeData(key: key, brokerId: thisBrokerId, status: newStatus)
        
    }
    
}

//MARK: - Functions

extension BrokerCardTableViewController{
    
    @objc func refresh(_ sender : Any?){
        
        guard let thisBrokerId = thisBrokerId else {return}
        
        brokersBrokerCardDataManager.getBrokersBrokerCardData(key: key, id: thisBrokerId)
        
    }
    
    func setLikeBarButtonImage(){
        
        DispatchQueue.main.async{ [self] in
            
            if brokerLikeStatus == "1" {
                
                likeBarButton.image = UIImage(systemName: "heart.fill")
                
            }else {
                
                likeBarButton.image = UIImage(systemName: "heart")
                
            }
            
        }
        
    }
    
    func makeInfoArray(data : JSON) {
        
        if let phone = data["phone"].string , phone != "" {
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "phone.fill")!, leftLabelText: "Номер телефона", rightLabelText: phone, shouldRightLabelBeBlue: false))
            
        }
        
        if let regDate = data["reg_dt"].string , regDate != "" {
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "calendar")!, leftLabelText: "Дата регистрации VK", rightLabelText: regDate, shouldRightLabelBeBlue: false))
            
        }
        
        if let vkLink = data["vk_link"].string , vkLink != "" {
            
            var leftLabelText = "Страница"
            
            if vkLink.contains("@club"){
                leftLabelText = "Группа"
            }
            
            infoCells.append(InfoCellObject(image: UIImage(named: "vk-3")!, leftLabelText: leftLabelText, rightLabelText: vkLink, shouldRightLabelBeBlue: true))
            
        }
        
        
    }
    
    func makeBalanceArray(data : JSON){
        
        let balanceBlock = data["balance"]
        
        var newBalanceItems = [BalanceCellItem]()
        
        //        if let balance = balanceBlock["balance"].string , balance != ""{
        //            newBalanceItems.append(BalanceCellItem(label1Text: "Ваш баланс", label2Text: balance, image: "plus" , label2TextColor: balance.contains("-") ? .systemRed : .systemGreen))
        //        }
        //
        //        if let waitBalance = balanceBlock["wait_balance"].string , waitBalance != ""{
        //            newBalanceItems.append(BalanceCellItem(label1Text: "В обработке", label2Text: waitBalance, image: "person.fill" , label2TextColor: #colorLiteral(red: 0.930277288, green: 0.6392800808, blue: 0.2036687732, alpha: 1)))
        //        }
        
        newBalanceItems.append(BalanceCellItem(label1Text: "Ваш баланс", label2Text: "- 25 000,30 руб.", image: "plus" , label2TextColor: "".contains("-") ? .systemRed : .systemGreen))
        
        newBalanceItems.append(BalanceCellItem(label1Text: "В обработке", label2Text: "11 500,00 руб.", image: "person.fill" , label2TextColor: #colorLiteral(red: 0.930277288, green: 0.6392800808, blue: 0.2036687732, alpha: 1)))
        
        balanceCellItems = newBalanceItems
        
        tableView.reloadData()
        
    }
    
}

//MARK: - TableView

extension BrokerCardTableViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            
            return balanceCellItems.count
            
        case 1:
            
            return 1
        case 2:
            
            return getInfoRowsCount()
            
        case 3:
            
            return 2
            
        case 4:
            
            return brokerRevs.count != 0 ? 1 : 0
            
        case 5:
            
            return brokerRevs.count < 3 ? brokerRevs.count : 3
            
        case 6:
            
            if brokerData?["alert_text"].stringValue != "" || brokerData?["altert_text"].stringValue != "" {
                return 1
            }else {
                return 0
            }
            
        default:
            fatalError("Invalid section")
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard let brokerData = self.brokerData else {return cell}
        
        switch indexPath.section {
            
        case 0:
            
            let item = balanceCellItems[indexPath.row]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "balanceCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let label2 = cell.viewWithTag(2) as? UILabel ,
                  let buttonView = cell.viewWithTag(3),
                  let buttonImageView = cell.viewWithTag(4) as? UIImageView,
                  let button = cell.viewWithTag(5) as? UIButton
            else {return cell}
            
            label1.text = item.label1Text
            label2.text = item.label2Text
            
            label2.textColor = item.label2TextColor
            
            button.setTitle("", for: .normal)
            
            buttonView.layer.cornerRadius = buttonView.frame.width / 2
            
            buttonImageView.image = UIImage(systemName: item.image)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "brokerTopCell", for: indexPath)
            
            setUpBrokerTopCell(cell: cell, data: brokerData)
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            setUpInfoCell(cell: cell, data: brokerData, index: indexPath.row)
            
        case 3:
            
            if indexPath.row == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "rateBroker", for: indexPath)
                
                setUpRateBroker(cell: cell, data: brokerData)
                
            }else if indexPath.row == 1 {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "leaveARevCell", for: indexPath)
                
                setUpLeaveARevCell(cell: cell, data: brokerData)
                
            }
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "revCountLabel", for: indexPath)
            
            setUpRevCountLabel(cell: cell)
            
        case 5:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "revCell", for: indexPath)
            
            let rev = brokerRevs[indexPath.row]
            
            setUpRevCell(cell: cell, data: rev)
            
            //        case 5:
            //
            //            cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath)
            //
            //            setUpAlertCell(cell: cell, data: brokerData)
            //
        default:
            
            return cell
            
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3, indexPath.row == 1{
            
            if !isLogged{
                
                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                
            }else{
                
                let reviewUpdateVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReviewUpdateVC") as! ReviewUpdateViewController
                
                reviewUpdateVC.key = key
                reviewUpdateVC.vendId = nil
                reviewUpdateVC.brokerId = thisBrokerId
                reviewUpdateVC.myRate = Double(brokerData!["my_rate"].stringValue)!
                
                navigationController?.pushViewController(reviewUpdateVC, animated: true)
                
            }
            
        }else if indexPath.section == 4{
            
            //            if brokerRevs.count >= 3 {
            //
            //                let vendorRevsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VendorRevsVC") as! VendorRevsViewController
            //
            //                vendorRevsVC.thisVendId = thisVendorId
            //
            //                navigationController?.pushViewController(vendorRevsVC, animated: true)
            //
            //            }
            
        }else if indexPath.section == 2{
            
            let selectedInfoCell = infoCells[indexPath.row]
            
            if selectedInfoCell.image == UIImage(named: "vk-3"){
                let urlString = "https://vk.com/\((brokerData!["vk_link"].stringValue))"
                if let url = URL(string: urlString){
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                }
                
            }else if selectedInfoCell.image == UIImage(systemName: "phone.fill") {
                
                if let url = URL(string: "tel://\(brokerData!["phone"].stringValue)") {
                    
                    UIApplication.shared.open(url ,  options: [:], completionHandler: nil)
                    
                }
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Cells count
    
    func getInfoRowsCount() -> Int{
        
        guard let brokerData = brokerData else {return 0}
        
        var count = 0
        
        if let phone = brokerData["phone"].string , phone != "" {
            count += 1
        }
        
        if let regDate = brokerData["reg_dt"].string , regDate != "" {
            count += 1
        }
        
        if let vkLink = brokerData["vk_link"].string , vkLink != "" {
            count += 1
        }
        
        return count
    }
    
    //MARK: - Cells SetUp
    
    func setUpBrokerTopCell(cell : UITableViewCell, data : JSON) {
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
            
            let image = data["img"].stringValue
            
            if !image.isEmpty{
                imageView.layer.cornerRadius = imageView.frame.width / 2
                imageView.clipsToBounds = true
                imageView.sd_setImage(with: URL(string: image))
            }else{
                imageView.image = UIImage(systemName: "person")
            }
            
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
    
    func setUpRateBroker(cell : UITableViewCell, data : JSON){
        
        if let ratingView = cell.viewWithTag(1) as? CosmosView,
           let userRating = Double(data["my_rate"].stringValue){
            
            ratingView.rating = userRating
            
            ratingView.didFinishTouchingCosmos = { [self] rating in
                
                if isLogged{
                    
                    BrokersRateUpdateDataManager().getBrokersRateUpdateData(key: key, id: thisBrokerId!, newRate: String(format: "%.0f", rating)) { [weak self] data , error in
                        
                        DispatchQueue.main.async {
                            
                            if let error = error , data == nil{
                                print("Error with BrokersRateUpdateDataManager : \(error)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                self?.refresh(nil)
                                
                            }
                            
                        }
                        
                    }
                    
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
            
            let revsCountString = brokerData!["revs_info"]["cnt"].stringValue
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
            
            if brokerRevs.count >= 3{
                smVseLabel.isHidden = false
                smVseImageView.isHidden = false
            }else{
                smVseLabel.isHidden = true
                smVseImageView.isHidden = true
            }
            
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
    
    
}

//MARK: - Structs

extension BrokerCardTableViewController{
    
    private struct BalanceCellItem {
        
        var label1Text : String
        var label2Text : String
        
        var image : String
        
        var label2TextColor : UIColor = .black
        
    }
    
}

//MARK: - BrokersBrokerCardDataManager

extension BrokerCardTableViewController : BrokersBrokerCardDataManagerDelegate{
    
    func didGetBrokersBrokerCardData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.brokerData = data
                
                self?.brokerRevs = data["revs_info"]["revs"].arrayValue
                
                self?.brokerLikeStatus = data["broker_like"].string
                
                self?.makeInfoArray(data: data)
                
                self?.makeBalanceArray(data: data)
                
                self?.setLikeBarButtonImage()
                
                self?.tableView.reloadData()
                
                self?.refreshControl?.endRefreshing()
                
                //                stopSimpleCircleAnimation(activityController: activityController)
                
            }else{
                
                
            }
            
        }
        
    }
    
    func didFailGettingBrokersBrokerCardDataWithError(error: String) {
        print("Error with BrokersBrokerCardDataManager : \(error)")
    }
    
}

//MARK: - BrokersBrokerLikeDataManager

extension BrokerCardTableViewController : BrokersBrokerLikeDataManagerDelegate{
    
    func didGetBrokersBrokerLikeData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.setLikeBarButtonImage()
            
        }
        
    }
    
    func didFailGettingBrokersBrokerLikeDataWithError(error: String) {
        print("Error with BrokersBrokerLikeDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension BrokerCardTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}
