//
//  BrokerCardViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.08.2021.
//

import UIKit
import SwiftyJSON
import Cosmos
import RealmSwift

class BrokerCardViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let realm = try! Realm()
    
    private var key = ""
    private var isLogged = false
    
    var thisBrokerId : String?
    
    private var likeBarButton: UIBarButtonItem!
    
    private var brokersBrokerCardDataManager = BrokersBrokerCardDataManager()
    private lazy var brokersBrokerLikeDataManager = BrokersBrokerLikeDataManager()
    private lazy var brokersBalanceAddRequestDataManager = BrokersBalanceAddRequestDataManager()
    private lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    private lazy var photoSavedDataManager = PhotoSavedDataManager()
    
    private var brokerData : JSON?
    
    private var balanceCellItems = [BalanceCellItem]()
    private var ratesArray = [UsloviaSotrItem]()
    private var parcelsArray = [UsloviaSotrItem]()
    private var payInfoArray = [UsloviaSotrItem]()
    private var defectsArray = [UsloviaSotrItem]()
    private var infoCells : [InfoCellObject] = []
    private var brokerRevs = [JSON]()
    private var brokerLikeStatus : String?
    
    private var checkImageUrl : URL?
    private var checkImageId : String?
    
    private var boxView = UIView()
    private var blurEffectView = UIVisualEffectView()
    
    private var showUsl = true
    
    private let activityController = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        brokersBrokerCardDataManager.delegate = self
        brokersBrokerLikeDataManager.delegate = self
        brokersBalanceAddRequestDataManager.delegate = self
        newPhotoPlaceDataManager.delegate = self
        
        likeBarButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(likeBarButtonPressed))
        
        tableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "revCell")
        tableView.register(UINib(nibName: "RatingTableViewCellWithImages", bundle: nil), forCellReuseIdentifier: "revCellWithImages")
        
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Посредник"
        
        navigationItem.rightBarButtonItems = [likeBarButton , UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoBarButtonPressed))]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refresh(nil)
        
    }
    
}

//MARK: - Actions

extension BrokerCardViewController {
    
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
    
