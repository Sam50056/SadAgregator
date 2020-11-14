//
//  ViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.11.2020.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    let key = UserDefaults.standard.string(forKey: "key")
    
    var checkKeysDataManager = CheckKeysDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkKeysDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        searchView.layer.cornerRadius = 8
        
        checkKeysDataManager.getKeysData(key: key)
    }
    
    
}

//MARK: - CheckKeysDataManagerDelegate stuff
extension ViewController : CheckKeysDataManagerDelegate {
    
    func didGetCheckKeysData(data: JSON) {
        
        if let safeKey = data["key"].string {
            
            print("Key: \(safeKey)")
            
            UserDefaults.standard.set(safeKey, forKey: "key") //Saving the key to UserDefaults
            
        }
        
        //Message field from api
        let message = data["message"]
        
        //Checking if it is there or not
        if message.exists() {
            
            guard let id = message["id"].int ,
                  let title = message["title"].string,
                  let msg = message["msg"].string else {
                return
            }
            
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Закрыть", style: .cancel) { (_) in
                
                guard let key = self.key else {return}
                
                MessageReadedDataManager().getMessageReadedData(key: key, messageId: String(id))
                
                alertController.dismiss(animated: true, completion: nil)
                
            }
            
            alertController.addAction(action)
            
        }
        
    }
    
    func didFailGettingCheckKeysData(error: String) {
        print("Error with CheckKeysDataManager: \(error)")
    }
    
}


//MARK: - UITableView stuff
extension ViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.row {
        
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "generalPostsPhotosCell", for: indexPath)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "linesActivityCell", for: indexPath)
        case 3...7:
            cell = tableView.dequeueReusableCell(withIdentifier: "activityLineCell", for: indexPath)
        default:
            print("")
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->    CGFloat {
        
        if indexPath.row == 1{
            
            return 126
            
        }
        
        return 50
        
    }
    
}
