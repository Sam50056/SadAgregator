//
//  ProdsInPointTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.07.2021.
//

import UIKit
import SwiftUI
import SwiftyJSON
import RealmSwift

//MARK: - View Representable

struct ProdsInPointView : UIViewControllerRepresentable{
    
    var pointName : String?
    var pointId : String?
    var helperId : String?
    var status : String?
    
    func makeUIViewController(context: Context) -> ProdsInPointTableViewController {
        
        let vc = ProdsInPointTableViewController()
        
        vc.pointName = pointName
        vc.pointId = pointId
        vc.helperId = helperId
        vc.status = status
        
        return vc
        
    }
    
    func updateUIViewController(_ uiViewController: ProdsInPointTableViewController, context: Context) {
        
    }
    
}

//MARK: - View Controller

class ProdsInPointTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var key = ""
    
    var pointName : String?
    var pointId : String?
    var helperId : String?
    var status : String?
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var assemblyProdsInPointDataManager = AssemblyProdsInPointDataManager()
    
    private var purProds = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        assemblyProdsInPointDataManager.delegate = self
        
        loadUserData()
        
        tableView.register(UINib(nibName: "TovarTableViewCell", bundle: nil), forCellReuseIdentifier: "tovar_cell")
        
        tableView.allowsSelection = false
        
        refresh()
        
    }
    
}

//MARK: - Functions

extension ProdsInPointTableViewController{
    
    func update(){
        
        assemblyProdsInPointDataManager.getAssemblyProdsInPointData(key: key, pointId: pointId ?? "", helperId: helperId ?? "", status: status ?? "", page: page)
        
    }
    
    @objc func refresh (){
        
        purProds.removeAll()
        tableView.reloadData()
        
        page = 1
        rowForPaggingUpdate = 15
        
        update()
        
    }
    
}

//MARK: - TableView

extension ProdsInPointTableViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purProds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !purProds.isEmpty else {return UITableViewCell()}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tovar_cell",for: indexPath) as! TovarTableViewCell
        
        cell.isZamena = false
        
        let purProd = purProds[indexPath.row]
        
        var tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue)
        
        cell.thisTovar = tovar
        
        cell.tovarImageTapped = {
            
            self.previewImage(tovar.img)
            
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
                    
                    let qrScannerVC = QRScannerController()
                    
                    qrScannerVC.pid = tovar.pid
                    
                    qrScannerVC.qrConnected = {
                        
                        self.showSimpleAlertWithOkButton(title: "QR-код успешно привязан", message: nil)
                        
                        tovar.status = "Куплено"
                        
                        cell.thisTovar = tovar
                        
                    }
                    
                    self.present(qrScannerVC, animated: true, completion: nil)
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                
                let qrScannerVC = QRScannerController()
                
                qrScannerVC.pid = tovar.pid
                
                qrScannerVC.qrConnected = {
                    
                    self.showSimpleAlertWithOkButton(title: "QR-код успешно привязан", message: nil)
                    
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
            
            tovarImageSearchVC.thisPointId = self!.pointId
            
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard !purProds.isEmpty else {return 420}
        
        let purProd = purProds[indexPath.row]
        
        let tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue)
        
        return K.makeHeightForTovarCell(thisTovar: tovar, isZamena: false)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
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

//MARK: - AssemblyProdsInPointDataManager

extension ProdsInPointTableViewController : AssemblyProdsInPointDataManagerDelegate{
    
    func didGetAssemblyProdsInPointData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                self.purProds.append(contentsOf: data["assembly_prods"].arrayValue)
                
                if self.page == 1 && self.purProds.isEmpty{
                    
                    let alertController = UIAlertController(title: "У пользователя не добавлены товары", message: nil, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                self.tableView.reloadData()
                
                self.refreshControl!.endRefreshing()
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingAssemblyProdsInPointDataWithError(error: String) {
        print("Error with AssemblyProdsInPointDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension ProdsInPointTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
