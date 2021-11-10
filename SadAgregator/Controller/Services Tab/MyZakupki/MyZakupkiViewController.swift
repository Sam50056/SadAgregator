//
//  MyZakupkiViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.09.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift
import SwiftUI

class MyZakupkiViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let realm = try! Realm()
    
    private var purchasesFormPagingDataManager = PurchasesFormPagingDataManager()
    
    private var key = ""
    
    private var purchases = [ZakupkaTableViewCell.Zakupka]()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 7
    
    private var gruzImageUrl : URL?
    private var gruzImageId : String?
    
    private var posilkaImageUrl : URL?
    private var posilkaImageId : String?
    
    private var isSendingGruz = true
    private var imageSendingPur : ZakupkaTableViewCell.Zakupka?
    
    private var boxView = UIView()
    private var blurEffectView = UIVisualEffectView()
    
    private lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    private lazy var photoSavedDataManager = PhotoSavedDataManager()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        purchasesFormPagingDataManager.delegate = self
        
        tableView.register(UINib(nibName: "ZakupkaTableViewCell", bundle: nil), forCellReuseIdentifier: "purCell")
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        refresh()
        
        newPhotoPlaceDataManager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Мои закупки"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: nil) , UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: nil) , UIBarButtonItem(image: UIImage(systemName: "magnifyingglass" ) , style: .plain, target: self, action: nil)]
    }
    
}

//MARK: - Functions

extension MyZakupkiViewController {
    
    func update(){
        
        purchasesFormPagingDataManager.getPurchasesFormPagingData(key: key, page: page, status: "", query: "")
        
    }
    
    @objc func refresh(){
        
        page = 1
        
        rowForPaggingUpdate = 7
        
        update()
        
    }
    
    func showConfirmAlert(firstText : String, secondText : String , yesTapped : @escaping (() -> Void)){
        
        let confirmAlertController = UIAlertController(title: firstText, message: secondText, preferredStyle: .alert)
        
        confirmAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
            yesTapped()
        }))
        
        confirmAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(confirmAlertController, animated: true, completion: nil)
        
    }
    
    func action12(pur : ZakupkaTableViewCell.Zakupka){
        
        let summAlertController = UIAlertController(title: "Какую сумму оплатил клиент?", message: nil, preferredStyle: .alert)
        
        summAlertController.addTextField { field in
            field.keyboardType = .numberPad
        }
        
        summAlertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { [weak self] _ in
            
            guard let summ = summAlertController.textFields?[0].text else {return}
            
            let confirmSumAlertController = UIAlertController(title: "Зачислить \(summ) на счет клиента на закупку?", message: nil, preferredStyle: .alert)
            
            confirmSumAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                
                NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.BrokerPurchasePayed?Akey=\(self!.key)&APurID=\(pur.purId)&ASumm=\(summ)")) { data , error in
                    
                    DispatchQueue.main.async {
                        
                        if let error = error {
                            print("Error with BrokerPurchasePayed : \(error)")
                            return
                        }
                        
                        if let errorMessage = data!["msg"].string , !errorMessage.isEmpty{
                            self?.showSimpleAlertWithOkButton(title: errorMessage, message: nil)
                        }
                        
                    }
                    
                }
                
            }))
            
            confirmSumAlertController.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { _ in
                
                confirmSumAlertController.dismiss(animated: true, completion: nil)
                self?.action12(pur: pur)
                
            }))
            
            confirmSumAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            self?.present(confirmSumAlertController, animated: true, completion: nil)
            
        }))
        
        summAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(summAlertController, animated: true, completion: nil)
        
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
    
    func gruzSent(){
        
        guard let imageSendingPur = imageSendingPur , let gruzImageId = gruzImageId else {return}
        
        NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.UpdatePurDocImg?AKey=\(key)&APurSYSID=\(imageSendingPur.purId)&AImgTYPE=1&AimgID=\(gruzImageId)"))
        
        
    }
    
    func posilkaSent(){
        
        guard let imageSendingPur = imageSendingPur , let posilkaImageId = posilkaImageId else {return}
        
        NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.UpdatePurDocImg?AKey=\(key)&APurSYSID=\(imageSendingPur.purId)&AImgTYPE=2&AimgID=\(posilkaImageId)"))
        
    }
    
}

//MARK: - PurchasesFormPagingDataManager

