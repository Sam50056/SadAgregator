//
//  VendorBrokerRevsViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.02.2021.
//

import UIKit
import SwiftyJSON
import Cosmos

class VendorBrokerRevsViewController: UITableViewController {
    
    var key = ""
    
    var thisVendId : String?
    var thisBrokerId : String?
    
    var page = 1
    var rowForPaggingUpdate = 15
    
    lazy var getVendRevsPagingDataManager = GetVendRevsPagingDataManager()
    lazy var brokersGetBrokerRevsPagginationDataManager = BrokersGetBrokerRevsPagginationDataManager()
    
    var revsArray = [JSON]()
    
    let activityController = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "revCell")
        tableView.register(UINib(nibName: "RatingTableViewCellWithImages", bundle: nil), forCellReuseIdentifier: "revCellWithImages")
        
        getVendRevsPagingDataManager.delegate = self
        brokersGetBrokerRevsPagginationDataManager.delegate = self
        
        refreshControl = UIRefreshControl()
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        
        refresh(self)
        
    }
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender : AnyObject){
        
        if let vendId = thisVendId{
            
            page = 1
            rowForPaggingUpdate = 15
            
            revsArray.removeAll()
            
            showSimpleCircleAnimation(activityController: activityController)
            
            getVendRevsPagingDataManager.getGetVendRevsPagingData(key: key, vendId: vendId, page: page)
            
        }else if let brokerId = thisBrokerId {
            
            page = 1
            rowForPaggingUpdate = 15
            
            revsArray.removeAll()
            
            showSimpleCircleAnimation(activityController: activityController)
            
            brokersGetBrokerRevsPagginationDataManager.getBrokersGetBrokerRevsPagginationData(key: key, id: brokerId, page: page)
            
        }
        
       
        
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return revsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let rev = revsArray[indexPath.row]
        
        let imgs = rev["imgs"].arrayValue
        
        if imgs.isEmpty{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "revCell", for: indexPath)
            
            setUpRevCell(cell: cell as! RatingTableViewCell, data: rev)
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "revCellWithImages", for: indexPath)
            
            setUpRevCell(cell: cell as! RatingTableViewCellWithImages, data: rev)
            
        }
        
        return cell
        
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            if let vendId = thisVendId {
                getVendRevsPagingDataManager.getGetVendRevsPagingData(key: key, vendId: vendId, page: page)
            }else if let brokerId = thisBrokerId{
                brokersGetBrokerRevsPagginationDataManager.getBrokersGetBrokerRevsPagginationData(key: key, id: brokerId, page: page)
            }
            
           
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
    //MARK: - Cell Setup
    
    func setUpRevCell(cell : RatingTableViewCell, data : JSON){
        
        cell.authorLabel.text = data["author"].stringValue
        
        cell.ratingView.rating = Double(data["rate"].stringValue)!
        
        let rateText = data["text"].stringValue
        
        let rateTextWithoutBr = rateText.replacingOccurrences(of: "<br>", with: "\n")
        
        cell.textView.text = rateTextWithoutBr
        
        cell.dateLabel.text = data["dt"].stringValue
        
    }
    
    func setUpRevCell(cell : RatingTableViewCellWithImages, data : JSON){
        
        cell.authorLabel.text = data["author"].stringValue
        
        cell.ratingView.rating = Double(data["rate"].stringValue)!
        
        let rateText = data["text"].stringValue
        
        let rateTextWithoutBr = rateText.replacingOccurrences(of: "<br>", with: "\n")
        
        cell.textView.text = rateTextWithoutBr
        
        cell.dateLabel.text = data["dt"].stringValue
        
        let images =  data["imgs"].arrayValue.map({ jsonImage in
            return jsonImage.stringValue
        })
        
        cell.images = images
        
        cell.imageSelected = { [weak self] index in
            
            let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
            
            galleryVC.selectedImageIndex = index
            
            galleryVC.images = images.map({ img in
                PostImage(image: img, imageId: "")
            })
            
            galleryVC.sizes = []
            
            galleryVC.simplePreviewMode = true
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self?.presentHero(navVC, navigationAnimationType: .fade)
            
            
        }
        
    }
    
}

//MARK: - GetVendRevsPagingDataManagerDelegate

extension VendorBrokerRevsViewController : GetVendRevsPagingDataManagerDelegate{
    
    func didGetGetVendRevsPagingData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.revsArray.append(contentsOf: data["revs"].arrayValue)
            
            self?.tableView.reloadData()
            
            self?.stopSimpleCircleAnimation(activityController: self!.activityController)
            
            self?.refreshControl!.endRefreshing()
            
        }
        
    }
    
    func didFailGettingGetVendRevsPagingDataWithError(error: String) {
        print("Error with GetVendRevsPagingDataManager : \(error)")
    }
    
}

//MARK: - BrokersGetBrokerRevsPagginationDataManager

extension VendorBrokerRevsViewController : BrokersGetBrokerRevsPagginationDataManagerDelegate{
    
    func didGetBrokersGetBrokerRevsPagginationData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.revsArray.append(contentsOf: data["revs"].arrayValue)
            
            self?.tableView.reloadData()
            
            self?.stopSimpleCircleAnimation(activityController: self!.activityController)
            
            self?.refreshControl!.endRefreshing()
            
        }
        
    }
    
    func didFailGettingBrokersGetBrokerRevsPagginationDataWithError(error: String) {
        print("Error with BrokersGetBrokerRevsPagginationDataManager : \(error)")
    }
    
}
