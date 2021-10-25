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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        purchasesFormPagingDataManager.delegate = self
        
        tableView.register(UINib(nibName: "ZakupkaTableViewCell", bundle: nil), forCellReuseIdentifier: "purCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        purchasesFormPagingDataManager.getPurchasesFormPagingData(key: key, page: 1, status: "", query: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Мои закупки"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: nil) , UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: nil) , UIBarButtonItem(image: UIImage(systemName: "magnifyingglass" ) , style: .plain, target: self, action: nil)]
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
            
            PurchaseActionsGetActionsDataManager().getPurchaseActionsGetActionsData(key: self!.key, purId: pur.purId) { data, error in
                
                if let error = error , data == nil {
                    print("Error with PurchaseActionsGetActionsDataManager : \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if data!["result"].intValue == 1{
                        
                        let actionsArray = data!["actions"].arrayValue
                        
                        self?.showActionsSheet(actionsArray: actionsArray) { action in
                            
                        }
                        
                    }else{
                        
                        if let message = data!["msg"].string , !message.isEmpty{
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
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesFormPagingDataWithError(error: String) {
        print("Error with PurchasesFormPagingDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension MyZakupkiViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