extension MyZakupkiViewController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        purchases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "purCell", for: indexPath) as! ZakupkaTableViewCell
        
        let pur = purchases[indexPath.row]
        
        cell.thisPur = pur
        
        cell.purNameTapped = { [weak self] in
            
            let alertController = UIAlertController(title: "Название закупки", message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { [weak self] _ in
                
                guard let value = alertController.textFields?[0].text else {return}
                
                PurchasesUpdateInfoDataManager().getPurchasesUpdateInfoData(key: self!.key, purSysId: pur.purId, fieldId: "1", val: value) { data, error in
                    
                    if let error = error , data == nil {
                        print("Error with PurchasesUpdateInfoDataManager : \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        if data!["result"].intValue == 1{
                            
                            self?.purchases[indexPath.row].capt = value
                            self?.tableView.reloadData()
                            
                        }
                        
                    }
                    
                }
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            alertController.addTextField { field in
                field.text = pur.capt
                field.delegate = self
            }
            
            self?.present(alertController, animated: true, completion: nil)
            
        }
        
        cell.dateTapped = { [weak self] in
            
            let datePickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerViewController
            
            datePickerVC.modalPresentationStyle = .custom
            datePickerVC.transitioningDelegate = self
            
            datePickerVC.dateSelected = { date in
                
                let dateForRequest = self!.formatDate(date, withDot: false)
                let dateForUpdate = self!.formatDate(date, withDot: true)
                
                PurchasesUpdateInfoDataManager().getPurchasesUpdateInfoData(key: self!.key, purSysId: pur.purId, fieldId: "2", val: dateForRequest) { data, error in
                    
                    if let error = error , data == nil {
                        print("Error with PurchasesUpdateInfoDataManager : \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        if data!["result"].intValue == 1{
                            
                            self?.purchases[indexPath.row].dt = dateForUpdate
                            self?.tableView.reloadData()
                            
                        }
                        
                    }
                    
                }
                
            }
            
            self?.present(datePickerVC, animated: true, completion: nil)
            
        }
        
        cell.openTapped = { [weak self] type in
            if type == .tovars{
                self?.purchases[indexPath.row].openTovars.toggle()
            }else if type == .finance{
                self?.purchases[indexPath.row].openMoney.toggle()
            }else if type == .docs{
                self?.purchases[indexPath.row].openDocs.toggle()
            }
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.clientTapped = { [weak self] id in
            
            let clientsListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyZakupkiClientsList") as! MyZakupkiClientsListViewController
            
            clientsListVC.thisPur = pur.purId
            
            self?.navigationController?.pushViewController(clientsListVC, animated: true)
            
        }
        
        cell.tochkaTapped = { [weak self] in
            
            let sborkaView = SborkaView()
            
            let sborkaVC = UIHostingController(rootView: sborkaView)
            
            sborkaView.sborkaViewModel.thisPurId = pur.purId
            
            self?.navigationController?.pushViewController(sborkaVC, animated: true)
            
        }
        
        cell.handlerTapped = { [weak self] in
            
            let handlerType = pur.handlerType
            let handlerId = pur.handlerId
            
            if handlerType == "0"{
                //Посредник
                let brokerCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BrokerCardVC") as! BrokerCardViewController
                brokerCardVC.thisBrokerId = handlerId
                self?.navigationController?.pushViewController(brokerCardVC, animated: true)
            }else if handlerType == "1"{
                //"Поставщик"
                let vendorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VendorVC") as! PostavshikViewController
                vendorVC.thisVendorId = handlerId
                self?.navigationController?.pushViewController(vendorVC, animated: true)
            }else if handlerType == "2"{
                //"Клиент"
                let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                clientVC.thisClientId = handlerId
                self?.navigationController?.pushViewController(clientVC, animated: true)
            }
            
        }
        
        cell.rightSideButtonPressedForCell = { [weak self] cellInfo in
            
            if cellInfo == "tovars"{
                
                guard pur.countItems != "" , pur.countItems != "0" else {return}
                
                let sborkaView = SborkaView()
                
                sborkaView.sborkaViewModel.thisPurId = pur.purId
                
                let sborkaVC = UIHostingController(rootView: sborkaView)
                
                self?.navigationController?.pushViewController(sborkaVC, animated: true)
                
            }
            
        }
        
        cell.tovarsSubItemTapped = { [weak self] i in
            
            let item = pur.tovarsSubItems[i]
            
            var status = ""
            var navTitle = ""
            
            if item.label1 == "В ожидании:"{
                status = "0"
                navTitle = "В ожидании"
            }else if item.label1 == "Выкуплены:"{
                status = "1"
                navTitle = "Выкуплены"
            }else if item.label1 == "Нет в наличии:"{
                status = "2"
                navTitle = "Нет в наличии"
            }
            
            let prodsVC = ProdsByPurByStatusViewController()
            
            prodsVC.thisPurId = pur.purId
            prodsVC.status = status
            prodsVC.navTitle = navTitle
            
            self?.navigationController?.pushViewController(prodsVC, animated: true)
            
        }
        
        cell.documentImageTapped = { [weak self] i in
            self?.previewImages(pur.images.map({$0.image}) , selectedImageIndex: i)
        }
        
        cell.documentImageRemoveButtonTapped = { [weak self] i in
            let image = pur.images[i]
            PurchaseActionsDeletePurDocImgDataManager().getPurchaseActionsDeletePurDocImgData(key: self!.key, purSysId: pur.purId, imgId: image.id) { data, error in
                
                if let error = error , data == nil {
                    print("Error with PurchaseActionsDeletePurDocImgDataManager : \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if data!["result"].intValue == 1{
                        
                        self?.purchases[indexPath.row].images.remove(at: i)
                        self?.tableView.reloadData()
                        
                    }else{
                        
                        if let message = data!["msg"].string , !message.isEmpty{
                            self?.showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                        }
                        
                    }
                    
                }
                
            }
        }
        
        cell.footerPressed = { [weak self] in
            
            PurchaseActionsGetActionsDataManager().getPurchaseActionsGetActionsData(key: self!.key, purId: pur.purId) { actionsData, actionsError in
                
                if let error = actionsError , actionsData == nil {
                    print("Error with PurchaseActionsGetActionsDataManager : \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if actionsData!["result"].intValue == 1{
                        
                        let actionsArray = actionsData!["actions"].arrayValue
                        
                        self?.showActionsSheet(actionsArray: actionsArray) { action in
                            
                            let actionId = action["id"].stringValue
                            
                            if actionId == "1"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Зафиксировить закупку?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.PurFixed?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "2"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Вернуть закупку к редактированию?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.PurUnFixed?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "3"{
                                
                                let alertController = UIAlertController(title: "Подбор посредника", message: nil, preferredStyle: .actionSheet)
                                
                                alertController.addAction(UIAlertAction(title: "По коду партнера", style: .default, handler: { _ in
                                    
                                    let partnerCodeAlertController = UIAlertController(title: "Код партнера", message: nil, preferredStyle: .alert)
                                    
                                    partnerCodeAlertController.addTextField { field in
                                        field.placeholder = "Введите код партнера"
                                        field.keyboardType = .numberPad
                                    }
                                    
                                    partnerCodeAlertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ in
                                        
                                        guard let code = partnerCodeAlertController.textFields?[0].text else {return}
                                        
                                        PurchaseActionsCheckBrokerByCodeDataManager().getPurchaseActionsCheckBrokerByCodeData(key: self!.key, code: code) { data, error in
                                            
                                            DispatchQueue.main.async {
                                                
                                                if let error = error , data == nil {
                                                    print("Error with PurchaseActionsCheckBrokerByCodeDataManager : \(error)")
                                                    return
                                                }
                                                
                                                if data!["result"].intValue == 1{
                                                    
                                                    let finalAlertController = UIAlertController(title: "Передать закупку  помощнику \"\(data!["broker_name"].stringValue)\"?", message: nil, preferredStyle: .alert)
                                                    
                                                    finalAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                                        
                                                        PurchaseActionsMoveToBrokerDataManager().getPurchaseActionsMoveToBrokerData(key: self!.key, purId: pur.purId, brokerId: data!["broker_id"].stringValue) { moveToBrokerData, moveToBrokerError in
                                                            
                                                            DispatchQueue.main.async{
                                                                
                                                                if let moveToBrokerError = moveToBrokerError , moveToBrokerData == nil {
                                                                    print("Error with PurchaseActionsCheckBrokerByCodeDataManager : \(moveToBrokerError)")
                                                                    return
                                                                }
                                                                
                                                                if moveToBrokerData!["result"].intValue == 1{
                                                                    
                                                                    
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }))
                                                    
                                                    finalAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                    
                                                    self?.present(finalAlertController, animated: true, completion: nil)
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }))
                                    
                                    partnerCodeAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                                    
                                    self?.present(partnerCodeAlertController,animated: true , completion: nil)
                                    
                                }))
                                
                                alertController.addAction(UIAlertAction(title: "Из избранных", style: .default, handler: { _ in
                                    
                                    let favBrokersVC = FavoriteBrokersViewController()
                                    
                                    let navVC = UINavigationController(rootViewController: favBrokersVC)
                                    
                                    favBrokersVC.brokerSelected = { [weak self] brokerId , brokerName in
                                        
                                        navVC.dismiss(animated: true, completion: nil)
                                        
                                        let finalAlertController = UIAlertController(title: "Передать закупку помощнику \"\(brokerName)\"?", message: nil, preferredStyle: .alert)
                                        
                                        finalAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                            
                                            PurchaseActionsMoveToBrokerDataManager().getPurchaseActionsMoveToBrokerData(key: self!.key, purId: pur.purId, brokerId: brokerId) { moveToBrokerData, moveToBrokerError in
                                                
                                                DispatchQueue.main.async{
                                                    
                                                    if let moveToBrokerError = moveToBrokerError , moveToBrokerData == nil {
                                                        print("Error with PurchaseActionsCheckBrokerByCodeDataManager : \(moveToBrokerError)")
                                                        return
                                                    }
                                                    
                                                    if moveToBrokerData!["result"].intValue == 1{
                                                        
                                                        
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }))
                                        
                                        finalAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                        
                                        self?.present(finalAlertController, animated: true, completion: nil)
                                        
                                    }
                                    
                                    self?.present(navVC, animated: true, completion: nil)
                                    
                                }))
                                
                                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                                
                                self?.present(alertController , animated: true , completion: nil)
                                
                            }else if actionId == "4"{
                                
                                let confirmAlertController = UIAlertController(title: "Подтвердите действие", message: "Передать закупку поставщику?", preferredStyle: .alert)
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                    
                                    PurchaseActionsToSupplierDataManager().getPurchaseActionsToSupplierData(key: self!.key, purId: pur.purId) { data, error in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let error = error , data == nil {
                                                print("Error with PurchaseActionsToSupplierDataManager : \(error)")
                                                return
                                            }
                                            
                                            if data!["result"].intValue == 1{
                                                
                                                let alertController = UIAlertController(title: "Оставить поставщику комментарий по закупке?", message: nil, preferredStyle: .alert)
                                                
                                                alertController.addAction(UIAlertAction(title: "Да", style: .default , handler: { _ in
                                                    
                                                    let commentController = UIAlertController(title: "Комментарий по закупке", message: nil, preferredStyle: .alert)
                                                    
                                                    commentController.addTextField { field in
                                                        field.placeholder = "Ваш комментарий"
                                                    }
                                                    
                                                    commentController.addAction(UIAlertAction(title: "Отправить", style: .default, handler: { _ in
                                                        
                                                        guard let comment = commentController.textFields?[0].text else {return}
                                                        
                                                        PurchaseActionsSetForSupplierCommentDataManager().getPurchaseActionsSetForSupplierCommentData(key: self!.key, purSysId: pur.purId, comment: comment) { commentData, commentError in
                                                            
                                                            DispatchQueue.main.async {
                                                                
                                                                if let commentError = commentError , commentData == nil{
                                                                    print("Error with PurchaseActionsSetForSupplierCommentDataManager : \(commentError)")
                                                                    return
                                                                }
                                                                
                                                                if commentData!["result"].intValue == 1{
                                                                    
                                                                    
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }))
                                                    
                                                    commentController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                    
                                                    self?.present(commentController, animated: true, completion: nil)
                                                    
                                                }))
                                                
                                                alertController.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
                                                
                                                self?.present(alertController, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }))
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                
                                self?.present(confirmAlertController, animated: true, completion: nil)
                                
                            }else if actionId == "5"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Собирать закупку самостоятельно?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.RedeemYourself?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "6"{
                                
                                let alertController = UIAlertController(title: "Подтвердите действие", message: "Удалить закупку? Операция необратима", preferredStyle: .alert)
                                
                                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                    
                                    PurchaseActionsDeletePurchaseDataManager().getPurchaseActionsDeletePurchaseData(key: self!.key, purId: pur.purId, force: "0") { data, error in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let error = error , data == nil{
                                                print("Error with PurchaseActionsDeletePurchaseDataManager : \(error)")
                                                return
                                            }
                                            
                                            if data!["result"].intValue == 1{
                                                
                                                
                                                
                                            }else{
                                                
                                                if let errorMessage = data!["msg"].string , !errorMessage.isEmpty{
                                                    
                                                    let errorAlertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                                                    
                                                    errorAlertController.addAction(UIAlertAction(title: "Всё равно удалить", style: .default, handler: { _ in
                                                        
                                                        PurchaseActionsDeletePurchaseDataManager().getPurchaseActionsDeletePurchaseData(key: self!.key, purId: pur.purId, force: "1") { secondData, secondError in
                                                            
                                                            if let secondError = secondError {
                                                                print("Error with PurchaseActionsDeletePurchaseDataManager: \(secondError)")
                                                                return
                                                            }
                                                            
                                                        }
                                                        
                                                    }))
                                                    
                                                    errorAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                    
                                                    self?.present(errorAlertController, animated: true, completion: nil)
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }))
                                
                                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                
                                self?.present(alertController, animated: true, completion: nil)
                                
                            }else if actionId == "7"{
                                
                                let confirmAlertController = UIAlertController(title: "Подтвердите действие", message: "Разбить закупку по поставщикам", preferredStyle: .alert)
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                    
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.PurVendCount?AKey=\(self!.key)&APurID=\(pur.purId)")) { purVendCountData, purVendCountError in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let purVendCountError = purVendCountError , purVendCountData == nil{
                                                print("Error with PurVendCount : \(purVendCountError)")
                                                return
                                            }
                                            
                                            if purVendCountData!["result"].intValue == 1{
                                                
                                                let infoAlertController = UIAlertController(title: "Закупка будет разбита по поставщикам", message: "Будет создано \(purVendCountData!["cnt"].stringValue) шт закупок, продолжить? Операция необратима", preferredStyle: .alert)
                                                
                                                infoAlertController.addAction(UIAlertAction(title: "Продолжить", style: .default
                                                                                            , handler: { _ in
                                                    
                                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.BreakBySupply?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                                    
                                                }))
                                                
                                                infoAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                
                                                self?.present(infoAlertController, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }))
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                
                                self?.present(confirmAlertController, animated: true, completion: nil)
                                
                            }else if actionId == "8"{
                                
                                let confirmAlertController = UIAlertController(title: "Подтвердите действие?", message: "Обьеденить закупки?", preferredStyle: .alert)
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                    
                                    PurchaseActionsMergeablePurchasesDataManager().getPurchaseActionsMergeablePurchasesData(key: self!.key, purId: pur.purId) { mergeListData, mergeListError in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let mergeListError = mergeListError , mergeListData == nil{
                                                print("Error with PurchaseActionsMergeablePurchasesDataManager : \(mergeListError)")
                                                return
                                            }
                                            
                                            if mergeListData!["result"].intValue == 1{
                                                
                                                let simpleDataVC = SimpleDataTableViewController()
                                                
                                                let navVC = UINavigationController(rootViewController: simpleDataVC)
                                                
                                                simpleDataVC.array = mergeListData!["purs"].arrayValue.map({ mergeListJsonPur in
                                                    mergeListJsonPur["capt"].stringValue
                                                })
                                                
                                                simpleDataVC.navBarTitle = "Выбрать закупку"
                                                
                                                simpleDataVC.shouldShowNavBarButtons = true
                                                
                                                simpleDataVC.tableViewItemSelected = { index in
                                                    
                                                    navVC.dismiss(animated: true, completion: nil)
                                                    
                                                    let connectController = UIAlertController(title: "Соединить закупки \(mergeListData!["cur_pur_name"].stringValue) и \( mergeListData!["purs"].arrayValue[index]["capt"].stringValue)?", message: nil, preferredStyle: .alert)
                                                    
                                                    connectController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                                        
                                                        PurchaseActionsaCombinePurchasesDataManager().getPurchaseActionsaCombinePurchasesData(key: self!.key, mainPurId: pur.purId, subPurId: mergeListData!["purs"].arrayValue[index]["id"].stringValue) { finalData, finalError in
                                                            
                                                            DispatchQueue.main.async {
                                                                
                                                                if let finalError = finalError , finalData == nil{
                                                                    print("Error with PurchaseActionsaCombinePurchasesDataManager : \(finalError)")
                                                                    return
                                                                }
                                                                
                                                                if finalData!["result"].intValue == 1{
                                                                    
                                                                    
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }))
                                                    
                                                    connectController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                    
                                                    self?.present(connectController, animated: true, completion: nil)
                                                    
                                                }
                                                
                                                self?.present(navVC, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }))
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                
                                self?.present(confirmAlertController, animated: true, completion: nil)
                                
                            }else if actionId == "9"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Забрать закупку у посредника?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.RemoveFromBroker?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "10"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Принять закупку?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.BrokerAcceptPurchase?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "11"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Отклонить закупку?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.PurHandlerReject?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "12"{
                                
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Закупка оплачена?", yesTapped: {
                                    
                                    self?.action12(pur: pur)
                                    
                                })
                                
                            }else if actionId == "13"{
                                
                                let confirmAlertController = UIAlertController(title: "Подтвердите действие", message: "Начать обработку закупки?", preferredStyle: .alert)
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                    
                                    PurchaseActionsStartPurProcessingDataManager().getPurchaseActionsStartPurProcessingData(key: self!.key, purId: pur.purId, force: "0") { firstData, firstError in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let firstError = firstError , firstData == nil{
                                                print("Error with PurchaseActionsStartPurProcessingDataManager : \(firstError)")
                                                return
                                            }
                                            
                                            if let errorMessage = firstData!["msg"].string , !errorMessage.isEmpty{
                                                
                                                let errorAlertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                                                
                                                errorAlertController.addAction(UIAlertAction(title: "Взять в обработку", style: .default, handler: { _ in
                                                    
                                                    PurchaseActionsStartPurProcessingDataManager().getPurchaseActionsStartPurProcessingData(key: self!.key, purId: pur.purId, force: "1") { secondData, secondError in
                                                        
                                                        DispatchQueue.main.async {
                                                            
                                                            if let secondError = secondError , secondData == nil{
                                                                print("Error with PurchaseActionsStartPurProcessingDataManager : \(secondError)")
                                                                return
                                                            }
                                                            
                                                            if secondData!["result"].intValue == 1{
                                                                
                                                                
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }))
                                                
                                                errorAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                
                                                self?.present(errorAlertController, animated: true, completion: nil)
                                                
                                                return
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }))
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                
                                self?.present(confirmAlertController, animated: true, completion: nil)
                                
                            }else if actionId == "14"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Поставить закупку в сборку?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.PutInAssembly?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "15"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Убрать закупку из сборки?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.PopFromAssembly?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "16"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Остановить закупку?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.StopPur?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "17"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Забрать закупку у поставщика?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.RemoveFromSupplier?Akey=\(self!.key)&APurID=\(pur.purId)&AForce=0")) { removeData, removeError  in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let removeError = removeError , removeData == nil {
                                                print("Error with RemoveFromSupplier : \(removeError)")
                                                return
                                            }
                                            
                                            if removeData!["error"].intValue == 1{
                                                
                                            }else{
                                                
                                                if let removeDataErrorMessage = removeData!["msg"].string , !removeDataErrorMessage.isEmpty{
                                                    
                                                    let alertController = UIAlertController(title: removeDataErrorMessage, message: nil, preferredStyle: .alert)
                                                    
                                                    alertController.addAction(UIAlertAction(title: "Всё равно забрать", style: .default, handler: { _ in
                                                        
                                                        NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.RemoveFromSupplier?Akey=\(self!.key)&APurID=\(pur.purId)&AForce=1"))
                                                        
                                                    }))
                                                    
                                                    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                    
                                                    self?.present(alertController, animated: true, completion: nil)
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                })
                            }else if actionId == "18"{
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Убрать закупку из личной сборки?", yesTapped: {
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.RemoveFromYourself?AKey=\(self!.key)&APurID=\(pur.purId)"))
                                })
                            }else if actionId == "19"{
                                
                                NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.ToSupplierDropCheck?Akey=\(self!.key)&APurID=\(pur.purId)")) { toSupData, toSupError in
                                    
                                    DispatchQueue.main.async {
                                        
                                        if let toSupError = toSupError , toSupData == nil{
                                            print("Error with : \(toSupError)")
                                            return
                                        }
                                        
                                        if toSupData!["result"].intValue == 1{
                                            
                                            if let errorMessage = toSupData!["msg"].string , !errorMessage.isEmpty{
                                                
                                                let errorAlertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                                                
                                                errorAlertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
                                                
                                                errorAlertController.addAction(UIAlertAction(title: "Показать", style: .default, handler: { _ in
                                                    
                                                    let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                                                    clientVC.thisClientId = toSupData!["client_id"].stringValue
                                                    self?.navigationController?.pushViewController(clientVC, animated: true)
                                                    
                                                }))
                                                
                                                self?.present(errorAlertController, animated: true, completion: nil)
                                                
                                                return
                                                
                                            }
                                            
                                            let alertController = UIAlertController(title: "Дропшип закупки \(toSupData!["pur_name"].stringValue) на клиента ФИО «Иванова Петровна» в почтовое отделение \(toSupData!["client_index"].stringValue)? Проверьте ФИО и индекс, эти данные изменить будет нельзя.", message: nil, preferredStyle: .alert)
                                            
                                            alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                                
                                                NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.ToSupplierDropship?Akey=\(self!.key)&APurID=\(pur.purId)"))
                                                
                                            }))
                                            
                                            alertController.addAction(UIAlertAction(title: "Клиент", style: .default, handler: { _ in
                                                let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                                                clientVC.thisClientId = toSupData!["client_id"].stringValue
                                                self?.navigationController?.pushViewController(clientVC, animated: true)
                                            }))
                                            
                                            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                            
                                            self?.present(alertController, animated: true, completion: nil)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }else if actionId == "20"{
                                
                                let confirmAlertController = UIAlertController(title: "Подтвердите действие", message: "Передать закупку посреднику на дропшип?", preferredStyle: .alert)
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                    
                                    let alertController = UIAlertController(title: "Подбор посредника", message: nil, preferredStyle: .actionSheet)
                                    
                                    alertController.addAction(UIAlertAction(title: "По коду партнера", style: .default, handler: { _ in
                                        
                                        let partnerCodeAlertController = UIAlertController(title: "Код партнера", message: nil, preferredStyle: .alert)
                                        
                                        partnerCodeAlertController.addTextField { field in
                                            field.placeholder = "Введите код партнера"
                                            field.keyboardType = .numberPad
                                        }
                                        
                                        partnerCodeAlertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { _ in
                                            
                                            guard let code = partnerCodeAlertController.textFields?[0].text else {return}
                                            
                                            PurchaseActionsCheckBrokerByCodeDataManager().getPurchaseActionsCheckBrokerByCodeData(key: self!.key, code: code) { checkBrokerdata, checkBrokerError in
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    if let checkBrokerError = checkBrokerError , checkBrokerdata == nil {
                                                        print("Error with PurchaseActionsCheckBrokerByCodeDataManager : \(checkBrokerError)")
                                                        return
                                                    }
                                                    
                                                    if checkBrokerdata!["result"].intValue == 1{
                                                        
                                                        let finalAlertController = UIAlertController(title: "Передать дропшип  посреднику \"\(checkBrokerdata!["broker_name"].stringValue)\"?", message: nil, preferredStyle: .alert)
                                                        
                                                        finalAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                                            
                                                            NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.BrokerDropshipCheck?Akey=\(self!.key)&APurSYSID=\(pur.purId)&ABroker=\(checkBrokerdata!["broker_id"].stringValue)")) { brokerDropCheckData, brokerDropCheckError in
                                                                
                                                                DispatchQueue.main.async {
                                                                    
                                                                    if let brokerDropCheckError = brokerDropCheckError {
                                                                        print("Error with BrokerDropshipCheck : \(brokerDropCheckError)")
                                                                        return
                                                                    }
                                                                    
                                                                    if let brokerDropCheckDataErrorMessage = brokerDropCheckData!["msg"].string , !brokerDropCheckDataErrorMessage.isEmpty{
                                                                        
                                                                        let brokerDropCheckErrorAlertController = UIAlertController(title: brokerDropCheckDataErrorMessage, message: nil, preferredStyle: .alert)
                                                                        
                                                                        brokerDropCheckErrorAlertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
                                                                        
                                                                        brokerDropCheckErrorAlertController.addAction(UIAlertAction(title: "Показать", style: .default, handler: { _ in
                                                                            
                                                                            let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                                                                            clientVC.thisClientId = brokerDropCheckData!["client_id"].stringValue
                                                                            self?.navigationController?.pushViewController(clientVC, animated: true)
                                                                            
                                                                        }))
                                                                        
                                                                        self?.present(brokerDropCheckErrorAlertController, animated: true, completion: nil)
                                                                        
                                                                        return
                                                                        
                                                                    }
                                                                    let alertController = UIAlertController(title: "Дропшип закупки \(brokerDropCheckData!["pur_name"].stringValue) на клиента ФИО «\(brokerDropCheckData!["client_name"].stringValue)» в почтовое отделение \(brokerDropCheckData!["client_index"].stringValue)? Проверьте ФИО и индекс, эти данные изменить будет нельзя.", message: nil, preferredStyle: .alert)
                                                                    
                                                                    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                                    
                                                                    alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                                                        
                                                                        NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.MoveToBrokerDropship?Akey=\(self!.key)&APurSYSID=\(pur.purId)&ABroker=\(checkBrokerdata!["broker_id"].stringValue)"))
                                                                        
                                                                    }))
                                                                    
                                                                    alertController.addAction(UIAlertAction(title: "Клиент", style: .default, handler: { _ in
                                                                        let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                                                                        clientVC.thisClientId = brokerDropCheckData!["client_id"].stringValue
                                                                        self?.navigationController?.pushViewController(clientVC, animated: true)
                                                                    }))
                                                                    
                                                                    self?.present(alertController, animated: true, completion: nil)
                                                                    
                                                                }
                                                                
                                                            }
                                                            
                                                        }))
                                                        
                                                        finalAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                        
                                                        self?.present(finalAlertController, animated: true, completion: nil)
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }))
                                        
                                        partnerCodeAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                                        
                                        self?.present(partnerCodeAlertController,animated: true , completion: nil)
                                        
                                    }))
                                    
                                    alertController.addAction(UIAlertAction(title: "Из избранных", style: .default, handler: { _ in
                                        
                                        let favBrokersVC = FavoriteBrokersViewController()
                                        
                                        let navVC = UINavigationController(rootViewController: favBrokersVC)
                                        
                                        favBrokersVC.brokerSelected = { [weak self] brokerId , brokerName in
                                            
                                            navVC.dismiss(animated: true, completion: nil)
                                            
                                            let finalAlertController = UIAlertController(title: "Передать дропшип  посреднику \"\(brokerName)\"?", message: nil, preferredStyle: .alert)
                                            
                                            finalAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                                
                                                NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.BrokerDropshipCheck?Akey=\(self!.key)&APurSYSID=\(pur.purId)&ABroker=\(brokerId)")) { brokerDropCheckData, brokerDropCheckError in
                                                    
                                                    DispatchQueue.main.async {
                                                        
                                                        if let brokerDropCheckError = brokerDropCheckError {
                                                            print("Error with BrokerDropshipCheck : \(brokerDropCheckError)")
                                                            return
                                                        }
                                                        
                                                        if let brokerDropCheckDataErrorMessage = brokerDropCheckData!["msg"].string , !brokerDropCheckDataErrorMessage.isEmpty{
                                                            
                                                            let brokerDropCheckErrorAlertController = UIAlertController(title: brokerDropCheckDataErrorMessage, message: nil, preferredStyle: .alert)
                                                            
                                                            brokerDropCheckErrorAlertController.addAction(UIAlertAction(title: "Ок", style: .cancel, handler: nil))
                                                            
                                                            brokerDropCheckErrorAlertController.addAction(UIAlertAction(title: "Показать", style: .default, handler: { _ in
                                                                
                                                                let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                                                                clientVC.thisClientId = brokerDropCheckData!["client_id"].stringValue
                                                                self?.navigationController?.pushViewController(clientVC, animated: true)
                                                                
                                                            }))
                                                            
                                                            self?.present(brokerDropCheckErrorAlertController, animated: true, completion: nil)
                                                            
                                                            return
                                                            
                                                        }
                                                        let alertController = UIAlertController(title: "Дропшип закупки \(brokerDropCheckData!["pur_name"].stringValue) на клиента ФИО «\(brokerDropCheckData!["client_name"].stringValue)» в почтовое отделение \(brokerDropCheckData!["client_index"].stringValue)? Проверьте ФИО и индекс, эти данные изменить будет нельзя.", message: nil, preferredStyle: .alert)
                                                        
                                                        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                        
                                                        alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                                                            
                                                            NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.MoveToBrokerDropship?Akey=\(self!.key)&APurSYSID=\(pur.purId)&ABroker=\(brokerId)"))
                                                            
                                                        }))
                                                        
                                                        alertController.addAction(UIAlertAction(title: "Клиент", style: .default, handler: { _ in
                                                            let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                                                            clientVC.thisClientId = brokerDropCheckData!["client_id"].stringValue
                                                            self?.navigationController?.pushViewController(clientVC, animated: true)
                                                        }))
                                                        
                                                        self?.present(alertController, animated: true, completion: nil)
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }))
                                            
                                            finalAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                            
                                            self?.present(finalAlertController, animated: true, completion: nil)
                                            
                                        }
                                        
                                        self?.present(navVC, animated: true, completion: nil)
                                        
                                    }))
                                    
                                    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                                    
                                    self?.present(alertController , animated: true , completion: nil)
                                    
                                }))
                                
                                confirmAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                
                                self?.present(confirmAlertController, animated: true, completion: nil)
                                
                            }else if actionId == "21"{
                                
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Обновить фото груза?", yesTapped: {
                                    
                                    self?.isSendingGruz = true
                                    self?.imageSendingPur = pur
                                    self?.showImagePickerController(sourceType: .photoLibrary)
                                    
                                })
                                
                            }else if actionId == "22"{
                                
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Обновить фото посылки?", yesTapped: {
                                    
                                    self?.isSendingGruz = false
                                    self?.imageSendingPur = pur
                                    self?.showImagePickerController(sourceType: .photoLibrary)
                                    
                                })
                                
                            }else if actionId == "23"{
                                
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Отклонить закупку?") {
                                    
                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.HandlerRejectAndReturn?AKey=\(self!.key)&APurSYSID=\(pur.purId)&AForce=0")) { handlerRejectData , handlerRejectError in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let handlerRejectError = handlerRejectError{
                                                print("Error with HandlerRejectAndReturn : \(handlerRejectError)")
                                                return
                                            }
                                            
                                            if let errorMessage = handlerRejectData!["msg"].string , !errorMessage.isEmpty{
                                                
                                                let errorAlertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                                                
                                                errorAlertController.addAction(UIAlertAction(title: "Всё равно отклонить", style: .default, handler: { _ in
                                                    
                                                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.HandlerRejectAndReturn?AKey=\(self!.key)&APurSYSID=\(pur.purId)&AForce=1"))
                                                    
                                                }))
                                                
                                                errorAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                                
                                                self?.present(errorAlertController, animated: true, completion: nil)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }else if actionId == "24"{
                                
                                self?.showConfirmAlert(firstText: "Подтвердите действие", secondText: "Обновить трек номер посылки в закупке?", yesTapped: {
                                    
                                    let alertController = UIAlertController(title: "Обновить трек номер", message: nil, preferredStyle: .alert)
                                    
                                    alertController.addTextField { field in
                                        
                                    }
                                    
                                    alertController.addAction(UIAlertAction(title: "Обновить", style: .default, handler: { _ in
                                        
                                        guard let trackNum = alertController.textFields?[0].text else {return}
                                        
                                        guard trackNum.count <= 32 else {
                                            self?.showSimpleAlertWithOkButton(title: "Ошибка", message: "Максимум 32 символа")
                                            return
                                        }
                                        
                                        NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.UpdateTrack?AKey=\(self!.key)&APurSYSID=\(pur.purId)&ATrack=\(trackNum)")) { updateTrackData , updateTrackError in
                                            
                                            DispatchQueue.main.async {
                                                
                                                if let updateTrackError = updateTrackError {
                                                    print("Error with UpdateTrack : \(updateTrackError)")
                                                    return
                                                }
                                                
                                                if updateTrackData!["result"].intValue == 1{
                                                    
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        
                                    }))
                                    
                                    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                    
                                    self?.present(alertController, animated: true, completion: nil)
                                    
                                })
                                
                            }
                            
                        }
                        
                    }else{
                        
                        if let message = actionsData!["msg"].string , !message.isEmpty{
                            self?.showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        cell.tableView.reloadData()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let pur = purchases[indexPath.row]
        
        return K.makeHeightForZakupkaCell(data: pur)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 8
            
            update()
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - UITextField

extension MyZakupkiViewController : UITextFieldDelegate{
    
    //This is for zakupka capt changing (it has limited input types)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789YNn-_").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
}

//MARK: - TransitioningDelegate

extension MyZakupkiViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//MARK: - PurchasesFormPagingDataManagerDelegate

extension MyZakupkiViewController : PurchasesFormPagingDataManagerDelegate{
    
    func didGetPurchasesFormPagingData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                var newPurs = [ZakupkaTableViewCell.Zakupka]()
                
                data["purchaces"].arrayValue.forEach { purchaseData in
                    
                    var newMoneySubItems = [ZakupkaTableViewCell.TableViewItem]()
                    
                    purchaseData["money"].arrayValue.forEach { jsonMoneyItem in
                        newMoneySubItems.append(ZakupkaTableViewCell.TableViewItem(label1: jsonMoneyItem["capt"].stringValue, label2: "", label3: jsonMoneyItem["value"].stringValue + " руб."))
                    }
                    
                    var pur = ZakupkaTableViewCell.Zakupka(purId: purchaseData["pur_id"].stringValue, statusId: purchaseData["status_id"].stringValue, capt: purchaseData["capt"].stringValue, dt: purchaseData["dt"].stringValue, countItems: purchaseData["cnt_items"].stringValue, replaces: purchaseData["replaces"].stringValue, countClients: purchaseData["cnt_clients"].stringValue, countPoints: purchaseData["cnt_points"].stringValue, money: newMoneySubItems, clientId: purchaseData["client_id"].stringValue, handlerType: purchaseData["handler_type"].stringValue, handlerId: purchaseData["handler_id"].stringValue, handlerName: purchaseData["handler_name"].stringValue, actAv: purchaseData["act_ac"].stringValue, status: purchaseData["status"].stringValue, profit: purchaseData["profit"].stringValue, postageCost: purchaseData["postage_cost"].stringValue, itemsWait: purchaseData["items"]["wait"].stringValue, itemsWaitCost: purchaseData["items"]["wait_cost"].stringValue, itemsBought: purchaseData["items"]["bought"].stringValue, itemsBoughtCost: purchaseData["items"]["bought_cost"].stringValue, itemsNotAvailable: purchaseData["items"]["not_available"].stringValue, itemsNotAvailableCost: purchaseData["items"]["not_available_cost"].stringValue)
                    
                    var newImages = [ZakupkaTableViewCell.ImageItem]()
                    
                    purchaseData["images"].arrayValue.forEach { jsonImage in
                        newImages.append(ZakupkaTableViewCell.ImageItem(image: jsonImage["img"].stringValue, id: jsonImage["id"].stringValue))
                    }
                    
                    pur.images = newImages
                    
                    var newTovarsSubItems = [ZakupkaTableViewCell.TableViewItem]()
                    
                    if let wait = Int(pur.itemsWait) , wait >= 1{
                        newTovarsSubItems.append(ZakupkaTableViewCell.TableViewItem(label1: "В ожидании:", label2: pur.itemsWait, label3: pur.itemsWaitCost + " руб.", haveClickableLabel: true))
                    }
                    
                    if pur.itemsBought != "" , pur.itemsBought != "0"{
                        newTovarsSubItems.append(ZakupkaTableViewCell.TableViewItem(label1: "Выкуплено:", label2: pur.itemsBought, label3: pur.itemsBoughtCost + " руб.", haveClickableLabel: true))
                    }
                    
                    if pur.itemsNotAvailable != "" , pur.itemsNotAvailable != "0"{
                        newTovarsSubItems.append(ZakupkaTableViewCell.TableViewItem(label1: "Не выкуплено:", label2: pur.itemsNotAvailable, label3: pur.itemsNotAvailableCost + " руб.", haveClickableLabel: true))
                    }
                    
                    pur.tovarsSubItems = newTovarsSubItems
                    
                    newPurs.append(pur)
                    
                }
                
                self?.purchases.append(contentsOf: newPurs)
                
                self?.tableView.reloadData()
                
                self?.refreshControl.endRefreshing()
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesFormPagingDataWithError(error: String) {
        print("Error with PurchasesFormPagingDataManager : \(error)")
    }
    
}

//MARK: - UIImagePickerControllerDelegate

extension MyZakupkiViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let safeUrl = info[.imageURL] as? URL{
            
            isSendingGruz ? (gruzImageUrl = safeUrl) : (posilkaImageUrl = safeUrl)
            showBoxView(with: "Загрузка фото \(isSendingGruz ? "груза" : "посылки")")
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
        }
        
        //        print(info)
        
        dismiss(animated: true, completion: nil)
        
    }
    
}


