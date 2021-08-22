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
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var brokersBrokersTopDataManager = BrokersBrokersTopDataManager()
    private lazy var brokersBrokersTopBySearchDataManager = BrokersBrokersTopBySearchDataManager()
    
    private var brokers = [JSON]()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 14
    
    private var searchBarIsEmpty : Bool{
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
    private var searchTimer : Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        brokersBrokersTopDataManager.delegate = self
        brokersBrokersTopBySearchDataManager.delegate = self
        
        tableView.register(UINib(nibName: "BrokerTableViewCell", bundle: nil), forCellReuseIdentifier: "brokerCell")
        tableView.separatorStyle = .none
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        update()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Рейтинг посредников"
        
    }
    
}

//MARK: - Functions

extension BrokersPopularityViewController{
    
    func update(){
        
        if searchBarIsEmpty{
            brokersBrokersTopDataManager.getBrokersBrokersTopData(key: key, page: page)
        }else{
            
            searchTimer != nil ? searchTimer.invalidate() : nil
            
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
                self?.brokersBrokersTopBySearchDataManager.geBrokersBrokersTopBySearchData(key: self!.key, query: self!.searchController.searchBar.text!, page: self!.page)
            }
            
        }
        
    }
    
}

//MARK: - SearchBar

extension BrokersPopularityViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        brokers.removeAll()
        page = 1
        
        update()
        
        tableView.reloadData()
        
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
        
        let peoples = broker["peoples"].stringValue
        
        if peoples == "" || peoples == "0"{
            cell.peoplesLabel.text = ""
            cell.peoplesImageView.isHidden = true
        }else{
            cell.peoplesLabel.text = peoples
            cell.peoplesImageView.isHidden = false
        }
        
        let rev = broker["revs"].intValue
        
        if rev == 0{
            cell.revLabel.text = ""
            cell.revImageView.isHidden = true
        }else{
            cell.revLabel.text = String(rev)
            cell.revImageView.isHidden = false
        }
        
        let imgs = broker["imgs"].stringValue
        
        if imgs == "0" || imgs == "" {
            cell.imageCountLabel.text = ""
            cell.imageCountImageView.isHidden = true
        }else{
            cell.imageCountLabel.text = imgs
            cell.imageCountImageView.isHidden = false
        }
        
        
        let rating = broker["avg_rate"].doubleValue
        cell.ratingView.rating = rating
        cell.ratingView.settings.fillMode = .precise
        cell.ratingLabel.text = "\(rating)"
        
        cell.brokerImageView.sd_setImage(with: URL(string: broker["img"].stringValue), placeholderImage: UIImage(systemName: "person"))
        
        var otherItemsArray = [BrokerTableViewCell.TableViewItem]()
        var rateItemsArray = [BrokerTableViewCell.TableViewItem]()
        var parcelItemsArray = [BrokerTableViewCell.TableViewItem]()
        
        let brokerJsonRates = broker["rates"].arrayValue
        let brokerJsonParcels = broker["parcels"].arrayValue
        
        if let phone = broker["phone"].string , phone != ""{
            otherItemsArray.append(BrokerTableViewCell.TableViewItem(image: "phone", label1Text: "Телефон", label2Text: phone))
        }
        
        if !brokerJsonRates.isEmpty{
            
            rateItemsArray.append(BrokerTableViewCell.TableViewItem(image: "newspaper", label1Text: "Условия закупки", label2Text: ""))
            
            brokerJsonRates.forEach { jsonRate in
                
                rateItemsArray.append(BrokerTableViewCell.TableViewItem(image: "newspaper", label1Text: "Условия закупки", label2Text: jsonRate["capt"].stringValue + " " + jsonRate["marge"].stringValue))
                
            }
            
        }
        
        if !brokerJsonParcels.isEmpty{
            
            parcelItemsArray.append(BrokerTableViewCell.TableViewItem(image: "shippingbox", label1Text: "Условия доставки", label2Text: ""))
            
            brokerJsonParcels.forEach { jsonParcel in
                
                parcelItemsArray.append(BrokerTableViewCell.TableViewItem(image: "shippingbox", label1Text: "Условия доставки", label2Text: jsonParcel["name"].stringValue + " " + jsonParcel["price"].stringValue))
                
            }
            
        }
        
        cell.otherItems = otherItemsArray
        cell.rateItems = rateItemsArray
        cell.parcelItems = parcelItemsArray
        
        cell.verifyImageView.isHidden = broker["verify"].intValue == 0
        
        if broker["new"].intValue == 1{
            
            cell.ratingView.isHidden = true
            cell.ratingLabel.isHidden = true
            
            let newFrame = CGRect(x: cell.ratingLabel.frame.origin.x, y: cell.ratingView.frame.origin.y, width: 70, height: 25)
            
            let newView = UIView(frame: newFrame)
            
            newView.backgroundColor = #colorLiteral(red: 0.8812789321, green: 0.9681747556, blue: 0.9018383622, alpha: 1)
            newView.layer.cornerRadius = 6
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: newView.frame.width, height: newView.frame.height))
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center
            label.textColor = .systemGreen
            
            label.text = "Новичок"
            
            newView.addSubview(label)
            
            cell.contentView.addSubview(newView)
            
        }else{
            cell.ratingView.isHidden = false
            cell.ratingLabel.isHidden = false
        }
        
        if broker["gold_rate"].intValue == 1{
            
            cell.ratingView.settings.filledColor = #colorLiteral(red: 0.9989343286, green: 0.8006014824, blue: 0.007612912916, alpha: 1)
            cell.ratingView.settings.filledBorderColor = #colorLiteral(red: 0.9989343286, green: 0.8006014824, blue: 0.007612912916, alpha: 1)
            cell.ratingView.settings.emptyBorderColor = #colorLiteral(red: 0.9989343286, green: 0.8006014824, blue: 0.007612912916, alpha: 1)
            
        }else{
            
            cell.ratingView.settings.filledColor = .systemGray
            cell.ratingView.settings.filledBorderColor = .systemGray
            cell.ratingView.settings.emptyBorderColor = .systemGray
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return K.makeHeightForBrokerCell(broker: brokers[indexPath.row])
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let brokerCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BrokerCardVC") as! BrokerCardViewController
        
        let selectedBrokerId = brokers[indexPath.row]["id"].string
        
        brokerCardVC.thisBrokerId = selectedBrokerId
        
        navigationController?.pushViewController(brokerCardVC, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            update()
            
            print("Done a request for page: \(page)")
            
        }
        
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

//MARK: - BrokersBrokersTopBySearchDataManager

extension BrokersPopularityViewController : BrokersBrokersTopBySearchDataManagerDelegate{
    
    func didGetBorkersBrokersTopDataManager(data: JSON) {
        DispatchQueue.main.async { [weak self] in
            
            if data["result"].intValue == 1{
                
                self?.brokers.append(contentsOf: data["brokers"].arrayValue)
                
                self?.tableView.reloadData()
                
            }else{
                
            }
            
        }
    }
    
    func didFailGettingBorkersBrokersTopDataWithError(error: String) {
        print("Error with BrokersBrokersTopBySearchDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension BrokersPopularityViewController {
    
    func loadUserData(){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first?.key ?? ""
        
    }
    
}
