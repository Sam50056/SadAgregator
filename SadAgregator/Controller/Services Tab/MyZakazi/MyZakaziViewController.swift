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
    
    private var selectedStatus = 0{
        didSet{
            if selectedStatus != oldValue{
                refresh()
            }
        }
    }
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.register(UINib(nibName: "ZakazTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        vendFormOrdersDataManager.delegate = self
        
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Мои заказы"
        
        updateNavBarItems()
        
    }
    
}

//MARK: - Functions

extension MyZakaziViewController {
    
    func updateNavBarItems(){
        
        let statusMenu = UIMenu(title: "Статус", children: [
            UIAction(title: "Новый заказ", state: selectedStatus == 0 ? .on : .off) { [weak self] action in
                self?.selectedStatus = 0
                self?.updateNavBarItems()
            },
            UIAction(title: "Ожидает оплаты", state: selectedStatus == 1 ? .on : .off) { [weak self] action in
                self?.selectedStatus = 1
                self?.updateNavBarItems()
            },
            UIAction(title: "В обработке", state: selectedStatus == 2 ? .on : .off) { [weak self] action in
                self?.selectedStatus = 2
                self?.updateNavBarItems()
            },
            UIAction(title: "Собран", state: selectedStatus == 3 ? .on : .off) { [weak self] action in
                self?.selectedStatus = 3
                self?.updateNavBarItems()
            },
            UIAction(title: "Готов к отправке", state: selectedStatus == 4 ? .on : .off) { [weak self] action in
                self?.selectedStatus = 4
                self?.updateNavBarItems()
            },
            UIAction(title: "Отправлен", state: selectedStatus == 5 ? .on : .off) { [weak self] action in
                self?.selectedStatus = 5
                self?.updateNavBarItems()
            }
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), menu: statusMenu)
        
    }
    
    func update(){
        
        vendFormOrdersDataManager.getVendFormOrdersData(key: key, status: "\(selectedStatus)", page: page)
        
    }
    
    @objc private func refresh(){
        
        orders.removeAll()
        page = 1
        
        vendFormOrdersDataManager.getVendFormOrdersData(key: key, status: "\(selectedStatus)", page: 1)
        
    }
    
}

//MARK: - TableView

extension MyZakaziViewController : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count == 0 ? 1 : orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if orders.isEmpty{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel
            else {return cell}
            
            if selectedStatus == 0{
                label.text = "Нет новых заказов"
            }else if selectedStatus == 1{
                label.text = "Нет заказов , ожидающих оплаты"
            }else if selectedStatus == 2{
                label.text = "Нет заказов в обработке"
            }else if selectedStatus == 3{
                label.text = "Нет собранных заказов"
            }else if selectedStatus == 4{
                label.text = "Нет заказов готовых к отправке"
            }else if selectedStatus == 5{
                label.text = "Нет отправленных заказов"
            }
            
            label.textColor = .systemGray
            label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
            
            cell.backgroundColor = UIColor(named: "whiteblack")
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCell
        
        let index = indexPath.row
        
        cell.thisZakaz = orders[index]
        
        cell.tableViewTapped = { [weak self] in
            
            let zakazVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZakazVC") as! ZakazViewController
            
            zakazVC.thisZakazId = self!.orders[index].id
            
            self?.navigationController?.pushViewController(zakazVC, animated: true)
            
        }
        
        cell.deliveryButtonTapped = { [weak self] in
            
            let zakazDeliveryDataVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZakazDeliveryDataVC") as! ZakazDeliveryDataTableViewController
            
            zakazDeliveryDataVC.zakazId = self!.orders[index].id
            
            let navVC = UINavigationController(rootViewController: zakazDeliveryDataVC)
            
            self?.present(navVC, animated: true)
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        orders.isEmpty ? (view.frame.height - 64) : K.makeHeightForZakazCell(data: orders[indexPath.row], width: view.bounds.width - 32)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard !orders.isEmpty else {return}
        
        let zakazVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ZakazVC") as! ZakazViewController
        
        zakazVC.thisZakazId = orders[indexPath.row].id
        
        navigationController?.pushViewController(zakazVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                update()
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
}

//MARK: - VendFormOrdersDataManager

extension MyZakaziViewController : VendFormOrdersDataManagerDelegate{
    
    func didGetVendFormOrdersData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.refreshControl.endRefreshing()
            
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
        refreshControl.endRefreshing()
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
