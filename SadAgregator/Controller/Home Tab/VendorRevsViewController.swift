//
//  VendorRevsViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.02.2021.
//

import UIKit
import SwiftyJSON
import Cosmos

class VendorRevsViewController: UITableViewController {
    
    var key = ""
    
    var thisVendId : String?
    
    var page = 1
    var rowForPaggingUpdate = 15
    
    var getVendRevsPagingDataManager = GetVendRevsPagingDataManager()
    
    var revsArray = [JSON]()
    
    let activityController = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        
        getVendRevsPagingDataManager.delegate = self
        
        refreshControl = UIRefreshControl()
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        
        refresh(self)
        
    }
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender : AnyObject){
        
        guard let vendId = thisVendId else {return}
        
        page = 1
        
        showSimpleCircleAnimation(activityController: activityController)
        
        getVendRevsPagingDataManager.getGetVendRevsPagingData(key: key, vendId: vendId, page: page)
        
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return revsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "revCell", for: indexPath)
        
        let rev = revsArray[indexPath.row]
        
        setUpRevCell(cell: cell, data: rev)
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            getVendRevsPagingDataManager.getGetVendRevsPagingData(key: key, vendId: thisVendId!, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
    //MARK: - Cell Setup
    
    func setUpRevCell(cell : UITableViewCell, data : JSON){
        
        if let authorLabel = cell.viewWithTag(1) as? UILabel,
           let ratingView = cell.viewWithTag(2) as? CosmosView,
           let textView = cell.viewWithTag(3) as? UITextView,
           let dateLabel = cell.viewWithTag(4) as? UILabel{
            
            authorLabel.text = data["author"].stringValue
            
            ratingView.rating = Double(data["rate"].stringValue)!
            
            let rateText = data["text"].stringValue
            
            let rateTextWithoutBr = rateText.replacingOccurrences(of: "<br>", with: "\n")
            
            textView.text = rateTextWithoutBr
            
            dateLabel.text = data["dt"].stringValue
            
        }
        
    }
    
}

//MARK: - GetVendRevsPagingDataManagerDelegate

extension VendorRevsViewController : GetVendRevsPagingDataManagerDelegate{
    
    func didGetGetVendRevsPagingData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            revsArray = data["revs"].arrayValue
            
            tableView.reloadData()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
            refreshControl!.endRefreshing()
            
            //Show table view to the user
            if tableView.isHidden {
                tableView.isHidden = false
            }
            
        }
        
    }
    
    func didFailGettingGetVendRevsPagingDataWithError(error: String) {
        print("Error with GetVendRevsPagingDataManager : \(error)")
    }
    
}
