//
//  MyZakaziViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.12.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class MyZakaziViewController : UIViewController{
    
    @IBOutlet weak var tableView : UITableView!
    
    let realm = try! Realm()
    
    private var key = ""
    
    private var vendFormOrdersDataManager = VendFormOrdersDataManager()
    
    private var orders = [ZakazTableViewCell.Zakaz]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.register(UINib(nibName: "ZakazTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        vendFormOrdersDataManager.delegate = self
        
        vendFormOrdersDataManager.getVendFormOrdersData(key: key, status: "", page: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Мои заказы"
        
    }
    
}

//MARK: - TableView

extension MyZakaziViewController : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCell
        
        let index = indexPath.row
        
        cell.thisZakaz = orders[index]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        K.makeHeightForZakazCell(data: orders[indexPath.row])
    }
    
}

//MARK: - VendFormOrdersDataManager

extension MyZakaziViewController : VendFormOrdersDataManagerDelegate{
    
    func didGetVendFormOrdersData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                var newOrders = [ZakazTableViewCell.Zakaz]()
                
                data["orders"].arrayValue.forEach { jsonOrder in
                    
                    newOrders.append(ZakazTableViewCell.Zakaz(id: jsonOrder["id"].stringValue, date: jsonOrder["dt"].stringValue, itemsCount: jsonOrder["items_cnt"].stringValue, replaces: jsonOrder["replaces"].stringValue, clientBalance: jsonOrder["client_balance"].stringValue, orderSumm: jsonOrder["ord_summ"].stringValue, comment: jsonOrder["comm"].stringValue, clientName: jsonOrder["client_name"].stringValue, clientId: jsonOrder["client_id"].stringValue, deliveryName: jsonOrder["delivery_name"].stringValue, deliveryType: jsonOrder["delivery_type"].stringValue, statusName: jsonOrder["status_name"].stringValue, status: jsonOrder["status"].stringValue, payCheckImg: jsonOrder["pay_check_img"].stringValue, orderQr: jsonOrder["order_qr"].stringValue))
                    
                }
                
                self?.orders.append(contentsOf: newOrders)
                
                self?.tableView.reloadData()
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingVendFormOrdersDataWithError(error: String) {
        print("Error with VendFormOrdersDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension MyZakaziViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
