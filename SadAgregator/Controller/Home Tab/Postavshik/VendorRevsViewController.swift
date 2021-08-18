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
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "revCell")
        tableView.register(UINib(nibName: "RatingTableViewCellWithImages", bundle: nil), forCellReuseIdentifier: "revCellWithImages")
        
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
        rowForPaggingUpdate = 15
        
        revsArray.removeAll()
        
        showSimpleCircleAnimation(activityController: activityController)
        
        getVendRevsPagingDataManager.getGetVendRevsPagingData(key: key, vendId: vendId, page: page)
        
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
            
            getVendRevsPagingDataManager.getGetVendRevsPagingData(key: key, vendId: thisVendId!, page: page)
            
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

extension VendorRevsViewController : GetVendRevsPagingDataManagerDelegate{
    
    func didGetGetVendRevsPagingData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            revsArray.append(contentsOf: data["revs"].arrayValue)
            
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
