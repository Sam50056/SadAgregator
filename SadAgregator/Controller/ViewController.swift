//
//  ViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.11.2020.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    let key = UserDefaults.standard.string(forKey: "key")
    
    var checkKeysDataManager = CheckKeysDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkKeysDataManager.delegate = self
        
        checkKeysDataManager.getKeysData(key: key)
    }
    
    
}

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
            
            let action = UIAlertAction(title: "Ok", style: .default) { (_) in
                
                alertController.dismiss(animated: true, completion: nil)
                
            }
            
            alertController.addAction(action)
            
        }
        
    }
    
    func didFailGettingCheckKeysData(error: String) {
        print("Error with CheckKeysDataManager: \(error)")
    }
    
}
