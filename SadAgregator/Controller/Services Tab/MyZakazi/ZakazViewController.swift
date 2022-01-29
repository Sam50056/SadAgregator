//
//  ZakazViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.12.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ZakazViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    private var zakazData : JSON?
    private var thisZakaz : ZakazTableViewCell.Zakaz?
    var thisZakazId = ""
    
    private var purProds = [TovarCellItem]()
    private var docs = [JSON](){
        didSet{
            
            for doc in docs{
                
                if doc["type"].stringValue == "1"{
                    parcelDoc = doc
                }else if doc["type"].stringValue == "2"{
                    trackDoc = doc
                }
                
            }
            
        }
    }
    
    private var parcelDoc : JSON?
    private var trackDoc : JSON?
    
    private var vendTargetOrderDataManager = VendTargetOrderDataManager()
    
    private var gruzImageUrl : URL?
    private var gruzImageId : String?
    private var gruzImage : UIImage?
    
    private var posilkaImageUrl : URL?
    private var posilkaImageId : String?
    private var posilkaImage : UIImage?
    
    private var sendingDocType : DocType?
    
    private var boxView = UIView()
    private var blurEffectView = UIVisualEffectView()
    
    private lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    private lazy var photoSavedDataManager = PhotoSavedDataManager()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ZakazTableViewCell", bundle: nil), forCellReuseIdentifier: "zakazCell")
        tableView.register(UINib(nibName: "TovarTableViewCell", bundle: nil), forCellReuseIdentifier: "tovarCell")
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        vendTargetOrderDataManager.delegate = self
        newPhotoPlaceDataManager.delegate = self
        
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
}

//MARK: - Enums

extension ZakazViewController {
    
    private enum DocType: Int {
        case gruz , posilka
    }
    
}

//MARK: - Actions

extension ZakazViewController{
    
    
    
}

//MARK: - Functions

extension ZakazViewController{
    
    @objc func refresh(){
        
        guard thisZakazId != "" else {return}
        
        thisZakaz = nil
        purProds.removeAll()
        docs.removeAll()
        parcelDoc = nil
        trackDoc = nil
        
        vendTargetOrderDataManager.getVendTargetOrderData(key: key, order: thisZakazId)
        
    }
    
    func update(){
        
        guard thisZakazId != "" else {return}
        
        NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_vend.TargetOrderProdsPage?AKey=\(key)&AOrder=\(thisZakazId)&APage=\(page)") { [weak self] data, error in
            
            DispatchQueue.main.async {
                
                if let error = error{
                    print("Error with Target Order Prods Page : \(error)")
                    return
                }
                
                if let errorText = data!["msg"].string , errorText != ""{
                    self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorText)
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    var newProds = [TovarCellItem]()
                    
                    data!["prods"].arrayValue.forEach { purProd in
                        
                        var tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue , itemStatus : purProd["item_status"].stringValue , handlerStatus : purProd["handler_status"].stringValue)
                        
                        guard let thisZakaz = self?.thisZakaz else {return}
                        
                        if let intStatus = Int(thisZakaz.status) , intStatus >= 3{
                            tovar.shouldShowBottomStackView = false
                        }
                        
                        if tovar.qr == "1"{ //If qr is connected , no bottom bar should be shown
                            tovar.shouldShowBottomStackView = false
                        }
                        
                        newProds.append(tovar)
                        
                    }
                    
                    self?.purProds = newProds
                    
                    self?.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    func statusChange(actId : String){
        
        if actId == "1"{
            NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchase_actions.SupplierAcceptOrder?AKey=\(key)&APurSYSID=\(thisZakazId)") { [weak self] acceptOrderData, acceptOrderError in
                
                DispatchQueue.main.async {
                    
                    if let acceptOrderError = acceptOrderError{
                        print("Error with Supplier Accept Order : \(acceptOrderError)")
                        return
                    }
                    
                    if acceptOrderData!["result"].intValue == 1{
                        
                        self?.refresh()
                        
                    }else{
                        
                        if let errorMessage = acceptOrderData!["msg"].string , errorMessage != ""{
                            
                            self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorMessage)
                            
                        }
                        
                    }
                    
                }
                
            }
        }else if actId == "2"{
            
            let questionAlertController = UIAlertController(title: "Отклонить заказ?", message: nil, preferredStyle: .alert)
            
            questionAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchase_actions.SupplierRejectOrder?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)") { rejectOrderData, rejectOrderError in
                    
