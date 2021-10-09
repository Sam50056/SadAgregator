//
//  MyZakupkiViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.09.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

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
        
        cell.openTapped = { [weak self] isTovars in
            if isTovars{
                self?.purchases[indexPath.row].openTovars.toggle()
            }else{
                self?.purchases[indexPath.row].openMoney.toggle()
            }
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.clientTapped = { [weak self] id in
            
            let clientsListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyZakupkiClientsList") as! MyZakupkiClientsListViewController
            
            clientsListVC.thisPur = pur.purId
            
            self?.navigationController?.pushViewController(clientsListVC, animated: true)
            
        }
        
        cell.tableView.reloadData()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let pur = purchases[indexPath.row]
    
        return K.makeHeightForZakupkaCell(data: pur)
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
                        newMoneySubItems.append(ZakupkaTableViewCell.TableViewItem(label1: jsonMoneyItem["capt"].stringValue, label2: "", label3: jsonMoneyItem["value"].stringValue))
                    }
                    
                    var pur = ZakupkaTableViewCell.Zakupka(purId: purchaseData["pur_id"].stringValue, statusId: purchaseData["status_id"].stringValue, capt: purchaseData["capt"].stringValue, dt: purchaseData["dt"].stringValue, countItems: purchaseData["cnt_items"].stringValue, replaces: purchaseData["replaces"].stringValue, countClients: purchaseData["cnt_clients"].stringValue, countPoints: purchaseData["cnt_points"].stringValue, money: newMoneySubItems, clientId: purchaseData["client_id"].stringValue, handlerType: purchaseData["handler_type"].stringValue, handlerId: purchaseData["handler_id"].stringValue, handlerName: purchaseData["handler_name"].stringValue, actAv: purchaseData["act_ac"].stringValue, status: purchaseData["status"].stringValue, profit: purchaseData["profit"].stringValue, postageCost: purchaseData["postage_cost"].stringValue, itemsWait: purchaseData["items"]["wait"].stringValue, itemsWaitCost: purchaseData["items"]["wait_cost"].stringValue, itemsBought: purchaseData["items"]["bought"].stringValue, itemsBoughtCost: purchaseData["items"]["bought_cost"].stringValue, itemsNotAvailable: purchaseData["items"]["not_available"].stringValue, itemsNotAvailableCost: purchaseData["items"]["not_available_cost"].stringValue)
                    
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
