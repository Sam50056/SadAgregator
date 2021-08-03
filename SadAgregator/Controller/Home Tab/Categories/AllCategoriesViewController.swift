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
    
    var key = ""
    
    var getCatListDataManager = GetCatListDataManager()
    
    var categories = [JSON]()
    
    var parentId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        navigationItem.title = "Категории"
        
        getCatListDataManager.delegate = self
        
        getCatListDataManager.getGetCatListData(key: key, parentId: parentId)
        
    }
    
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
            
            navigationController?.pushViewController(categoryVC, animated: true)
            
        }else {
            
            let allCategoriesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllCatVC") as! AllCategoriesViewController
            
            allCategoriesVC.parentId = id
            
            navigationController?.pushViewController(allCategoriesVC, animated: true)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK: - Data Manipulation Methods

extension AllCategoriesViewController{
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
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
            
        }
        
    }
    
    func didFailGettingGetCatListDataWithError(error: String) {
        print("Error with GetCatListDataManager : \(error)")
    }
    
}
