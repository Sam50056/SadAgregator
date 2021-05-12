//
//  VendsPopularityRatingViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.01.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON

class VendsPopularityRatingViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    var refreshControl = UIRefreshControl()
    
    let realm = try! Realm()
    
    var key : String?
    
    var isLogged : Bool = false
    
    var hintCellShouldBeShown = true
    
    var topVendorsDataManager = TopVendorsDataManager()
    
    var items = [JSON]()
    var help : JSON?
    
    var page = 1
    var rowForPaggingUpdate : Int = 15
    
    var selectedVendId = ""
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        topVendorsDataManager.delegate = self
        
        tableView.register(UINib(nibName: "VendorRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "vendRatingCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.delegate = self
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        tableView.separatorStyle = .none
        
        searchView.layer.cornerRadius = 10
        
        refresh(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        navigationItem.title = "Рейтинг Поставщиков"
        
    }
    
    //MARK: - Actions
    
    @IBAction func searchTextFieldEditingChanged(_ sender: UITextField) {
        
        if searchTextField.text != "" , key != nil{
            
            topVendorsDataManager.getTopVendorsData(key: key!, query: searchTextField.text!)
            
            items.removeAll()
            
        }else if searchTextField.text == "" , key != nil{
            
            refresh(self)
            
        }
        
    }
    
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        guard let key = key else {return}
        
        topVendorsDataManager.getTopVendorsData(key: key, query: searchTextField.text ?? "")
        
        items.removeAll()
        
        page = 1
        rowForPaggingUpdate = 15
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToVend"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension VendsPopularityRatingViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first?.key ?? ""
        
        isLogged = userDataObject.first?.isLogged ?? false
        
    }
    
}

//MARK: - TopVendorsDataManagerDelegate

extension VendsPopularityRatingViewController : TopVendorsDataManagerDelegate{
    
    func didGetTopVendorsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            items.append(contentsOf:data["items"].arrayValue)
            
            help = data["help"]
            
            tableView.reloadData()
            
            refreshControl.endRefreshing()
            
        }
        
    }
    
    func didFailGettingTopVendorsDataWithError(error: String) {
        print("Error with TopVendorsDataManager : \(error)")
    }
    
}

//MARK: - TextField Stuff

extension VendsPopularityRatingViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != "" , key != nil{
            
            topVendorsDataManager.getTopVendorsData(key: key!, query: textField.text!)
            
            items.removeAll()
            
        }
        
        return true 
        
    }
    
}

//MARK: - TableView Stuff

extension VendsPopularityRatingViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return help != nil ? (hintCellShouldBeShown ? 1 : 0) : 0
        }else {
            return items.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
            
            guard let help = help else {return cell}
            
            setUpHintCell(cell: cell, data : help)
            
        }else {
            
            if !items.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "vendRatingCell", for: indexPath)
                
                setUpVendRatingCell(cell: cell as! VendorRatingTableViewCell, data: items[indexPath.row])
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return K.simpleCellHeight
        }else {
            
            if !items.isEmpty{
                return K.makeHeightForVendRatingCell(vendRatingCell: items[indexPath.row])
            }else{
                return 0
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            selectedVendId = items[indexPath.row]["vend_id"].stringValue
            
            performSegue(withIdentifier: "goToVend", sender: self)
            
        }else if indexPath.section == 0 {
            
            if let help = help , let url = URL(string: help["url"].stringValue){
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 9
                
                topVendorsDataManager.getTopVendorsData(key: key!, query: searchTextField.text!, page: page)
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
    @IBAction func removeHintCell(_ sender : Any) {
        
        hintCellShouldBeShown = false
        
        tableView.reloadSections([0], with: .automatic)
        
    }
    
    //MARK: - Cells SetUp
    
    func setUpHintCell(cell : UITableViewCell , data : JSON){
        
        if let closeButton = cell.viewWithTag(3) as? UIButton,
           let label = cell.viewWithTag(2) as? UILabel{
            
            label.text = data["str"].stringValue
            
            closeButton.addTarget(self, action: #selector(removeHintCell(_: )), for: .touchUpInside)
            
        }
        
    }
    
    func setUpVendRatingCell(cell: VendorRatingTableViewCell , data : JSON){
        
        cell.nameLabel.text = data["name"].stringValue
        
        cell.dateLabel.text = data["dt"].stringValue
        
        cell.captLabel.text = data["capt"].stringValue
        
        cell.posLabel.text = data["pos"].stringValue
        
        let peoples = data["peoples"].stringValue
        
        if peoples == "" || peoples == "0"{
            cell.peoplesLabel.text = ""
            cell.peoplesImageView.isHidden = true
        }else{
            cell.peoplesLabel.text = peoples
            cell.peoplesImageView.isHidden = false
        }
        
        let rev = data["revs"].intValue
        
        if rev == 0{
            cell.revLabel.text = ""
            cell.revImageView.isHidden = true
        }else{
            cell.revLabel.text = String(rev)
            cell.revImageView.isHidden = false
        }
        
        let imgs = data["imgs"].stringValue
        
        if imgs == "0" || imgs == "" {
            cell.imgsLabel.text = ""
            cell.imgsImageView.isHidden = true
        }else{
            cell.imgsLabel.text = imgs
            cell.imgsImageView.isHidden = false
        }
        
        let prices = data["prices"].stringValue
        let pricesAvg = data["prices_avg"].stringValue
        let pop = data["popularity"].intValue
        let rating = data["avg_rate"].stringValue
        
        cell.rating = rating == "0" ? nil : rating
        cell.prices = prices == "" ? nil : prices
        cell.pricesAvg = pricesAvg == "" ? nil : pricesAvg
        cell.pop = pop == 0 ? "Нет уникального контента" : "Охват ~\(String(pop)) чел/сутки"
        
    }
    
}

