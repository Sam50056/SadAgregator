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
    
    var thisZakaz : ZakazTableViewCell.Zakaz?
    var thisZakazId : String?
    
    private var vendTargetOrderDataManager = VendTargetOrderDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ZakazTableViewCell", bundle: nil), forCellReuseIdentifier: "zakazCell")
        
        vendTargetOrderDataManager.delegate = self
        
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let thisZakaz = thisZakaz else {return}
        
        navigationItem.title = "Заказ #"+thisZakaz.id
        
    }
    
}

//MARK: - Actions

extension ZakazViewController{
    
    
    
}

//MARK: - Functions

extension ZakazViewController{
    
    @objc func refresh(){
        
        guard let thisZakazId = thisZakazId else {return}
        
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
        }else if section == 3{
            
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