//MARK: - NewPhotoPlaceDataManagerDelegate

extension MyZakupkiViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let url = "\(data["post_to"].stringValue)/store?file_name=\(data["file_name"].stringValue)"
                
                print("URL FOR SENDING THE FILE: \(url)")
                
                if isSendingGruz , let gruzImageUrl = gruzImageUrl {
                    sendFileToServer(from: gruzImageUrl, to: url)
                }else if !isSendingGruz , let posilkaImageUrl = posilkaImageUrl{
                    sendFileToServer(from: posilkaImageUrl, to: url)
                }
                
                let imageId = data["image_id"].stringValue
                
                let imageLinkWithPortAndWithoutFile = "\(data["post_to"].stringValue)"
                let splitIndex = imageLinkWithPortAndWithoutFile.lastIndex(of: ":")!
                let imageLink = "\(String(imageLinkWithPortAndWithoutFile[imageLinkWithPortAndWithoutFile.startIndex ..< splitIndex]))\(data["file_name"].stringValue)"
                
                print("Image Link: \(imageLink)")
                
                isSendingGruz ? (gruzImageId = imageId) : (posilkaImageId = imageId)
                
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

extension MyZakupkiViewController{
    
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
                    
                    print("Got \(isSendingGruz ? "gruz" : "posilka") sent to server")
                    
                    photoSavedDataManager.getPhotoSavedData(key: key, photoId: isSendingGruz ? gruzImageId! : posilkaImageId!) { data, error in
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        DispatchQueue.main.async { [weak self] in
                            
                            guard let data = data else {return}
                            
                            if data["result"].intValue == 1{
                                
                                print("\(isSendingGruz ? "Gruz" : "Posilka") image successfuly saved to server")
                                
                                self?.removeBoxView()
                                
                                isSendingGruz ? gruzSent() : posilkaSent()
                                
                            }else{
                                
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


//MARK: - Data Manipulation Methods

extension MyZakupkiViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