    @IBAction func infoBarButtonPressed(){
        
        guard let thisBrokerId = thisBrokerId else {return}
        
        BrokersGetBrokerActionsDataManager().getBrokersGetBrokerActionsData(key : key , id : thisBrokerId){ data , error in
            
            if let error = error , data == nil {
                print("Error with BrokersGetBrokerActionsDataManager : \(error)")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                
                if data!["result"].intValue == 1{
                    
                    let actionsArray = data!["actions"].arrayValue
                    
                    self?.showActionsSheet(actionsArray: actionsArray) { (action) in
                        
                        let actionid = (action["id"].stringValue)
                        
                        BrokersSetBrokerActionsDataManager().getBrokersSetBrokerActionsDataManager(key : self!.key , brokerId : thisBrokerId , actionId: actionid){ data2 , error2 in
                            
                            if let error2 = error2 , data2 == nil{
                                print("Error with BrokersSetBrokerActionsDataManager : \(error2)")
                                return
                            }
                            
                            DispatchQueue.main.async {
                                
                                if data2!["result"].intValue == 1{
                                    
                                    self?.dismiss(animated: true, completion: nil)
                                    
                                    if let message = data2!["msg"].string{
                                        
                                        self?.showSimpleAlertWithOkButton(title: message, message: nil)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func balanceButonTapped(_ sender : UIButton){
        
        guard let buttonKey = sender.restorationIdentifier else {return}
        
        if buttonKey.contains("plus"){
            
            let alertController = UIAlertController(title: "Пополнить баланс?", message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                
                let firstAlertController = UIAlertController(title: "Прикрепить чек?", message: nil, preferredStyle: .alert)
                
                firstAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                    self?.showImagePickerController(sourceType: .photoLibrary)
                }))
                
                firstAlertController.addAction(UIAlertAction(title: "Нет", style: .default, handler: { [weak self] _ in
                    
                    let secondAlertController = UIAlertController(title: "Укажите сумму", message: nil, preferredStyle: .alert)
                    
                    secondAlertController.addTextField { textField in
                        textField.keyboardType = .numberPad
                    }
                    
                    secondAlertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [weak self] _ in
                        
                        guard let summ = secondAlertController.textFields![0].text , !summ.isEmpty else {return}
                        
                        self?.brokersBalanceAddRequestDataManager.getBrokersBalanceAddRequestData(key: self!.key, brokerId: self!.thisBrokerId!, summ: summ)
                        
                    }))
                    
                    self?.present(secondAlertController , animated: true)
                    
                }))
                
                self?.present(firstAlertController , animated: true , completion: nil)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            present(alertController , animated: true)
            
        }else{
            
            guard let brokerData = brokerData ,
                  let checks = brokerData["balance"]["checks"].arrayObject as? [String] ,
                  !checks.isEmpty
            else {return}
            
            previewImages(checks)
            
        }
        
    }
    
    func checkSent() {
        
        let alertController = UIAlertController(title: "Укажите сумму из чека", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [weak self] _ in
            
            guard let summ = alertController.textFields![0].text , !summ.isEmpty else {return}
            
            self?.brokersBalanceAddRequestDataManager.getBrokersBalanceAddRequestData(key: self!.key, brokerId: self!.thisBrokerId!, summ: summ , imgId: self?.checkImageId ?? "")
            
        }))
        
        present(alertController , animated: true)
        
    }
    
}

//MARK: - Functions

extension BrokerCardViewController{
    
    @objc func refresh(_ sender : Any?){
        
        guard let thisBrokerId = thisBrokerId else {return}
        
        showSimpleCircleAnimation(activityController: activityController)
        
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
            var rightLabelText = vkLink
            
            if vkLink.contains("-"){
                leftLabelText = "Группа"
                rightLabelText.removeFirst()
                rightLabelText.insert(contentsOf: "@club", at: rightLabelText.startIndex)
            }else{
                rightLabelText.insert(contentsOf: "@id", at: rightLabelText.startIndex)
            }
            
            infoCells.append(InfoCellObject(image: UIImage(named: "vk-3")!, leftLabelText: leftLabelText, rightLabelText: rightLabelText, shouldRightLabelBeBlue: true))
            
        }
        
        if let propusk = data["official_status"]["pass_dt"].string , propusk != ""{
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "text.badge.checkmark")!, leftLabelText: "Пропуск до", rightLabelText: propusk, shouldRightLabelBeBlue: data["official_status"]["img_card"].stringValue != ""))
            
        }
        
    }
    
    func makeBalanceArray(data : JSON){
        
        let balanceBlock = data["balance"]
        
        var newBalanceItems = [BalanceCellItem]()
        
        if var balance = balanceBlock["balance"].string , balance != "" , balance != "0"{
            
            balance = String(String(balance.reversed()).inserting(separator: " ", every: 3).reversed())
            
            newBalanceItems.append(BalanceCellItem(label1Text: "Ваш баланс", label2Text: balance + " руб.", image: "plus" , label2TextColor: balance.contains("-") ? .systemRed : .systemGreen))
        }
        
        if var waitBalance = balanceBlock["wait_balance"].string , waitBalance != "" , waitBalance != "0"{
            
            waitBalance = String(String(waitBalance.reversed()).inserting(separator: " ", every: 3).reversed())
            
            newBalanceItems.append(BalanceCellItem(label1Text: "В обработке", label2Text: waitBalance + " руб.", image: "newspaper.fill" , label2TextColor: #colorLiteral(red: 0.930277288, green: 0.6392800808, blue: 0.2036687732, alpha: 1)))
        }
        
        balanceCellItems = newBalanceItems
        
        tableView.reloadData()
        
    }
    
    func makeUslSotrArrays(data : JSON){
        
        let jsonRatesArray = data["rates"].arrayValue
        
        if !jsonRatesArray.isEmpty{
            var newRates = [UsloviaSotrItem]()
            newRates.append(UsloviaSotrItem(label1: "Выкуп", label2: ""))
            jsonRatesArray.forEach { jsonRate in
                newRates.append(UsloviaSotrItem(label1: jsonRate["capt"].stringValue, label2: jsonRate["marge"].stringValue))
            }
            ratesArray = newRates
        }
        
        let jsonParcelsArray = data["parcels"].arrayValue
        
        if !jsonParcelsArray.isEmpty{
            var newParcels = [UsloviaSotrItem]()
            newParcels.append(UsloviaSotrItem(label1: "Отправка", label2: ""))
            jsonParcelsArray.forEach { jsonParcel in
                newParcels.append(UsloviaSotrItem(label1: jsonParcel["name"].stringValue, label2: jsonParcel["price"].stringValue))
            }
            parcelsArray = newParcels
        }
        
        let defect = data["defect"]
        
        if defect["check"].stringValue != ""{
            var newDefects = [UsloviaSotrItem]()
            newDefects.append(UsloviaSotrItem(label1: "Проверка на брак", label2: ""))
            newDefects.append(UsloviaSotrItem(label1: "Услуга предоставляется", label2: defect["check"].stringValue == "1" ? "Да" : "Нет"))
            if let price = defect["price"].string , !price.isEmpty{
                newDefects.append(UsloviaSotrItem(label1: "Стоимость за 1 шт.", label2: price + " руб."))
            }
            defectsArray = newDefects
        }
        
        if var card = data["pay_info"]["card4"].string , !card.isEmpty{
            var newPayInfo = [UsloviaSotrItem]()
            newPayInfo.append(UsloviaSotrItem(label1: "Оплата", label2: ""))
            if card.count <= 4{
                card.insert(contentsOf: "**** ", at: card.startIndex)
            }
            newPayInfo.append(UsloviaSotrItem(label1: "Карта", label2: card))
            payInfoArray = newPayInfo
        }
        
        tableView.reloadData()
        
    }
    
    func showBoxView(with text : String) {
        
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        let width = text.width(withConstrainedHeight: UIScreen.main.bounds.width - 16, font: UIFont.systemFont(ofSize: 17)) + 60
        
        // You only need to adjust this frame to move it anywhere you want
        boxView = UIView(frame: CGRect(x: view.frame.midX - (width/2), y: view.frame.midY - 25, width: width, height: 50))
        boxView.backgroundColor = UIColor(named: "gray")
        boxView.alpha = 0.95
        boxView.layer.cornerRadius = 10
        
        boxView.center = view.center
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 45, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.gray
        textLabel.text = text
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
        
        view.isUserInteractionEnabled = false
        
    }
    
    func removeBoxView(){
        
        boxView.removeFromSuperview()
        blurEffectView.removeFromSuperview()
        view.isUserInteractionEnabled = true
        
    }
    
}

//MARK: - TableView

extension BrokerCardViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        15
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case 0:
            
            if brokerData?["alert_text"].stringValue != "" || brokerData?["altert_text"].stringValue != "" {
                return 1
            }else {
                return 0
            }
            
        case 1:
            
            return balanceCellItems.count
            
        case 2:
            
            return 1
            
        case 3:
            
            return 1
            
        case 4:
            
            return showUsl ? ratesArray.count : 0
            
        case 5:
            
            return showUsl ? parcelsArray.count : 0
            
        case 6:
            
            return showUsl ? defectsArray.count : 0
            
        case 7:
            
            return showUsl ?  payInfoArray.count : 0
            
        case 8:
            
            if showUsl , brokerData?["dop_info"].string != ""{
                return 1
            }else{
                return 0
            }
            
        case 9:
            
            return getInfoRowsCount()
            
        case 10:
            
            return 2
            
        case 11:
            
            return brokerRevs.count != 0 ? 1 : 0
            
        case 12:
            
            return brokerRevs.count < 3 ? brokerRevs.count : 3
            
        case 13:
            
            return brokerRevs.count >= 3 ? 1 : 0
            
        case 14:
            
            if brokerData?["alert_text"].stringValue != "" || brokerData?["altert_text"].stringValue != "" {
                return 1
            }else {
                return 0
            }
            
        default:
            fatalError("Invalid section")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard let brokerData = self.brokerData else {return cell}
        
        switch indexPath.section {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath)
            
            setUpAlertCell(cell: cell, data: brokerData)
        
        case 1:
            
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
            
            button.restorationIdentifier = item.image
            
            button.addTarget(self, action: #selector(balanceButonTapped(_:)), for: .touchUpInside)
            
            if item.image != "plus" , brokerData["balance"]["checks"].arrayValue.isEmpty{
                buttonView.isHidden = true
            }else{
                buttonView.isHidden = false
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "brokerTopCell", for: indexPath)
            
            setUpBrokerTopCell(cell: cell, data: brokerData)
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "uslCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel,
                  let imgView = cell.viewWithTag(2) as? UIImageView
            else {return cell}
            
            label.text = "Условия сотрудничества"
            
            label.font = UIFont.systemFont(ofSize: 18)
            
            imgView.image = UIImage(systemName: showUsl ? "chevron.up" : "chevron.down")
            
            cell.contentView.backgroundColor = .systemGray6
            
        case 3...7:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
            
            cell.contentView.backgroundColor = .systemGray6
            
            var item : UsloviaSotrItem!
            
            if indexPath.section == 4{
                item = ratesArray[indexPath.row]
            }else if indexPath.section == 5{
                item = parcelsArray[indexPath.row]
            }else if indexPath.section == 6{
                item = defectsArray[indexPath.row]
            }else if indexPath.section == 7{
                item = payInfoArray[indexPath.row]
            }
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let label2 = cell.viewWithTag(2) as? UILabel
            else {return cell}
            
            label1.text = item.label1
            label2.text = item.label2
            
            if item.label2.isEmpty{
                label1.font = UIFont.boldSystemFont(ofSize: 17)
                label1.textColor = UIColor(named: "blackwhite")
            }else{
                label1.font = UIFont.systemFont(ofSize: 15)
                label1.textColor = .systemGray
                label2.font = UIFont.boldSystemFont(ofSize: 15)
            }
            
        case 8:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "labelTextViewCell", for: indexPath)
            
            cell.contentView.backgroundColor = .systemGray6
            
            guard let label = cell.viewWithTag(1) as? UILabel ,
                  let textView = cell.viewWithTag(2) as? UITextView
            else {return cell}
            
            label.font = UIFont.boldSystemFont(ofSize: 17)
            
            textView.text = brokerData["dop_info"].stringValue.replacingOccurrences(of: "<br>", with: "\n")
            
            textView.backgroundColor = .systemGray6
            
        case 9:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            setUpInfoCell(cell: cell, data: brokerData, index: indexPath.row)
            
        case 10:
            
            if indexPath.row == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "rateBroker", for: indexPath)
                
                setUpRateBroker(cell: cell, data: brokerData)
                
            }else if indexPath.row == 1 {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "leaveARevCell", for: indexPath)
                
                setUpLeaveARevCell(cell: cell, data: brokerData)
                
            }
            
        case 11:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "revCountLabel", for: indexPath)
            
            setUpRevCountLabel(cell: cell)
            
        case 12:
            
            let rev = brokerRevs[indexPath.row]
            
            let imgs = rev["imgs"].arrayValue
            
            if imgs.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "revCell", for: indexPath)
                
                setUpRevCell(cell: cell as! RatingTableViewCell, data: rev)
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "revCellWithImages", for: indexPath)
                
                setUpRevCell(cell: cell as! RatingTableViewCellWithImages, data: rev)
                
            }
            
        case 13:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "oneLabelCell", for: indexPath)
            
        default:
            
            return cell
            
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            let item = balanceCellItems[indexPath.row]
            
            if item.label1Text == "Ваш баланс"{
                
                let paymentsHistoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentHistoryVC") as! PaymentHistoryViewController

                paymentsHistoryVC.thisBrokerId = thisBrokerId
                
                navigationController?.pushViewController(paymentsHistoryVC, animated: true)

                
            }
            
        }else if indexPath.section == 3{
            
            showUsl.toggle()
            
            tableView.reloadSections([4,5,6,7,8], with: .automatic)
            
        }else if indexPath.section == 10, indexPath.row == 1{
            
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
            
        }else if indexPath.section == 11 || indexPath.section == 13{
            
            if brokerRevs.count >= 3 {
                
                let brokerRevsVC = VendorBrokerRevsViewController()
                
                brokerRevsVC.key = key
                
                brokerRevsVC.thisBrokerId = brokerRevs[indexPath.row]["id"].string
                
                navigationController?.pushViewController(brokerRevsVC, animated: true)
                
            }
            
        }else if indexPath.section == 9{
            
            let selectedInfoCell = infoCells[indexPath.row]
            
            if selectedInfoCell.image == UIImage(named: "vk-3"){
                let urlString = "https://vk.com/@\(brokerData!["vk_link"].stringValue.contains("-") ? "club" : "id")\((brokerData!["vk_link"].stringValue.replacingOccurrences(of: "-", with: "")))"
                if let url = URL(string: urlString){
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                }
                
            }else if selectedInfoCell.image == UIImage(systemName: "phone.fill") {
                
                if let url = URL(string: "tel://\(brokerData!["phone"].stringValue)") {
                    
                    UIApplication.shared.open(url ,  options: [:], completionHandler: nil)
                    
                }
                
            }else if selectedInfoCell.image == UIImage(systemName: "text.badge.checkmark") , selectedInfoCell.shouldRightLabelBeBlue{
                
                previewImage(brokerData!["official_status"]["img_card"].stringValue)
                
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
        
        if let propusk = brokerData["official_status"]["pass_dt"].string , propusk != ""{
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
           let peoplesImageView = cell.viewWithTag(6) as? UIImageView,
           let peoplesLabel = cell.viewWithTag(7) as? UILabel,
           let revImageView = cell.viewWithTag(4) as? UIImageView,
           let revLabel = cell.viewWithTag(5) as? UILabel,
           let imageCountImageView = cell.viewWithTag(8) as? UIImageView,
           let imageCountLabel = cell.viewWithTag(9) as? UILabel,
           let ratingLabel = cell.viewWithTag(10) as? UILabel,
           let verifyImageView = cell.viewWithTag(11) as? UIImageView,
           let verifyImageViewButton = cell.viewWithTag(12) as? UIButton
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
            
            //Verify Image Stuff
            
            verifyImageView.isHidden = data["official_status"]["verify"].intValue == 0
            verifyImageViewButton.setTitle("", for: .normal)
            verifyImageViewButton.addAction(UIAction(handler: { [weak self] _ in
                if let imgLink = data["official_status"]["img_card"].string , !imgLink.isEmpty{
                    self?.previewImage(imgLink)
                }
            }), for: .touchUpInside)
            
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
            
            galleryVC.previewMode = .simple
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self?.presentHero(navVC, navigationAnimationType: .fade)
            
            
        }
        
    }
    
    func setUpAlertCell(cell : UITableViewCell, data: JSON){
        
        if let label = cell.viewWithTag(1) as? UILabel{
            
            label.text = data["alert_text"].stringValue.replacingOccurrences(of: "<br>", with: "\n")
            
        }
        
    }
    
}

