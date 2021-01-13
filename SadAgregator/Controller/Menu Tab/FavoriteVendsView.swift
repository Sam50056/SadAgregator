//
//  FavoriteVendsView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 24.12.2020.
//

import SwiftUI
import UIKit
import SwiftyJSON
import RealmSwift

//MARK: - ViewController Representable

struct FavoriteVendsView : UIViewControllerRepresentable{
    
    func makeUIViewController(context: Context) -> FavoriteVendsViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteVendsVC") as! FavoriteVendsViewController
        
    }
    
    func updateUIViewController(_ uiViewController: FavoriteVendsViewController, context: Context) {
        
    }
    
}

//MARK: - ViewController

class FavoriteVendsViewController : UITableViewController {
    
    let realm = try! Realm()
    
    var key = ""
    
    lazy var myVendorsDataManager = MyVendorsDataManager()
    
    var page = 1
    var rowForPaggingUpdate : Int = 10
    
    var vendsArray = [JSON]()
    
    var selectedVendId : String?
    
    override func viewDidLoad() {
        
        loadUserData()
        
        tableView.register(UINib(nibName: "VendTableViewCell", bundle: nil), forCellReuseIdentifier: "vendCell")
        
        refreshControl = UIRefreshControl()
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        
        tableView.separatorStyle = .none
        
        myVendorsDataManager.delegate = self
        
        refresh(self)
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPostavshik"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
        }
        
    }
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        page = 1
        
        vendsArray.removeAll()
        
        tableView.reloadData()
        
        myVendorsDataManager.getMyVendorsData(key: key, page: page)
        
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "vendCell", for: indexPath) as! VendTableViewCell
        
        setUpVendCell(cell: cell, data: vendsArray[indexPath.row])
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedVendId = vendsArray[indexPath.row]["id"].stringValue
        
        self.performSegue(withIdentifier: "goToPostavshik", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.makeHeightForVendCell(vend: vendsArray[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 9
            
            myVendorsDataManager.getMyVendorsData(key: key, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
    //MARK: - Cell Set up
    
    func setUpVendCell(cell: VendTableViewCell , data : JSON){
        
        cell.data = data
        
        cell.nameLabel.text = data["name"].stringValue
        
        cell.actLabel.text = data["act"].stringValue
        
        let peoples = data["peoples"].stringValue
        
        if peoples == "0"{
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
        
        let phone = data["ph"].stringValue
        let pop = data["pop"].intValue
        let rating = data["rate"].stringValue
        
        cell.rating = rating == "0" ? nil : rating
        cell.phone = phone == "" ? nil : phone
        cell.pop = pop == 0 ? "Нет уникального контента" : "Охват ~\(String(pop)) чел/сутки"
        
    }
    
    
}

//MARK: - MyVendorsDataManagerDelegate

extension FavoriteVendsViewController : MyVendorsDataManagerDelegate {
    
    func didGetMyVendorsData(data : JSON){
        
        DispatchQueue.main.async {
            
            self.vendsArray.append(contentsOf: data["vends"].arrayValue)
            
            self.tableView.reloadSections([0], with: .automatic)
            
            self.refreshControl?.endRefreshing()
            
        }
        
    }
    
    func didFailGettingMyVendorsDataWithError(error : String){
        print("Error with MyVendorsDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension FavoriteVendsViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
