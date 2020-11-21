//
//  LineViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.11.2020.
//

import UIKit
import SwiftyJSON

class LineViewController: UIViewController {
    
    
    let key = UserDefaults.standard.string(forKey: "key")!
    var thisLineId : String?
    
    lazy var activityLineDataManager = ActivityLineDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityLineDataManager.delegate = self
        
        if let safeId = thisLineId{
            activityLineDataManager.getActivityData(key: key, lineId: safeId)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }

}

extension LineViewController : ActivityLineDataManagerDelegate{
    
    func didGetActivityData(data: JSON) {
        
    }
    
    func didFailGettingActivityLineData(error: String) {
        print("Error with ActivityLineDataManager: \(error)")
    }
    
}
