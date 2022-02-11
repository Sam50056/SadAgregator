//
//  VendorPostsTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.01.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class VendorPostsTableViewController: UITableViewController, GetVendPostsPaggingDataManagerDelegate {
    
    let realm = try! Realm()
    
    var thisVendId : String?
    
    var key = ""
    var isLogged = false
    
    var page = 1
    var rowForPaggingUpdate = 0
    
    lazy var getVendPostsPaggingDataManager = GetVendPostsPaggingDataManager()
    
    var pageData : JSON?
    
    var postsArray = [JSON]()
    
    var sizes : Array<[String]> {
        get{
            var thisArray = Array<[String]>()
            
            for post in postsArray {
                
                let sizesForThisPost = post["sizes"].arrayValue
                
                var stringSizesForThisPost = [String]()
                
                for size in sizesForThisPost {
                    stringSizesForThisPost.append(size.stringValue)
                }
                
                thisArray.append(stringSizesForThisPost)
            }
            
            return thisArray
        }
    }
    
    var options : Array<[String]> {
        get{
            var thisArray = Array<[String]>()
            
            for post in postsArray {
                
                let optionsForThisPost = post["options"].arrayValue
                
                var stringOptionsForThisPost = [String]()
                
                for option in optionsForThisPost {
                    stringOptionsForThisPost.append(option.stringValue)
                }
                
                thisArray.append(stringOptionsForThisPost)
            }
            
            return thisArray
        }
    }
    
    var images : Array<[PostImage]> {
        get{
            var thisArray = Array<[PostImage]>()
            
            for post in postsArray {
                
                let jsonImagesForThisPost = post["images"].arrayValue
                
                var ImagesForThisPost = [PostImage]()
                
                for image in jsonImagesForThisPost {
                    ImagesForThisPost.append(PostImage(image: image["img"].stringValue, imageId: image["img_id"].stringValue))
                }
                
                thisArray.append(ImagesForThisPost)
            }
            
            return thisArray
        }
    }
    
    let activityController = UIActivityIndicatorView()
    
    var selectedPostId = ""
    
    var thisPeerId = ""
    
    var doneArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        tableView.separatorStyle = .none
        
        refreshControl = UIRefreshControl()
        
        //        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl!) // not required when using UITableViewController
        
        getVendPostsPaggingDataManager.delegate = self
        
        refresh(self)
        
    }
    
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        if let thisVendId = thisVendId {
            
            postsArray.removeAll()
            
            page = 1
            rowForPaggingUpdate = 0
            
            getVendPostsPaggingDataManager.getGetVendPostsPaggingData(key: key, vendId: thisVendId, page: page)
            
            showSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    //MARK: - GetVendPostsPaggingDataManager
    
    func didGetGetVendPostsPaggingData(data: JSON) {
        
        DispatchQueue.main.async{ [self] in
            
            pageData = data
            
            postsArray.append(contentsOf: data["posts"].arrayValue)
            
            if page == 1{
                rowForPaggingUpdate += data["posts"].arrayValue.count - 1
            }else{
                rowForPaggingUpdate += data["posts"].arrayValue.count
            }
            
            tableView.reloadData()
            
            refreshControl!.endRefreshing()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingGetVendPostsPaggingDataWithError(error: String) {
        print("Error with GetVendPostsPaggingDataManager : \(error)")
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if !postsArray.isEmpty{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let post = postsArray[indexPath.row]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: indexPath.row, export: pageData?["export"])
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            getVendPostsPaggingDataManager.getGetVendPostsPaggingData(key: key, vendId: thisVendId!, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
    
    //MARK: - Cell Set Up
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int, export : JSON?){
        
        cell.key = key
        
        let postId = data["id"].stringValue
        
        cell.id = postId
        
        let like = data["like"].stringValue
        cell.like = like
        
        like == "0" ? (cell.likeButtonImageView.image = UIImage(systemName: "heart")) : (cell.likeButtonImageView.image = UIImage(systemName: "heart.fill"))
        
        cell.vkLinkUrlString = data["vk_post"].stringValue
        
        cell.didTapOnImageCell = { [weak self] index, images , sizes in
            
            let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
            
            galleryVC.selectedImageIndex = index
            
            galleryVC.images = images
            
            galleryVC.sizes = sizes
            
            galleryVC.key = self?.key ?? ""
            
            galleryVC.price = data["price"].stringValue
            
            galleryVC.point = data["vendor_capt"].stringValue
            
            galleryVC.forceClosed = { [weak self] in
                self?.tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: true)
            }
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self?.presentHero(navVC, navigationAnimationType: .fade)
            
        }
        
        cell.didTapOnOptionCell = { [weak self] option in
            
            let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SearchVC") as! SearchViewController
            
            searchVC.searchText = option
            
            self?.navigationController?.pushViewController(searchVC, animated: true)
            
        }
        
        cell.soobshitButtonCallback = { [self] in
            
            GetPostActionsDataManager(delegate: self).getGetPostActionsData(key: key, postId: postId)
            
            selectedPostId = postId
            
        }
        
        cell.vendorLabelButtonCallBack = { [self] in
            
            let selectedPointId = data["point_id"].stringValue
            
            let pointVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PointVC") as! PointViewController
            
            pointVC.thisPointId = selectedPointId
            
            navigationController?.pushViewController(pointVC, animated: true)
            
        }
        
        cell.byLabelButtonCallback = { [self] in
            
            let selectedVendId = data["vendor_id"].stringValue
            
            let vendorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VendorVC") as! PostavshikViewController
            
            vendorVC.thisVendorId = selectedVendId
            
            navigationController?.pushViewController(vendorVC, animated: true)
            
        }
        
        cell.peerButtonCallback = { [self] in
            
            guard isLogged else {
                
                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                
                return
            }
            
            showSimpleCircleAnimation(activityController: activityController)
            
            ExportPeersDataManager(delegate: self).getExportPeersData(key: key)
            
        }
        
        if thisPeerId != cell.peerId {
            cell.vigruzitLabel.text = "Выгрузить"
            cell.peerId = thisPeerId
            doneArray.removeAll()
        }
        
        if doneArray.contains(postId){
            cell.vigruzitLabel.text = "Готово"
        }else{
            cell.vigruzitLabel.text = "Выгрузить"
        }
        
        cell.vigruzitButtonCallback = { [self] in
            
            guard isLogged else {
                
                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                
                return
            }
            
            if pageData!["export"]["fast"].intValue == 0{
                
                let editVigruzkaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditVigruzkaVC") as! EditVigruzkaViewController
                
                editVigruzkaVC.thisPostId = postId
                
                editVigruzkaVC.toExpQueueDataManagerCallback = {
                    
                    cell.vigruzitLabel.text = "Готово"
                    doneArray.append(postId)
                   
                }
                
                present(editVigruzkaVC, animated: true, completion: nil)
                
            }else{
                
                ToExpQueueDataManager().getToExpQueueData(key: key, postId: postId, completionHandler: { data , error in
                    
                    DispatchQueue.main.async {
                        
                        if error != nil , data == nil {
                            print("Error with ToExpQueueDataManager : \(error!)")
                            return
                        }
                        
                        if data!["result"].intValue == 1{
                            
                            cell.vigruzitLabel.text = "Готово"
                            doneArray.append(postId)
                            
                            print("ToExpQueueDataManager Request Sent")
                            
                        }else{
                            
                            showSimpleAlertWithOkButton(title: "Ошибка отправки запроса", message: nil, dismissButtonText: "Закрыть")
                            
                        }
                        
                    }
                    
                })
                
            }
            
        }
        
        if let export = export{
            
            let exportType = export["type"].stringValue
            
            cell.vigruzitImageView.image = exportType == "vk" ? UIImage(named: "vk") : UIImage(named: "odno")
            
        }
        
        cell.showDescription = false
        
        cell.postDescription = data["text"].stringValue != "" ?  data["text"].stringValue : nil
        
        cell.vendorLabel.text = data["vendor_capt"].stringValue
        
        cell.byLabel.text = data["by"].stringValue
        
        let price = data["price"].stringValue
        cell.priceLabel.text = "\(price == "0" ? "" : price + " руб")"
        
        cell.postedLabel.text = data["posted"].stringValue
        
        let sizesArray = sizes[index]
        let optionsArray = options[index]
        let imagesArray = images[index]
        
        cell.sizes = sizesArray
        cell.options = optionsArray
        cell.images = imagesArray
        
        isLogged ? (cell.likeButtonImageView.isHidden = false) : (cell.likeButtonImageView.isHidden = true)
        
        !isLogged ? (cell.vigruzitView.alpha = 0.6) : (cell.vigruzitView.alpha = 1)
        
    }
    
}

//MARK: -  GetPostActionsDataManagerDelegate Stuff

extension VendorPostsTableViewController : GetPostActionsDataManagerDelegate{
    
    func didGetGetPostActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let actionsArray = data["actions"].arrayValue
            
            showActionsSheet(actionsArray: actionsArray) { (action) in
                
                let actionid = (action["id"].stringValue)
                
                SetPostActionsDataManager(delegate: self).getSetPostActionsData(key: key, actionId: actionid, postId: selectedPostId)
                
            }
            
        }
        
    }
    
    func didFailGettingGetPostActionsDataWithError(error: String) {
        print("Error with  GetPostActionsDataManager : \(error)")
    }
    
}

//MARK: - SetPostActionsDataManagerDelegate

extension VendorPostsTableViewController : SetPostActionsDataManagerDelegate{
    
    func didGetSetPostActionsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            dismiss(animated: true, completion: nil)
            
            if let message = data["msg"].string{
                
                showSimpleAlertWithOkButton(title: message, message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingSetPostActionsDataWithError(error: String) {
        print("Error with SetPostActionsDataManager : \(error)")
    }
    
}

//MARK: - ExportPeersDataManager

extension VendorPostsTableViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            stopSimpleCircleAnimation(activityController: activityController)
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType , newPeerId) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        pageData!["export"]["type"].stringValue = newType
                        
                        thisPeerId = newPeerId
                        
                        tableView.reloadData()
                        
                    }
                    
                }
                
                present(peerVC, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingExportPeersDataWithError(error: String) {
        print("Error with ExportPeersDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension VendorPostsTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}

