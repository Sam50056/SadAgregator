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
    
    private var thisZakaz : ZakazTableViewCell.Zakaz?
    var thisZakazId = ""
    
    private var purProds = [TovarCellItem]()
    private var statuses = [JSON]()
    
    private var selectedStatus = 0{
        didSet{
            if selectedStatus != oldValue{
                refresh()
            }
        }
    }
    
    private var vendTargetOrderDataManager = VendTargetOrderDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ZakazTableViewCell", bundle: nil), forCellReuseIdentifier: "zakazCell")
        tableView.register(UINib(nibName: "TovarTableViewCell", bundle: nil), forCellReuseIdentifier: "tovarCell")
        
        vendTargetOrderDataManager.delegate = self
        
        refresh()
        
        updateNavBarItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
    }
    
}

//MARK: - Actions

extension ZakazViewController{
    
    
    
}

//MARK: - Functions

extension ZakazViewController{
    
    func updateNavBarItems(){
        
        let asyncItem = UIDeferredMenuElement { [weak self] completion in
            
            NoAnswerDataManager().sendNoAnswerDataRequest(url: URL(string: "https://agrapi.tk-sad.ru/agr_vend.GetOrderStatuses?AKey=\(self!.key)&APurSYSID=\(self!.thisZakazId)")) { data , error in
                
                if let error = error{
                    print("Error with GetPurStatuses : \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if data!["result"].intValue == 1{
                        
                        var menuItems = [UIAction]()
                        
                        let jsonSatuses = data!["statuses"].arrayValue
                        
                        self?.statuses = jsonSatuses
                        
                        for i in 0 ..< jsonSatuses.count {
                            
                            let jsonStatus = jsonSatuses[i]
                            
                            menuItems.append(UIAction(title: "\(jsonStatus["capt"].stringValue)" , state: i == self!.selectedStatus ? .on : .off) { action in
                                
                                self!.selectedStatus = i
                                self!.updateNavBarItems()
                                
                            })
                            
                        }
                        
                        completion(menuItems)
                        
                    }
                    
                }
                
            }
            
        }
        
        let statusMenu = UIMenu(title: "Статус", children: [asyncItem])
        
        let statusNavBarItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), primaryAction: nil, menu: statusMenu)
        
        navigationItem.rightBarButtonItems = [statusNavBarItem]
        
    }
    
    @objc func refresh(){
        
        guard thisZakazId != "" else {return}
        
        vendTargetOrderDataManager.getVendTargetOrderData(key: key, order: thisZakazId)
        
    }
    
}

//MARK: - TableView

