//
//  ZakazZameiTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.01.2022.
//

import UIKit
import RealmSwift

class ZakazZameiTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var key = ""
    
    var tovarId = ""
    var zakazId = ""
    var thisZakaz : ZakazTableViewCell.Zakaz?
    
    private var purProds = [TovarCellItem]()
    
    let dataManager = NoAnswerDataManager()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.register(UINib(nibName: "TovarTableViewCell", bundle: nil), forCellReuseIdentifier: "tovarCell")
        
        refreshControl = UIRefreshControl()
        
        refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        
        refresh()
        
    }
    
    //MARK: - Functions
    
    func update(){
        
        guard zakazId != "" , tovarId != "" else {return}
        
        dataManager.sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_vend.GetReplaces?AKey=\(key)&APurSYSID=\(zakazId)&AItemID=\(tovarId)&APage=\(page)") { data, error in
            
            DispatchQueue.main.async { [weak self] in 
                
                self?.refreshControl!.endRefreshing()
                
                if let error = error {
                    print("Error with GetReplaces : \(error)")
                    return
                }
                
                if let errorText = data!["msg"].string , errorText != ""{
                    self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorText)
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    var newProds = [TovarCellItem]()
                    
                    data!["prods"].arrayValue.forEach { purProd in
                        
                        var tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue , commentTitle: purProd["comment"]["title"].stringValue , commentMessage: purProd["comment"]["msg"].stringValue , itemStatus : purProd["item_status"].stringValue , handlerStatus : purProd["handler_status"].stringValue)
                        
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
    
    @objc func refresh(){
        
        purProds.removeAll()
        
        page = 1
        rowForPaggingUpdate = 15
        
        update()
        
    }
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purProds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let thisZakaz = thisZakaz else {return UITableViewCell()}
        
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
            
            NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_vend.ConfirmAvailability?AKey=\(self!.key)&APurSYSID=\(self!.zakazId)&AItemID=\(tovar.pid)") { confirmData, confirmError in
                
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
                
                NoAnswerDataManager().sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_vend.ConfirmNotAviable?AKey=\(self!.key)&APurSYSID=\(self!.zakazId)&AItemID=\(tovar.pid)") { confirmData, confirmError in
                    
                    DispatchQueue.main.async {
                        
                        if let confirmError = confirmError {
                            print("Error with Confirm Not Available : \(confirmError)")
                            return
                        }
                        
                        if confirmData!["result"].intValue == 1{
                            
                            let replaceJSONTovar = confirmData!["replace"]
                            
                            if !replaceJSONTovar.isEmpty{
                                
                                let purProd = replaceJSONTovar
                                
                                var replaceTovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue , commentTitle: purProd["comment"]["title"].stringValue , commentMessage: purProd["comment"]["msg"].stringValue , itemStatus : purProd["item_status"].stringValue , handlerStatus : purProd["handler_status"].stringValue)
                                
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
                    
                    VendorSetQRDataManager().getVendorSetQRData(key: self!.key, pid: self!.zakazId, qrValue: qr) { setQrData, setQrError in
                        
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
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                update()
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let purProd = purProds[indexPath.row]
        
        return K.makeHeightForTovarCell(thisTovar: purProd, contentType: .order, width: view.bounds.width - 32)
        
    }
    
}

//MARK: - Data Manipulation Methods

extension ZakazZameiTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}


