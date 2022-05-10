//
//  AllCategoriesViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.02.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class AllCategoriesViewController: UITableViewController {
    
    let realm = try! Realm()
    
    let activityController = UIActivityIndicatorView()
    
    var key = ""
    
    var catWorkDomain = ""
    
    var getCatListDataManager = GetCatListDataManager()
    var catsGetVendCatsDataManager = CatsGetVendCatsDataManager()
    
    var categories = [JSON]()
    
    var parentId : String?
    
    var vendId : String?
    
    var contentType : ContentType = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        navigationItem.title = "Категории"
        
        getCatListDataManager.delegate = self
        
        refresh()
        
    }
    
    //MARK: - Functions
    
    @objc func refresh(){
        
        showSimpleCircleAnimation(activityController: activityController)
        
        if contentType == .normal{
            
            getCatListDataManager.getGetCatListData(domain: catWorkDomain, key: key, parentId: parentId)
            
        }else if contentType == .vend , let vendId = vendId{
            
            catsGetVendCatsDataManager.getCatsGetVendCatsData(key: key, domain: catWorkDomain, vendId: vendId) { data, error in
                
                DispatchQueue.main.async{ [weak self] in
                    
                    self?.stopSimpleCircleAnimation(activityController: self!.activityController)
                    
                    if let error = error {
                        print("Error with CatsGetVendCatsDataManager : \(error)")
                        return
                    }
                    
                    if data!["result"].intValue == 1{
                        
                        self?.categories = data!["list"].arrayValue
                        
                        if let title = data!["name"].string{
                            self?.navigationItem.title = title
                        }
                        
                        self?.tableView.reloadData()
                        
                    }else{
                        
                        if let errorMessage = data!["msg"].string {
                            self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorMessage)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryItemCell", for: indexPath)
        
        if let firstLabel = cell.viewWithTag(1) as? UILabel ,
           let secondLabel = cell.viewWithTag(2) as? UILabel ,
           let thirdLabel = cell.viewWithTag(3) as? UILabel{
            
            let category = categories[indexPath.row]
            
            firstLabel.text = category["capt"].stringValue
            secondLabel.text = category["descr"].stringValue
            
            thirdLabel.text = category["cnt"].stringValue
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = categories[indexPath.row]
        
        let id = category["id"].stringValue
        
        if parentId != nil || category["is_cat"].stringValue == "1"{
            
            let categoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoryVC") as! CategoryViewController
            
            categoryVC.thisCatId = id
            
            categoryVC.contentType = contentType == .normal ? .normal : .vend
            
            categoryVC.thisVendId = vendId
            
            navigationController?.pushViewController(categoryVC, animated: true)
            
        }else {
            
            if contentType == .normal{
                
                let allCategoriesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllCatVC") as! AllCategoriesViewController
                
                allCategoriesVC.parentId = id
                
                navigationController?.pushViewController(allCategoriesVC, animated: true)
                
            }else if contentType == .vend{
                
                let allCategoriesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllCatVC") as! AllCategoriesViewController
                
                allCategoriesVC.parentId = parentId
                
                allCategoriesVC.contentType = .vend
                
                allCategoriesVC.vendId = vendId
                
                navigationController?.pushViewController(allCategoriesVC, animated: true)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK: - Data Manipulation Methods

extension AllCategoriesViewController{
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        catWorkDomain = userDataObject.first!.catWork
        
    }
    
}

//MARK: - GetCatListDataManagerDelegate

extension AllCategoriesViewController : GetCatListDataManagerDelegate{
    
    func didGetGetCatListData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            categories = data["list"].arrayValue
            
            if let title = data["name"].string{
                navigationItem.title = title
            }
            
            tableView.reloadData()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingGetCatListDataWithError(error: String) {
        print("Error with GetCatListDataManager : \(error)")
        DispatchQueue.main.async { [weak self] in
            self?.stopSimpleCircleAnimation(activityController: self!.activityController)
        }
    }
    
}

//MARK: - Enums

extension AllCategoriesViewController {
    
    enum ContentType {
        case normal
        case vend
    }
    
}