extension ZakazViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else if section == 1{
            return 1
        }else if section == 2{
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
            
            return cell
            
        }else if section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoImageViewTowLabelCell", for: indexPath)
            
            guard let imageView1 = cell.viewWithTag(1) as? UIImageView ,
                  let label1 = cell.viewWithTag(2) as? UILabel,
                  let imageView2 = cell.viewWithTag(4) as? UIImageView,
                  let label2 = cell.viewWithTag(3) as? UILabel
            else {return cell}
            
            imageView1.image = UIImage(systemName: "doc.text")
            imageView2.image = UIImage(systemName: "chevron.right")
            label1.text = "Статус"
            label2.text = "Новый заказ"
            
            return cell
            
        }else if section == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tovarCell",for: indexPath) as! TovarTableViewCell
            
            cell.contentType = .order
            
            var tovar = purProds[indexPath.row]
            
            cell.thisTovar = tovar
            
            cell.tovarImageTapped = {
                
                self.previewImage(tovar.img)
                
            }
            
            cell.bottomStackViewLeftViewButtonTapped = {
                print("Left tapped")
            }
            
            cell.bottomStackViewRightViewButtonTapped = {
                print("RIght tapped")
            }
            
            cell.infoTapped = {
                
                if tovar.comExt != "0"{
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    alertController.addAction(UIAlertAction(title: "Перейти на пост в VK", style: .default, handler: { _ in
                        
                        guard let vkLink = URL(string: "https://vk.com/wall\(tovar.link)") else {return}
                        
                        UIApplication.shared.open(vkLink, options: [:])
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "Посмотреть комментарии", style: .default, handler: { _ in
                        
                        let assemblyCommentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssemblyCommentsVC") as! AssemblyCommentsViewController
                        
                        assemblyCommentsVC.thisTovarId = tovar.pid
                        
                        self.present(assemblyCommentsVC, animated: true, completion: nil)
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }else{
                    
                    guard let vkLink = URL(string: "https://vk.com/wall\(tovar.link)") else {return}
                    
                    UIApplication.shared.open(vkLink, options: [:])
                    
                }
                
            }
            
            cell.questionMarkTapped = {
                
                let alertController = UIAlertController(title: "Задать вопрос клиенту по товару?", message: nil, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
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
                    
                    let qrScannerVC = QRScannerController()
                    
                    qrScannerVC.pid = tovar.pid
                    
                    qrScannerVC.qrConnected = { [weak self] in
                        
                        self?.showSimpleAlertWithOkButton(title: "QR-код успешно привязан", message: nil)
                        
                        tovar.status = "Куплено"
                        
                        tovar.qr = "1"
                        
                        cell.thisTovar = tovar
                        
                    }
                    
                    self.present(qrScannerVC, animated: true, completion: nil)
                    
                }
                
            }
            
            cell.magnifyingGlassTapped = { [weak self] in
                
                let tovarImageSearchVC = TovarImageSearchTableViewController()
                
                tovarImageSearchVC.imageHashText = tovar.hash
                
                //                tovarImageSearchVC.thisPointId = self!.pointId
                
                tovarImageSearchVC.thisPid = tovar.pid
                
                tovarImageSearchVC.vibratTochkaInPost = { postId in
                    
                    tovarImageSearchVC.dismiss(animated: true, completion: nil)
                    
                    self?.purProds.remove(at: indexPath.row)
                    
                    self?.tableView.reloadData()
                    
                    if self!.purProds.isEmpty{
                        
                        let alertController = UIAlertController(title: "У пользователя не добавлены товары", message: nil, preferredStyle: .alert)
                        
                        alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }))
                        
                        self?.present(alertController, animated: true, completion: nil)
                        
                    }
                    
                }
                
                //            print("HASH THAT WE'RE GIVING \(tovar.hash)")
                
                let navVC = UINavigationController(rootViewController: tovarImageSearchVC)
                
                self!.present(navVC, animated: true, completion: nil)
                
            }
            
            cell.oplachenoTapped = {
                
                self.previewImage(tovar.payedImage)
                
            }
            
            cell.shipmentImageTapped = {
                
                self.previewImage(tovar.shipmentImage)
                
            }
            
            cell.clientNameTapped = {
                
                let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
                
                clientVC.thisClientId = tovar.clientId
                
                let navVC = UINavigationController(rootViewController: clientVC)
                
                self.present(navVC, animated: true, completion: nil)
            }
            
            cell.statusTapped = {
                
                AssemblyAvailableStatusesDataManager().getAssemblyAvailableStatusesData(key: self.key, id: tovar.pid) { data, error in
                    
                    DispatchQueue.main.async {
                        
                        if let error = error , data == nil{
                            
                            print("Error with AssemblyAvailableStatusesDataManager : \(error)")
                            return
                        }
                        
                        if data!["result"].intValue == 1{
                            
                            let jsonStatuses = data!["statuses"].arrayValue
                            
                            let sheetAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            jsonStatuses.forEach { jsonStatus in
                                
                                sheetAlertController.addAction(UIAlertAction(title: jsonStatus["capt"].stringValue, style: .default, handler: { _ in
                                    
                                    AssemblySetItemStatusDataManager().getAssemblySetItemStatusData(key: self.key, id: tovar.pid, status: jsonStatus["id"].stringValue) { setStatusData, setStatusError in
                                        
                                        DispatchQueue.main.async {
                                            
                                            if let error = error , data == nil{
                                                
                                                print("Error with AssemblySetItemStatusDataManager : \(error)")
                                                return
                                            }
                                            
                                            if data!["result"].intValue == 1{
                                                
                                                tovar.status = jsonStatus["capt"].stringValue
                                                
                                                cell.thisTovar = tovar
                                                
                                            }else{
                                                
                                                if let message = data!["msg"].string, message != ""{
                                                    
                                                    self.showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                                                    
                                                }else{
                                                    
                                                    self.showSimpleAlertWithOkButton(title: "Ошибка запроса", message: nil)
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }))
                                
                            }
                            
                            sheetAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                            
                            self.present(sheetAlertController, animated: true, completion: nil)
                            
                        }else{
                            
                            if let message = data!["msg"].string, message != ""{
                                
                                self.showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                                
                            }else{
                                
                                self.showSimpleAlertWithOkButton(title: "Ошибка запроса", message: nil)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            cell.zakupkaTapped = {
                
                let alertController = UIAlertController(title: tovar.chLvl == "1" ? "Изменить цену закупки?" : "Отправить на согласование изменение закупочный цены?", message: nil, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                    
                    let textFieldAlertController = UIAlertController(title: "Введите новое значение", message: nil, preferredStyle: .alert)
                    
                    textFieldAlertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { _ in
                        
                        guard let newValue = textFieldAlertController.textFields?[0].text else {return}
                        
                        AssemblySetItemValueDataManager().getAssemblySetItemValueData(key: self.key, itemId: tovar.pid, fieldId: "1", value: newValue) { data, error in
                            
                            DispatchQueue.main.async {
                                
                                if let error = error , data == nil{
                                    
                                    print("Error with AssemblyAvailableStatusesDataManager : \(error)")
                                    return
                                }
                                
                                if data!["result"].intValue == 1{
                                    
                                    tovar.purCost = newValue
                                    
                                    cell.thisTovar = tovar
                                    
                                }
                                
                            }
                            
                        }
                        
                    }))
                    
                    textFieldAlertController.addTextField { field in
                        
                        field.keyboardType = .numberPad
                        
                    }
                    
                    textFieldAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    self.present(textFieldAlertController, animated: true, completion: nil)
                    
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            cell.prodazhaTapped = {
                
                let alertController = UIAlertController(title: "Изменить цену продажи?", message: nil, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                    
                    let textFieldAlertController = UIAlertController(title: "Введите новое значение", message: nil, preferredStyle: .alert)
                    
                    textFieldAlertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { _ in
                        
                        guard let newValue = textFieldAlertController.textFields?[0].text else {return}
                        
                        AssemblySetItemValueDataManager().getAssemblySetItemValueData(key: self.key, itemId: tovar.pid, fieldId: "2", value: newValue) { data, error in
                            
                            DispatchQueue.main.async {
                                
                                if let error = error , data == nil{
                                    
                                    print("Error with AssemblyAvailableStatusesDataManager : \(error)")
                                    return
                                }
                                
                                if data!["result"].intValue == 1{
                                    
                                    tovar.sellCost = newValue
                                    
                                    cell.thisTovar = tovar
                                    
                                }
                                
                            }
                            
                        }
                        
                    }))
                    
                    textFieldAlertController.addTextField { field in
                        
                        field.keyboardType = .numberPad
                        
                    }
                    
                    textFieldAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    self.present(textFieldAlertController, animated: true, completion: nil)
                    
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            cell.razmerTapped = {
                
                let alertController = UIAlertController(title: tovar.chLvl == "1" ? "Изменить размер?" : "Отправить на согласование изменение размера?" , message: nil, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                    
                    AssemblyGetItemSizesDataManager().getAssemblyGetItemSizesData(key: self.key, id: tovar.pid) { data, error in
                        
                        DispatchQueue.main.async {
                            
                            if let error = error , data == nil{
                                
                                print("Error with AssemblyAvailableStatusesDataManager : \(error)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                let jsonSizes = data!["sizes"].arrayValue
                                
                                let sheetAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                
                                jsonSizes.forEach { jsonSize in
                                    
                                    sheetAlertController.addAction(UIAlertAction(title: jsonSize.stringValue, style: .default, handler: { _ in
                                        
                                        AssemblySetItemValueDataManager().getAssemblySetItemValueData(key: self.key, itemId: tovar.pid, fieldId: "3", value: jsonSize.stringValue) { data, error in
                                            
                                            DispatchQueue.main.async {
                                                
                                                if let error = error , data == nil{
                                                    
                                                    print("Error with AssemblyAvailableStatusesDataManager : \(error)")
                                                    return
                                                }
                                                
                                                if data!["result"].intValue == 1{
                                                    
                                                    tovar.size = jsonSize.stringValue
                                                    
                                                    cell.thisTovar = tovar
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }))
                                    
                                }
                                
                                sheetAlertController.addAction(UIAlertAction(title: "Свой размер", style: .default, handler: { _ in
                                    
                                    let textFieldAlertController = UIAlertController(title: "Введите свой размер", message: nil, preferredStyle: .alert)
                                    
                                    textFieldAlertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { _ in
                                        
                                        guard let newValue = textFieldAlertController.textFields?[0].text else {return}
                                        
                                        AssemblySetItemValueDataManager().getAssemblySetItemValueData(key: self.key, itemId: tovar.pid, fieldId: "3", value: newValue) { data, error in
                                            
                                            DispatchQueue.main.async {
                                                
                                                if let error = error , data == nil{
                                                    
                                                    print("Error with AssemblyAvailableStatusesDataManager : \(error)")
                                                    return
                                                }
                                                
                                                if data!["result"].intValue == 1{
                                                    
                                                    tovar.size = newValue
                                                    
                                                    cell.thisTovar = tovar
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }))
                                    
                                    textFieldAlertController.addTextField { field in
                                        
                                    }
                                    
                                    textFieldAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                    
                                    self.present(textFieldAlertController, animated: true, completion: nil)
                                    
                                }))
                                
                                sheetAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                                
                                self.present(sheetAlertController, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let thisZakaz = thisZakaz else {return 0}
        
        let section = indexPath.section
        
        if section == 0{
            return K.makeHeightForZakazCell(data: thisZakaz, width: view.bounds.width - 32)
        }else if section == 1{
            return 50
        }else if section == 2{
            
            let purProd = purProds[indexPath.row]
            
            return K.makeHeightForTovarCell(thisTovar: purProd, contentType: .order)
        }
        
        return 0
    }
    
}

//MARK: - VendTargetOrderDataManager

extension ZakazViewController : VendTargetOrderDataManagerDelegate{
    
    func didGetVendTargetOrderData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                let jsonOrder = data["order"]
                
                self?.thisZakaz = ZakazTableViewCell.Zakaz(id: jsonOrder["id"].stringValue, date: jsonOrder["dt"].stringValue, itemsCount: jsonOrder["items_cnt"].stringValue, replaces: jsonOrder["replaces"].stringValue, clientBalance: jsonOrder["client_balance"].stringValue, orderSumm: jsonOrder["ord_summ"].stringValue, comment: jsonOrder["comm"].stringValue, clientName: jsonOrder["client_name"].stringValue, clientId: jsonOrder["client_id"].stringValue, deliveryName: jsonOrder["delivery_name"].stringValue, deliveryType: jsonOrder["delivery_type"].stringValue, statusName: jsonOrder["status_name"].stringValue, status: jsonOrder["status"].stringValue, payCheckImg: jsonOrder["pay_check_img"].stringValue, orderQr: jsonOrder["order_qr"].stringValue , isShownForOneZakaz: true)
                
                self?.navigationItem.title = "Заказ #"+self!.thisZakaz!.id
                
                var newProds = [TovarCellItem]()
                
                data["prods"].arrayValue.forEach { purProd in
                    
                    var tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue , itemStatus : purProd["item_status"].stringValue , handlerStatus : purProd["handler_status"].stringValue)
                    
                    if tovar.itemStatus == "" {
                        tovar.shouldShowBottomStackView = false
                    }
                    
                    if let intItemStatus = Int(tovar.itemStatus) , intItemStatus >= 3{
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
        print("Error with VendTargetOrderDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension ZakazViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}