                    DispatchQueue.main.async {
                        
                        if let acceptOrderError = rejectOrderError{
                            print("Error with Supplier Reject Order : \(acceptOrderError)")
                            return
                        }
                        
                        if rejectOrderData!["result"].intValue == 1{
                            
                            self?.refresh()
                            
                        }else{
                            
                            if let errorMessage = rejectOrderData!["msg"].string , errorMessage != ""{
                                
                                questionAlertController.dismiss(animated: true, completion: nil)
                                self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorMessage)
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }))
            
            questionAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            present(questionAlertController, animated: true)
            
        }else if actId == "3"{
            
            let summAlertController = UIAlertController(title: "Какую сумму оплатил клиент?", message: nil, preferredStyle: .alert)
            
            summAlertController.addAction(UIAlertAction(title: "Ок", style: .default, handler: { [weak self] _ in
                
                guard let summ = summAlertController.textFields?[0].text else {return}
                
                let finalAlertController = UIAlertController(title: "Зачислить \(summ) на счет заказа?", message: nil, preferredStyle: .alert)
                
                finalAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                    NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchase_actions.SupplierPayedOrder?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)&ASumm=\(summ)") { payedData , payedError in
                        
                        if let payedError = payedError{
                            print("Error with Supplier Payed Order : \(payedError)")
                            return
                        }
                        
                        if payedData!["result"].intValue == 1{
                            
                            self?.refresh()
                            
                        }else{
                            
                            if let errorMessage = payedData!["msg"].string , errorMessage != ""{
                                
                                finalAlertController.dismiss(animated: true, completion: nil)
                                self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorMessage)
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                finalAlertController.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { _ in
                    finalAlertController.dismiss(animated: true, completion: nil)
                    self?.statusChange(actId: actId)
                }))
                
                finalAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self?.present(finalAlertController, animated: true , completion : nil)
                
            }))
            
            summAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            summAlertController.addTextField { textField in
                textField.keyboardType = .numberPad
            }
            
            present(summAlertController, animated: true, completion: nil)
            
        }else if actId == "4"{
            
            let questionAlertController = UIAlertController(title: "Заказ собран?", message: nil, preferredStyle: .alert)
            
            questionAlertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                
                NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchase_actions.SupplierReadyOrder?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)") { [weak self] readyData, readyError in
                    
                    DispatchQueue.main.async {
                        
                        if let readyError = readyError{
                            print("Error with Supplier Ready Order : \(readyError)")
                            return
                        }
                        
                        if readyData!["result"].intValue == 1{
                            
                            self?.refresh()
                            
                        }else{
                            
                            if let errorMessage = readyData!["msg"].string , errorMessage != ""{
                                
                                questionAlertController.dismiss(animated: true, completion: nil)
                                self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorMessage)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }))
            
            questionAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            present(questionAlertController, animated: true, completion: nil)
            
        }
        
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
        
        DispatchQueue.main.async { [weak self] in
            
            self?.boxView.removeFromSuperview()
            self?.blurEffectView.removeFromSuperview()
            self?.view.isUserInteractionEnabled = true
            
        }
        
    }
    
    func getImage(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Сделать снимок", style: .default, handler: { [weak self] _ in
            self?.showImagePickerController(sourceType: .camera)
        }))
        
        alertController.addAction(UIAlertAction(title: "Из галереи", style: .default, handler: { [weak self] _ in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(alertController , animated: true)
        
    }
    
    func gruzSent(){
        
        guard let gruzImageId = gruzImageId else {return}
        
        NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.UpdatePurDocImg?AKey=\(key)&APurSYSID=\(thisZakazId)&AImgTYPE=1&AimgID=\(gruzImageId)")) { [weak self] updateDocData , _ in
            guard let updateDocData = updateDocData else {return}
            if updateDocData["result"].intValue == 1{
                self?.refresh()
            }
        }
        
        
    }
    
    func posilkaSent(){
        
        guard let posilkaImageId = posilkaImageId else {return}
        
        NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_purchase_actions.UpdatePurDocImg?AKey=\(key)&APurSYSID=\(thisZakazId)&AImgTYPE=2&AimgID=\(posilkaImageId)")) { [weak self] updateDocData , _ in
            guard let updateDocData = updateDocData else {return}
            if updateDocData["result"].intValue == 1{
                self?.refresh()
            }
        }
        
    }
    
    func addZakazQR(){
        
        let qrScannerVC = QRScanViewController()
        
        qrScannerVC.qrConnected = { [weak self] qr in
            
            qrScannerVC.dismiss(animated: true, completion: nil)
            
            NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchase_actions.UpdatePurQR?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)&AQR=\(qr)") { data, error in
                
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print("Error with Update Pur QR : \(error)")
                        return
                    }
                    
                    if let errorText = data!["msg"].string , errorText != ""{
                        
                        self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorText)
                        return
                        
                    }
                    
                    if data!["result"].intValue == 1{
                        
                        self?.refresh()
                        
                    }
                    
                }
                
            }
            
        }
        
        self.present(qrScannerVC, animated: true, completion: nil)
        
    }
    
}

