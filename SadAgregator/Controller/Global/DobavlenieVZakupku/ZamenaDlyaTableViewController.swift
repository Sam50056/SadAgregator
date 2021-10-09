//
//  ZamenaDlyaTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.04.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ZamenaDlyaTableViewController: UITableViewController {
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var thisClientId : String?
    var zakupkaId : String?
    
    private var purchasesProdsByClientDataManager = PurchasesProdsByClientDataManager()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var purProds = [JSON]()
    
    var tovarSelected : ((String) -> Void)?
    
    var shouldCloseWindowFromNav = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        purchasesProdsByClientDataManager.delegate = self
        
        tableView.register(UINib(nibName: "TovarTableViewCell", bundle: nil), forCellReuseIdentifier: "tovar_cell")
        tableView.allowsSelection = false
        
        if let id = thisClientId{
            purchasesProdsByClientDataManager.getPurchasesProdsByClientData(key: key, clientId: id, purSYSID: zakupkaId ?? "")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Замена для"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(otmenaTapped(_:)))
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let purProd = purProds[indexPath.row]
        
        let tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue)
        
        return K.makeHeightForTovarCell(thisTovar: tovar, isZamena: true)
        
    }
    
}

//MARK: - Actions

extension ZamenaDlyaTableViewController{
    
    @IBAction func otmenaTapped(_ sender : Any){
        if shouldCloseWindowFromNav{
            navigationController?.popViewController(animated: true)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
}

//MARK: - PurchasesProdsByClientDataManager

extension ZamenaDlyaTableViewController : PurchasesProdsByClientDataManagerDelegate{
    
    func didGetPurchasesProdsByClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                purProds.append(contentsOf: data["pur_prods"].arrayValue)
                
                if page == 1 && purProds.isEmpty{
                    
                    let alertController = UIAlertController(title: "У пользователя не добавлены товары", message: nil, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    present(alertController, animated: true, completion: nil)
                    
                }
                
                tableView.reloadData()
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesProdsByClientDataWithError(error: String) {
        print("Error with PurchasesProdsByClientDataManager : \(error)")
    }
    
}

// MARK: - TableView

extension ZamenaDlyaTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purProds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tovar_cell",for: indexPath) as! TovarTableViewCell
        
        cell.isZamena = true
        
        let purProd = purProds[indexPath.row]
        
        var tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, defCheck: purProd["def_check"].stringValue , withoutRep: purProd["without_rep"].stringValue, payedImage: purProd["payed_img"].stringValue, shipmentImage: purProd["shipment_img"].stringValue)
        
        cell.thisTovar = tovar
        
        cell.tovarSelected = { [self] in
            
            dismiss(animated: true, completion: nil)
            
            tovarSelected?(tovar.pid)
            
        }
        
        cell.infoTapped = {
            
            if tovar.comExt != "0"{
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                alertController.addAction(UIAlertAction(title: "Перейти на пост в VK", style: .default, handler: { _ in
                    
                    guard let vkLink = URL(string: "https://vk.com/wall\(tovar.link)") else {return}
                    
                    UIApplication.shared.open(vkLink, options: [:])
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Посмотреть комментарии", style: .default, handler: { _ in
                    
                    
                    
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
        
        cell.tovarImageTapped = {
            
            self.previewImage(tovar.img)
            
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            if let id = thisClientId{
                purchasesProdsByClientDataManager.getPurchasesProdsByClientData(key: key, clientId: id, purSYSID: zakupkaId ?? "", page: page)
            }
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension ZamenaDlyaTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}