//MARK: - Structs

extension BrokerCardViewController{
    
    private struct BalanceCellItem {
        
        var label1Text : String
        var label2Text : String
        
        var image : String
        
        var label2TextColor : UIColor = .black
        
    }
    
    private struct UsloviaSotrItem {
        
        var label1 : String
        var label2 : String
        
    }
    
}

//MARK: - UIImagePickerControllerDelegate

extension BrokerCardViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let safeUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            
            checkImageUrl = safeUrl
            showBoxView(with: "Загрузка фото чека")
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


//MARK: - NewPhotoPlaceDataManagerDelegate

extension BrokerCardViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let url = "\(data["post_to"].stringValue)/store?file_name=\(data["file_name"].stringValue)"
                
                print("URL FOR SENDING THE FILE: \(url)")
                
                guard let checkImageUrl = checkImageUrl else {return}
                
                sendFileToServer(from: checkImageUrl, to: url)
                
                let imageId = data["image_id"].stringValue
                
                let imageLinkWithPortAndWithoutFile = "\(data["post_to"].stringValue)"
                let splitIndex = imageLinkWithPortAndWithoutFile.lastIndex(of: ":")!
                let imageLink = "\(String(imageLinkWithPortAndWithoutFile[imageLinkWithPortAndWithoutFile.startIndex ..< splitIndex]))\(data["file_name"].stringValue)"
                
                print("Image Link: \(imageLink)")
                
                checkImageId = imageId
                
            }else{
                
                removeBoxView()
                
            }
            
        }
        
    }
    
    func didFailGettingNewPhotoPlaceDataWithError(error: String) {
        print("Error with NewPhotoPlaceDataManager: \(error)")
    }
    
}