//MARK: - TableView

extension ZakazViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let thisZakaz = thisZakaz else {return 0}
        
        if section == 0{
            return 1
        }else if section == 1 || section == 7{
            return 1
        }else if section == 2 , !thisZakaz.payCheckImg.isEmpty{//Check
            return 1
        }else if section == 3{//Status
            return 1
        }else if section == 4 , let intStatus = Int(thisZakaz.status) , intStatus >= 3{ //Parcel
            return 1
        }else if section == 5, let intStatus = Int(thisZakaz.status) , intStatus >= 3{ //Track
            return 1
        }else if section == 6 , let intStatus = Int(thisZakaz.status) , intStatus >= 3{ //QR
            return 1
        }else if section == 8{ //Tovar
            return purProds.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let thisZakaz = thisZakaz else {return UITableViewCell()}
        
        let section = indexPath.section
        
        if section == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "zakazCell", for: indexPath) as! ZakazTableViewCell
            
            cell.thisZakaz = thisZakaz
            
            cell.deliveryButtonTapped = { [weak self] in
                
                let zakazDeliveryDataVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZakazDeliveryDataVC") as! ZakazDeliveryDataTableViewController
                
                zakazDeliveryDataVC.zakazId = self!.thisZakazId
                
                let navVC = UINavigationController(rootViewController: zakazDeliveryDataVC)
                
                self?.present(navVC, animated: true)
                
            }
            
            return cell
            
        }else if section == 1 || section == 7{
            
            let cell = UITableViewCell()
            
            cell.backgroundColor = UIColor(named: "gray")
            cell.contentView.backgroundColor = UIColor(named: "gray")
            
            return cell
            
        }else if section == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoImageViewTowLabelCell", for: indexPath)
            
            guard let imageView1 = cell.viewWithTag(1) as? UIImageView ,
                  let label1 = cell.viewWithTag(2) as? UILabel,
                  let imageView2 = cell.viewWithTag(4) as? UIImageView,
                  let label2 = cell.viewWithTag(3) as? UILabel,
                  let cellButton = cell.viewWithTag(5) as? UIButton
            else {return cell}
            
            imageView1.image = UIImage(systemName: "list.bullet.rectangle")
            
            label1.text = "Чек оплаты"
            
            label2.text = "Показать"
            
            imageView2.image = UIImage(systemName: "chevron.right")
            
            cellButton.isHidden = true
            
            return cell
            
        }else if section == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoImageViewTowLabelCell", for: indexPath)
            
            guard let imageView1 = cell.viewWithTag(1) as? UIImageView ,
                  let label1 = cell.viewWithTag(2) as? UILabel,
                  let imageView2 = cell.viewWithTag(4) as? UIImageView,
                  let label2 = cell.viewWithTag(3) as? UILabel,
                  let cellButton = cell.viewWithTag(5) as? UIButton
            else {return cell}
            
            imageView1.image = UIImage(systemName: "doc.text")
            //            imageView2.image = nil
            //            label2.text = ""
            
            label1.text = "Статус"
            
            label2.text = thisZakaz.statusName
            
            if let intStatus = Int(thisZakaz.status) , intStatus < 3{
                
                imageView2.image = UIImage(systemName: "chevron.right")
                
                cellButton.showsMenuAsPrimaryAction = true
                
                let asyncItem = UIDeferredMenuElement { [weak self] completion in
                    
                    NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_vend.GetOrderStatuses?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)")) { data , error in
                        
                        if let error = error{
                            print("Error with GetOrderStatuses : \(error)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            
                            if data!["result"].intValue == 1{
                                
                                var menuItems = [UIAction]()
                                
                                let jsonSatuses = data!["actions"].arrayValue
                                
                                for i in 0 ..< jsonSatuses.count {
                                    
                                    let jsonStatus = jsonSatuses[i]
                                    
                                    menuItems.append(UIAction(title: "\(jsonStatus["capt"].stringValue)") { action in
                                        
                                        let actId = jsonStatus["act_id"].stringValue
                                        
                                        self?.statusChange(actId: actId)
                                        
                                    })
                                    
                                }
                                
                                completion(menuItems)
                                
                            }else{
                                
                                completion([])
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                let statusMenu = UIMenu(title: "Статус", children: [asyncItem])
                
                cellButton.menu = statusMenu
                
            }
            
        }else if section == 4{
            
            if let parcelDoc = parcelDoc{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
                
                guard let iconImageView = cell.viewWithTag(1) as? UIImageView ,
                      let label = cell.viewWithTag(2) as? UILabel ,
                      let _ = cell.viewWithTag(3), //imageViewView
                      let imageView = cell.viewWithTag(4) as? UIImageView,
                      let removeButtonView = cell.viewWithTag(5),
                      let removeButton = cell.viewWithTag(7) as? UIButton,
                      let imageViewButton = cell.viewWithTag(8) as? UIButton
                else {return UITableViewCell()}
                
                iconImageView.image =  UIImage(systemName: "camera.viewfinder")
                label.text = "Фото посылки"
                
                imageView.sd_setImage(with: URL(string: parcelDoc["img"].stringValue), completed: nil)
                
                imageView.layer.cornerRadius = 8
                removeButtonView.layer.cornerRadius = 14
                
                imageViewButton.addAction(UIAction(handler: { [weak self] _ in
                    self?.previewImage(parcelDoc["img"].stringValue)
                }) , for:.touchUpInside)
                
                if thisZakaz.status == "5"{
                    removeButtonView.isHidden = true
                }else{
                    removeButtonView.isHidden = false
                }
                
                removeButton.addAction(UIAction(handler: { [weak self] _ in
                    
                    let confirmAlert = UIAlertController(title: "Удалить фото посылки?", message: nil, preferredStyle: .alert)
                    
                    confirmAlert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                        
                        NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchase_actions.DeletePurDocIMG?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)&AImgID=\(parcelDoc["id"].stringValue)") { deleteData, deleteError in
                            
                            DispatchQueue.main.async {
                                
                                if let deleteError = deleteError{
                                    print("Error with Delete Pur Doc IMG : \(deleteError)")
                                    return
                                }
                                
                                if let errorText = deleteData!["msg"].string , errorText != ""{
                                    self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorText)
                                    return
                                }
                                
                                if deleteData!["result"].intValue == 1{
                                    
                                    self?.parcelDoc = nil
                                    self?.refresh()
                                    
                                }
                                
                            }
                            
                        }
                        
                    }))
                    
                    confirmAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    self?.present(confirmAlert , animated: true , completion: nil)
                    
                }), for: .touchUpInside)
                
                return cell
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "twoImageViewTowLabelCell", for: indexPath)
                
                guard let imageView1 = cell.viewWithTag(1) as? UIImageView ,
                      let label1 = cell.viewWithTag(2) as? UILabel,
                      let imageView2 = cell.viewWithTag(4) as? UIImageView,
                      let label2 = cell.viewWithTag(3) as? UILabel,
                      let cellButton = cell.viewWithTag(5) as? UIButton
                else {return cell}
                
                imageView1.image = UIImage(systemName: "camera.viewfinder")
                
                label1.text = "Фото посылки"
                
                label2.text = "Добавить"
                
                imageView2.image = UIImage(systemName: "chevron.right")
                
                cellButton.isHidden = true
                
                return cell
                
            }
            
        }else if section == 5{
            
            if let trackDoc = trackDoc{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
                
                guard let iconImageView = cell.viewWithTag(1) as? UIImageView ,
                      let label = cell.viewWithTag(2) as? UILabel ,
                      let _ = cell.viewWithTag(3), //imageViewView
                      let imageView = cell.viewWithTag(4) as? UIImageView,
                      let removeButtonView = cell.viewWithTag(5),
                      let removeButton = cell.viewWithTag(7) as? UIButton,
                      let imageViewButton = cell.viewWithTag(8) as? UIButton
                else {return UITableViewCell()}
                
                iconImageView.image =  UIImage(systemName: "text.viewfinder")
                label.text = "Фото трека"
                
                imageView.sd_setImage(with: URL(string: trackDoc["img"].stringValue), completed: nil)
                
                imageView.layer.cornerRadius = 8
                removeButtonView.layer.cornerRadius = 14
                
                imageViewButton.addAction(UIAction(handler: { [weak self] _ in
                    self?.previewImage(trackDoc["img"].stringValue)
                }) , for:.touchUpInside)
                
                if thisZakaz.status == "5"{
                    removeButtonView.isHidden = true
                }else{
                    removeButtonView.isHidden = false
                }
                
                removeButton.addAction(UIAction(handler: { [weak self] _ in
                    
                    let confirmAlert = UIAlertController(title: "Удалить фото трека?", message: nil, preferredStyle: .alert)
                    
                    confirmAlert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                        
                        NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_purchase_actions.DeletePurDocIMG?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)&AImgID=\(trackDoc["id"].stringValue)") { deleteData, deleteError in
                            
                            DispatchQueue.main.async {
                                
                                if let deleteError = deleteError{
                                    print("Error with Delete Pur Doc IMG : \(deleteError)")
                                    return
                                }
                                
                                if let errorText = deleteData!["msg"].string , errorText != ""{
                                    
                                    self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorText)
                                    return
                                    
                                }
                                
                                if deleteData!["result"].intValue == 1{
                                    
                                    self?.trackDoc = nil
                                    self?.refresh()
                                    
                                }
                                
                            }
                            
                        }
                        
                    }))
                    
                    confirmAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    self?.present(confirmAlert , animated: true , completion: nil)
                    
                }), for: .touchUpInside)
                
                return cell
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "twoImageViewTowLabelCell", for: indexPath)
                
                guard let imageView1 = cell.viewWithTag(1) as? UIImageView ,
                      let label1 = cell.viewWithTag(2) as? UILabel,
                      let imageView2 = cell.viewWithTag(4) as? UIImageView,
                      let label2 = cell.viewWithTag(3) as? UILabel,
                      let cellButton = cell.viewWithTag(5) as? UIButton
                else {return cell}
                
                imageView1.image = UIImage(systemName: "text.viewfinder")
                
                label1.text = "Фото трека"
                
                label2.text = "Добавить"
                
                imageView2.image = UIImage(systemName: "chevron.right")
                
                cellButton.isHidden = true
                
                return cell
                
            }
            
        }else if section == 6{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoImageViewTowLabelCell", for: indexPath)
            
            guard let imageView1 = cell.viewWithTag(1) as? UIImageView ,
                  let label1 = cell.viewWithTag(2) as? UILabel,
                  let imageView2 = cell.viewWithTag(4) as? UIImageView,
                  let label2 = cell.viewWithTag(3) as? UILabel,
                  let cellButton = cell.viewWithTag(5) as? UIButton
            else {return cell}
            
            imageView1.image = UIImage(systemName: "qrcode.viewfinder")
            
            label1.text = "QR-код заказа"
            
            label2.text = thisZakaz.orderQr == "1" ? "Изменить" : "Добавить"
            
            imageView2.image = UIImage(systemName: "chevron.right")
            
            cellButton.isHidden = true
            
            return cell
            
        }else if section == 8{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tovarCell",for: indexPath) as! TovarTableViewCell
            
            cell.thisZakaz = thisZakaz
            
            cell.contentType = .order
            
            let tovar = purProds[indexPath.row]
            
            cell.thisTovar = tovar
            
            cell.tovarImageTapped = {
                
                self.previewImage(tovar.img)
                
            }
            
            cell.bottomStackViewLeftViewButtonTapped = { [weak self] in
                //                print("Left tapped")
                
                if thisZakaz.status == "2"{ //This is for "Cобрано"
                    
                    let qrScannerVC = QRScanViewController()
                    
                    qrScannerVC.qrConnected = { [weak self] qr in
                        
                        VendorSetQRDataManager().getVendorSetQRData(key: self!.key, pid: "", qrValue: qr) { setQrData, setQrError in
                            
                            if let setQrError = setQrError{
                                print("Error with VendorSetQRDataManager : \(setQrError)")
                                return
                            }
                            
                            if setQrData!["result"].intValue == 1{
                                
                                qrScannerVC.dismiss(animated: true, completion: nil)
                                
                                self?.showSimpleAlertWithOkButton(title: "QR-код успешно привязан", message: nil)
                                
                                self?.purProds[indexPath.row].shouldShowBottomStackView = false
                                
                                cell.thisTovar = tovar
                                
                            }
                            
                        }
                        
                    }
                    
                    self?.present(qrScannerVC, animated: true, completion: nil)
                    
                    return
                    
                }
                
                NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_vend.ConfirmAvailability?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)&AItemID=\(tovar.pid)") { confirmData, confirmError in
                    
                    DispatchQueue.main.async {
                        
                        if let confirmError = confirmError {
                            print("Error with Confirm Availability : \(confirmError)")
                            return
                        }
                        
                        if confirmData!["result"].intValue == 1{
                            
                            cell.selectGreen()
                            
                        }
                        
                    }
                    
                }
                
            }
            
            cell.bottomStackViewRightViewButtonTapped = { [weak self] in
                //                print("RIght tapped")
                
                let alertController = UIAlertController(title: "Товара нет в наличии?", message: nil, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                    
                    NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_vend.ConfirmNotAviable?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)&AItemID=\(tovar.pid)") { confirmData, confirmError in
                        
                        DispatchQueue.main.async {
                            
                            if let confirmError = confirmError {
                                print("Error with Confirm Not Available : \(confirmError)")
                                return
                            }
                            
                            if confirmData!["result"].intValue == 1{
                                
                                let replaceJSONTovar = confirmData!["replace"]
                                
                                if !replaceJSONTovar.isEmpty{
                                    
                                    let purProd = replaceJSONTovar
                                    
                                    var replaceTovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue , itemStatus : purProd["item_status"].stringValue , handlerStatus : purProd["handler_status"].stringValue)
                                    
                                    guard let thisZakaz = self?.thisZakaz else {return}
                                    
                                    if let intStatus = Int(thisZakaz.status) , intStatus >= 3{
                                        replaceTovar.shouldShowBottomStackView = false
                                    }
                                    
                                    if tovar.qr == "1"{ //If qr is connected , no bottom bar should be shown
                                        replaceTovar.shouldShowBottomStackView = false
                                    }
                                    
                                    cell.thisTovar = replaceTovar
                                    
                                }
                                
                                cell.selectRed()
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self?.present(alertController , animated: true)
                
            }
            
            cell.qrCodeTapped = {
                
                if tovar.qr == "1"{
                    
                    let alertController = UIAlertController(title: "Перепривязать код?", message: nil, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                        
                        let qrScannerVC = QRScanViewController()
                        
                        qrScannerVC.qrConnected = { [weak self] qr in
                            
                            VendorSetQRDataManager().getVendorSetQRData(key: self!.key, pid: "", qrValue: qr) { setQrData, setQrError in
                                
                                if let setQrError = setQrError{
                                    print("Error with VendorSetQRDataManager : \(setQrError)")
                                    return
                                }
                                
                                if setQrData!["result"].intValue == 1{
                                    
                                    qrScannerVC.dismiss(animated: true, completion: nil)
                                    
                                    self?.showSimpleAlertWithOkButton(title: "QR-код успешно привязан", message: nil)
                                    
                                    self?.purProds[indexPath.row].shouldShowBottomStackView = false
                                    
                                    cell.thisTovar = tovar
                                    
                                }
                                
                            }
                            
                        }
                        
                        self.present(qrScannerVC, animated: true, completion: nil)
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    
                    let qrScannerVC = QRScanViewController()
                    
                    qrScannerVC.qrConnected = { [weak self] qr in
                        
                        VendorSetQRDataManager().getVendorSetQRData(key: self!.key, pid: self!.thisZakazId, qrValue: qr) { setQrData, setQrError in
                            
                            if let setQrError = setQrError{
                                print("Error with VendorSetQRDataManager : \(setQrError)")
                                return
                            }
                            
                            if setQrData!["result"].intValue == 1{
                                
                                qrScannerVC.dismiss(animated: true, completion: nil)
                                
                                self?.showSimpleAlertWithOkButton(title: "QR-код успешно привязан", message: nil)
                                
                                self?.purProds[indexPath.row].shouldShowBottomStackView = false
                                
                                cell.thisTovar = tovar
                                
                            }
                            
                        }
                        
                    }
                    
                    self.present(qrScannerVC, animated: true, completion: nil)
                    
                }
                
            }
            
            cell.zameniTapped = { [weak self] in
                
                let zameniVC = ZakazZameiTableViewController()
                
                zameniVC.tovarId = tovar.pid
                zameniVC.zakazId = self!.thisZakazId
                zameniVC.thisZakaz = self!.thisZakaz
                
                self?.navigationController?.pushViewController(zameniVC, animated: true)
                
            }
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        
        guard let thisZakaz = thisZakaz else {return}
        
        if section == 2{
            
            previewImage(thisZakaz.payCheckImg)
            
        }else if section == 4{
            sendingDocType = .gruz
            getImage()
        }else if section == 5{
            sendingDocType = .posilka
            getImage()
        }else if section == 6{
            
            if thisZakaz.orderQr == "1"{
                
                let alertController = UIAlertController(title: "К заказу уже привязан QR код заказа , вы хотите его изменить?", message: nil, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
                    
                    self?.addZakazQR()
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                present(alertController, animated: true)
                
            }else{
                
                addZakazQR()
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let thisZakaz = thisZakaz else {return 0}
        
        let section = indexPath.section
        
        if section == 0{
            return K.makeHeightForZakazCell(data: thisZakaz, width: view.bounds.width - 32)
        }else if section == 1 || section == 7{
            return 30
        }else if section == 2 || section == 3 || section == 6{
            return 50
        }else if section == 4{
            if parcelDoc != nil{
                return 148
            }else{
                return 50
            }
        }else if section == 5{
            if trackDoc != nil{
                return 148
            }else{
                return 50
            }
        }else if section == 8{
            
            let purProd = purProds[indexPath.row]
            
            return K.makeHeightForTovarCell(thisTovar: purProd, contentType: .order, width: view.bounds.width - 32)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 8{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                update()
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
}

//MARK: - VendTargetOrderDataManager

extension ZakazViewController : VendTargetOrderDataManagerDelegate{
    
    func didGetVendTargetOrderData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.refreshControl.endRefreshing()
            
            self?.zakazData = data
            
            if data["result"].intValue == 1{
                
                self?.docs = data["docs"].arrayValue
                
                let jsonOrder = data["order"]
                
                self?.thisZakaz = ZakazTableViewCell.Zakaz(id: jsonOrder["id"].stringValue, date: jsonOrder["dt"].stringValue, itemsCount: jsonOrder["items_cnt"].stringValue, replaces: jsonOrder["replaces"].stringValue, clientBalance: jsonOrder["client_balance"].stringValue, orderSumm: jsonOrder["ord_summ"].stringValue, comment: jsonOrder["comm"].stringValue, clientName: jsonOrder["client_name"].stringValue, clientId: jsonOrder["client_id"].stringValue, deliveryName: jsonOrder["delivery_name"].stringValue, deliveryType: jsonOrder["delivery_type"].stringValue, statusName: jsonOrder["status_name"].stringValue, status: jsonOrder["status"].stringValue, payCheckImg: jsonOrder["pay_check_img"].stringValue, orderQr: jsonOrder["order_qr"].stringValue , isShownForOneZakaz: true)
                
                self?.navigationItem.title = "Заказ #"+self!.thisZakaz!.id
                
                var newProds = [TovarCellItem]()
                
                data["prods"].arrayValue.forEach { purProd in
                    
                    var tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue , itemStatus : purProd["item_status"].stringValue , handlerStatus : purProd["handler_status"].stringValue)
                    
                    guard let thisZakaz = self?.thisZakaz else {return}
                    
                    if let intStatus = Int(thisZakaz.status) , intStatus >= 3{
                        tovar.shouldShowBottomStackView = false
                    }
                    
                    if tovar.qr == "1"{ //If qr is connected , no bottom bar should be shown
                        tovar.shouldShowBottomStackView = false
                    }
                    
                    newProds.append(tovar)
                    
                }
                
                self?.purProds = newProds
                
                self?.tableView.reloadData()
                
            }else{
                
                if let errorMessage = data["msg"].string , !errorMessage.isEmpty{
                    self?.showSimpleAlertWithOkButton(title: errorMessage, message: nil)
                }
                
            }
            
        }
        
    }
    
    func didFailGettingVendTargetOrderDataWithError(error: String) {
        refreshControl.endRefreshing()
        print("Error with VendTargetOrderDataManager : \(error)")
    }
    
}

//MARK: - UIImagePickerControllerDelegate

extension ZakazViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let safeUrl = info[.imageURL] as? URL{
            
            if sendingDocType == .gruz {
                gruzImageUrl = safeUrl
                showBoxView(with: "Загрузка фото груза")
            }else if sendingDocType == .posilka{
                posilkaImageUrl = safeUrl
                showBoxView(with: "Загрузка фото накладной")
            }
            
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
        }else if let safeImage = info[.originalImage] as? UIImage{
            
            if sendingDocType == .gruz {
                gruzImage = safeImage
                showBoxView(with: "Загрузка фото посылки")
            }else if sendingDocType == .posilka{
                posilkaImage = safeImage
                showBoxView(with: "Загрузка фото трека")
            }
            
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
        }
        
        //        print(info)
        
        dismiss(animated: true, completion: nil)
        
    }
    
}


//MARK: - NewPhotoPlaceDataManagerDelegate

extension ZakazViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let url = "\(data["post_to"].stringValue)/store?file_name=\(data["file_name"].stringValue)"
                
                print("URL FOR SENDING THE FILE: \(url)")
                
                if sendingDocType == .gruz{
                    if let gruzImageUrl = gruzImageUrl{
                        sendFileToServer(from: gruzImageUrl, to: url)
                    }else if let gruzImage = gruzImage{
                        sendFileToServer(image: gruzImage, to: url)
                    }
                }else if sendingDocType == .posilka{
                    if let posilkaImageUrl = posilkaImageUrl{
                        sendFileToServer(from: posilkaImageUrl, to: url)
                    }else if let posilkaImage = posilkaImage{
                        sendFileToServer(image: posilkaImage, to: url)
                    }
                }
                
                let imageId = data["image_id"].stringValue
                
                let imageLinkWithPortAndWithoutFile = "\(data["post_to"].stringValue)"
                let splitIndex = imageLinkWithPortAndWithoutFile.lastIndex(of: ":")!
                let imageLink = "\(String(imageLinkWithPortAndWithoutFile[imageLinkWithPortAndWithoutFile.startIndex ..< splitIndex]))\(data["file_name"].stringValue)"
                
                print("Image Link: \(imageLink)")
                
                if sendingDocType == .gruz{
                    gruzImageId = imageId
                }else if sendingDocType == .posilka{
                    posilkaImageId = imageId
                }
                
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

extension ZakazViewController{
    
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
                
                DispatchQueue.main.async { [weak self] in
                    
                    //                    print("Got \(isSendingGruz ? "gruz" : "posilka") sent to server")
                    
                    var imageid = ""
                    
                    if sendingDocType == .gruz {
                        imageid = self!.gruzImageId!
                    }else if sendingDocType == .posilka{
                        imageid = self!.posilkaImageId!
                    }
                    
                    photoSavedDataManager.getPhotoSavedData(key: key, photoId: imageid) { data, error in
                        
                        self?.removeBoxView()
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            
                            guard let data = data else {return}
                            
                            if data["result"].intValue == 1{
                                
                                //                                print("\(isSendingGruz ? "Gruz" : "Posilka") image successfuly saved to server")
                                
                                if sendingDocType == .gruz{
                                    gruzSent()
                                }else if sendingDocType == .posilka{
                                    posilkaSent()
                                }
                                
                            }else{
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            task.resume()
            
        }catch{
            print(error)
            removeBoxView()
        }
        
    }
    
    func sendFileToServer(image : UIImage, to toUrl : String){
        
        //        print("import result : \(fromUrl)")
        
        guard let toUrl = URL(string: toUrl) else {return}
        
        print("To URL: \(toUrl)")
        
        do{
            
            let imageData = image.jpegData(compressionQuality: 0.5)
            
            var request = URLRequest(url: toUrl)
            
            request.httpMethod = "POST"
            request.setValue("text/plane", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                
                if error != nil {
                    print("Error sending file: \(error!.localizedDescription)")
                    return
                }
                
                guard let data = data else {return}
                
                let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
                
                print("Answer : \(json)")
                
                DispatchQueue.main.async {
                    
                    var imageid = ""
                    
                    if self!.sendingDocType == .gruz {
                        imageid = self!.gruzImageId!
                    }else if self!.sendingDocType == .posilka{
                        imageid = self!.posilkaImageId!
                    }
                    
                    self?.photoSavedDataManager.getPhotoSavedData(key: self!.key, photoId: imageid) { data, error in
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            
                            guard let data = data else {return}
                            
                            if data["result"].intValue == 1{
                                
                                print("Check image successfuly saved to server")
                                
                                self?.removeBoxView()
                                
                                if self!.sendingDocType == .gruz{
                                    self?.gruzSent()
                                }else if self!.sendingDocType == .posilka{
                                    self?.posilkaSent()
                                }
                                
                            }else{
                                
                                self?.removeBoxView()
                                
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

extension ZakazViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}

