//
//  BrokersPopularityViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.07.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class BrokersPopularityViewController: UITableViewController {
    
    private let realm = try! Realm()
    
    private var key = ""
    
    private var brokersBrokersTopDataManager = BrokersBrokersTopDataManager()
    
    private var brokers = [JSON]()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 14
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        brokersBrokersTopDataManager.delegate = self
        
        tableView.register(UINib(nibName: "BrokerTableViewCell", bundle: nil), forCellReuseIdentifier: "brokerCell")
        tableView.separatorStyle = .none
        
        update()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Посредники"
        
    }
    
}

//MARK: - Functions

extension BrokersPopularityViewController{
    
    func update(){
        
        brokersBrokersTopDataManager.getBrokersBrokersTopData(key: key, page: page)
        
    }
    
}

//MARK: - TableView

extension BrokersPopularityViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brokers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "brokerCell" , for: indexPath) as! BrokerTableViewCell
        
        let broker = brokers[indexPath.row]
        
        cell.label.text = broker["name"].stringValue
        
        let rating = broker["avg_rate"].doubleValue
        cell.ratingView.rating = rating
        cell.ratingView.settings.fillMode = .precise
        cell.ratingLabel.text = "\(rating)"
        
        cell.brokerImageView.sd_setImage(with: URL(string: broker["img"].stringValue), placeholderImage: UIImage(systemName: "person"))
        
        var otherItemsArray = [BrokerTableViewCell.TableViewItem]()
        var rateItemsArray = [BrokerTableViewCell.TableViewItem]()
        var parcelItemsArray = [BrokerTableViewCell.TableViewItem]()
        
        if let phone = broker["phone"].string , phone != ""{
            otherItemsArray.append(BrokerTableViewCell.TableViewItem(image: "phone", label1Text: "Телефон", label2Text: phone))
        }
        
        broker["rates"].arrayValue.forEach { jsonRate in
            
            rateItemsArray.append(BrokerTableViewCell.TableViewItem(image: "newspaper", label1Text: "Условия закупки", label2Text: jsonRate["capt"].stringValue + " " + jsonRate["marge"].stringValue))
            
        }
        
        broker["parcels"].arrayValue.forEach { jsonParcel in
            
            parcelItemsArray.append(BrokerTableViewCell.TableViewItem(image: "shippingbox", label1Text: "Условия доставки", label2Text: jsonParcel["name"].stringValue + " " + jsonParcel["price"].stringValue))
            
        }
        
        cell.otherItems = otherItemsArray
        cell.rateItems = rateItemsArray
        cell.parcelItems = parcelItemsArray
        
        cell.verifyImageView.isHidden = broker["verify"].intValue == 0
            
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height : CGFloat = 0
        
        let topPartHeight : CGFloat = 90
        
        let broker = brokers[indexPath.row]
        
        if let phone = broker["phone"].string , phone != ""{
            height += 32
        }
        
        height += 32 * CGFloat(broker["rates"].arrayValue.count)
        
        height += 32 * CGFloat(broker["parcels"].arrayValue.count)
        
        height += topPartHeight
        
        return height
        
    }
    
}

//MARK: - BrokersBrokersTopDataManager

extension BrokersPopularityViewController : BrokersBrokersTopDataManagerDelegate{
    
    func didGetBrokersBrokersTopData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.brokers = data["brokers"].arrayValue
                
                self?.tableView.reloadData()
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingBrokersBrokersTopDataWithError(error: String) {
        print("Error with BrokersBrokersTopDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension BrokersPopularityViewController {
    
    func loadUserData(){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first?.key ?? ""
        
    }
    
}
