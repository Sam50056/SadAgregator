//
//  VendorRevsViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.02.2021.
//

import UIKit
import SwiftyJSON

class VendorRevsViewController: UITableViewController {
    
    var key = ""
    
    var vendId : String?
    
    var page = 1
    
    var getVendRevsPagingDataManager = GetVendRevsPagingDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getVendRevsPagingDataManager.delegate = self
        
        guard let vendId = vendId else {return}
        
        getVendRevsPagingDataManager.getGetVendRevsPagingData(key: key, vendId: vendId, page: page)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        
        return cell
        
    }
    
}

//MARK: - GetVendRevsPagingDataManagerDelegate

extension VendorRevsViewController : GetVendRevsPagingDataManagerDelegate{
    
    func didGetGetVendRevsPagingData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingGetVendRevsPagingDataWithError(error: String) {
        print("Error with GetVendRevsPagingDataManager : \(error)")
    }
    
}
