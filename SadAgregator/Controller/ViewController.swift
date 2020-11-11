//
//  ViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.11.2020.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    
    var checkKeysDataManager = CheckKeysDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkKeysDataManager.delegate = self
        
        checkKeysDataManager.getKeysData()
    }
    
    
}

extension ViewController : CheckKeysDataManagerDelegate {
    
    func didGetCheckKeysData(data: JSON) {
        
        if let safeKey = data["key"].string {
            
            print("Key: \(safeKey)")
            
            UserDefaults.standard.set(safeKey, forKey: "key") //Saving the key to UserDefaults
            
        }
        
    }
    
    func didFailGettingCheckKeysData(error: String) {
        print("Error with CheckKeysDataManager: \(error)")
    }
    
}
