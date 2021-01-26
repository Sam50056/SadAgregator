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
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCell")
        
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
        
        showSimpleCircleAnimation()
        
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendsArray.count == 0 ? 1 : vendsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if vendsArray.isEmpty{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            
            (cell as! EmptyTableViewCell).label.text = "Вы еще не добавили поставщиков в избранное"
            
            return cell
            
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "vendCell", for: indexPath) as! VendTableViewCell
        
        setUpVendCell(cell: cell as! VendTableViewCell, data: vendsArray[indexPath.row])
        
        //        EmptyTableViewCell
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         
        guard vendsArray.count != 0 else {return}
        
        selectedVendId = vendsArray[indexPath.row]["id"].stringValue
        
        self.performSegue(withIdentifier: "goToPostavshik", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (vendsArray.count == 0) ? ((UIScreen.main.bounds.height / 2)) : (K.makeHeightForVendCell(vend: vendsArray[indexPath.row]))
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
        
        DispatchQueue.main.async { [self] in
            
            vendsArray.append(contentsOf: data["vends"].arrayValue)
            
            tableView.reloadSections([0], with: .automatic)
            
            refreshControl?.endRefreshing()
            
            stopSimpleCircleAnimation()
            
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
