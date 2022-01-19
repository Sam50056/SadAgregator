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
                        
                        let jsonSatuses = data!["actions"].arrayValue
                        
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
        5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else if section == 1 || section == 3{
            return 1
        }else if section == 2{
            return 1
        }else if section == 4{
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
            
        }else if section == 1 || section == 3{
            
            let cell = UITableViewCell()
            
            cell.backgroundColor = UIColor(named: "gray")
            cell.contentView.backgroundColor = UIColor(named: "gray")
            
            return cell
            
        }else if section == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoImageViewTowLabelCell", for: indexPath)
            
            guard let imageView1 = cell.viewWithTag(1) as? UIImageView ,
                  let label1 = cell.viewWithTag(2) as? UILabel,
                  let imageView2 = cell.viewWithTag(4) as? UIImageView,
                  let label2 = cell.viewWithTag(3) as? UILabel
            else {return cell}
            
            imageView1.image = UIImage(systemName: "doc.text")
            imageView2.image = nil
            label2.text = ""
           
            label1.text = "Статус"
            
            if let intStatus = Int(thisZakaz.status) , intStatus < 3{
                
                imageView2.image = UIImage(systemName: "chevron.right")
                
                label2.text = thisZakaz.statusName
                
            }
            
            return cell
            
        }else if section == 4{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tovarCell",for: indexPath) as! TovarTableViewCell
            
            cell.thisZakaz = thisZakaz
            
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
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let thisZakaz = thisZakaz else {return 0}
        
        let section = indexPath.section
        
        if section == 0{
            return K.makeHeightForZakazCell(data: thisZakaz, width: view.bounds.width - 32)
        }else if section == 1 || section == 3{
            return 30
        }else if section == 2{
            return 50
        }else if section == 4{
            
            let purProd = purProds[indexPath.row]
            
            return K.makeHeightForTovarCell(thisTovar: purProd, contentType: .order, width: view.bounds.width - 32)
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
                    
                    guard let thisZakaz = self?.thisZakaz else {return}
                    
                    if let intStatus = Int(thisZakaz.status) , intStatus >= 3{
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