//MARK: - File Sending

extension BrokerCardViewController{
    
    func sendFileToServer(from fromUrl : URL, to toUrl : String){
        
        print("import result : \(fromUrl)")
        
        guard let toUrl = URL(string: toUrl) else {return}
        
        print("To URL: \(toUrl)")
        
        do{
            
            let data = try Data(contentsOf: fromUrl)
            
            let image = UIImage(data: data)!
            
            let imageData = image.jpegData(compressionQuality: 0.5)
            
            var request = URLRequest(url: toUrl)
            
            request.httpMethod = "POST"
            request.setValue("text/plane", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
            
            let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
                
                if error != nil {
                    print("Error sending file: \(error!.localizedDescription)")
                    return
                }
                
                guard let data = data else {return}
                
                let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
                
                print("Answer : \(json)")
                
                DispatchQueue.main.async { [self] in
                    
                    print("Got check sent to server")
                    
                    photoSavedDataManager.getPhotoSavedData(key: key, photoId: checkImageId!) { data, error in
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        guard let data = data else {return}
                        
                        if data["result"].intValue == 1{
                            
                            print("Check image successfuly saved to server")
                            
                            DispatchQueue.main.async { [self] in
                                
                                removeBoxView()
                                
                                checkSent()
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
            task.resume()
            
        }catch{
            print(error)
        }
        
    }
    
}

//MARK: - BrokersBrokerCardDataManager

extension BrokerCardViewController : BrokersBrokerCardDataManagerDelegate{
    
    func didGetBrokersBrokerCardData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.stopSimpleCircleAnimation(activityController: self!.activityController)
                
                self?.brokerData = data
                
                self?.brokerRevs = data["revs_info"]["revs"].arrayValue
                
                self?.brokerLikeStatus = data["broker_like"].string
                
                self?.makeInfoArray(data: data)
                
                self?.makeBalanceArray(data: data)
                
                self?.makeUslSotrArrays(data: data)
                
                self?.setLikeBarButtonImage()
                
                self?.tableView.reloadData()
                
                //                self?.refreshControl?.endRefreshing()
                
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

extension BrokerCardViewController : BrokersBrokerLikeDataManagerDelegate{
    
    func didGetBrokersBrokerLikeData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.setLikeBarButtonImage()
            
        }
        
    }
    
    func didFailGettingBrokersBrokerLikeDataWithError(error: String) {
        print("Error with BrokersBrokerLikeDataManager : \(error)")
    }
    
}

//MARK: - BrokersBalanceAddRequestDataManager

extension BrokerCardViewController : BrokersBalanceAddRequestDataManagerDelegate{
    
    func didGetBrokersBalanceAddRequestData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.refresh(nil)
                
                self?.checkImageUrl = nil
                self?.checkImageId = nil
                
            }
            
        }
        
    }
    
    func didFailGettingBrokersBalanceAddRequestDataWithError(error: String) {
        print("Error with BrokersBalanceAddRequestDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension BrokerCardViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}
