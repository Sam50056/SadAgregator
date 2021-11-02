//
//  FavoriteBrokersView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.08.2021.
//

import SwiftUI
import UIKit
import SwiftyJSON
import RealmSwift

//MARK: - ViewController Representable

struct FavoriteBrokersView : UIViewControllerRepresentable{
    
    func makeUIViewController(context: Context) -> FavoriteBrokersViewController {
        
        return FavoriteBrokersViewController() //UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteVendsVC") as! FavoriteVendsViewController
        
    }
    
    func updateUIViewController(_ uiViewController: FavoriteBrokersViewController, context: Context) {
        
    }
    
}

//MARK: - ViewController

class FavoriteBrokersViewController : UITableViewController {
    
    let realm = try! Realm()
    
    let activityController = UIActivityIndicatorView()
    
    var key = ""
    
    lazy var brokersFavoritesDataManager = BrokersFavoritesDataManager()
    
    var page = 1
    var rowForPaggingUpdate : Int = 10
    
    var brokersArray = [JSON]()
    
    var brokersData : JSON?
    
    var brokerSelected : ((String , String) -> Void)?
    
    override func viewDidLoad() {
        
        loadUserData()
        
        tableView.register(UINib(nibName: "BrokerTableViewCell", bundle: nil), forCellReuseIdentifier: "brokerCell")
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCell")
        
        refreshControl = UIRefreshControl()
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        
        tableView.separatorStyle = .none
        
        brokersFavoritesDataManager.delegate = self
        
        refresh(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if brokerSelected != nil{
            navigationItem.title = "Избранные посредники"
        }
    }
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        page = 1
        
        brokersArray.removeAll()
        
        tableView.reloadData()
        
        brokersFavoritesDataManager.getBrokersFavoritesData(key: key, page: page)
        
        showSimpleCircleAnimation(activityController: activityController)
        
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brokersData != nil ? brokersArray.count == 0 ? 1 : brokersArray.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if brokersArray.isEmpty{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            
            (cell as! EmptyTableViewCell).label.text = "Вы еще не добавили посредников в избранное"
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "brokerCell" , for: indexPath) as! BrokerTableViewCell
        
        let broker = brokersArray[indexPath.row]
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let brokerSelected = brokerSelected {
            brokerSelected(brokersArray[indexPath.row]["id"].stringValue , brokersArray[indexPath.row]["name"].stringValue)
        }else{
            
            let brokerCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BrokerCardVC") as! BrokerCardViewController
            
            let selectedBrokerId = brokersArray[indexPath.row]["id"].string
            
            brokerCardVC.thisBrokerId = selectedBrokerId
            
            navigationController?.pushViewController(brokerCardVC, animated: true)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (brokersArray.count == 0) ? ((UIScreen.main.bounds.height / 2)) : (K.makeHeightForBrokerCell(broker: brokersArray[indexPath.row]))
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 9
            
            brokersFavoritesDataManager.getBrokersFavoritesData(key: key, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - BrokersFavoritesDataManager

extension FavoriteBrokersViewController : BrokersFavoritesDataManagerDelegate {
    
    func didGegBrokersFavoritesData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.brokersData = data
            
            self?.brokersArray.append(contentsOf: data["brokers"].arrayValue)
            
            self?.tableView.reloadSections([0], with: .automatic)
            
            self?.refreshControl?.endRefreshing()
            
            self?.stopSimpleCircleAnimation(activityController: self!.activityController)
            
        }
        
    }
    
    func didFailGettingBrokersFavoritesDataWithError(error: String) {
        print("Error with BrokersFavoritesDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension FavoriteBrokersViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}

