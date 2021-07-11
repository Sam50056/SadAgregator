//
//  TovarImageSearchTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.07.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class TovarImageSearchTableViewController: UITableViewController {
    
    private let realm = try! Realm()
    
    private var key = ""
    private var isLogged = false
    
    private var imageHashSearch = ""
    private var imageHashServer = ""
    
    var imageHashText : String?
    
    private var searchData : JSON?
    
    private var postsArray = [JSON]()
    
    private var selectedVendId : String?
    
    private var selectedPointId : String?
    
    private var sizes : Array<[String]> {
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
    
    private var options : Array<[String]> {
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
    
    private var images : Array<[PostImage]> {
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
    
    private let activityController = UIActivityIndicatorView()
    
    private var selectedPostId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        imageSearch()
        
    }
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let post = postsArray[indexPath.row]
        
        setUpPostCell(cell: cell , data: post, index: indexPath.row, export: nil)
        
        return cell
        
    }
    
    //MARK: - Cell Set up
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int, export : JSON?){
        
        cell.delegate = self
        
        cell.key = key
        
        let postId = data["id"].stringValue
        
        cell.id = postId
        
        let like = data["like"].stringValue
        cell.like = like
        
        like == "0" ? (cell.likeButtonImageView.image = UIImage(systemName: "heart")) : (cell.likeButtonImageView.image = UIImage(systemName: "heart.fill"))
        
        cell.vkLinkUrlString = data["vk_post"].stringValue
        
        //        cell.soobshitButtonCallback = { [self] in
        //
        //            GetPostActionsDataManager(delegate: self).getGetPostActionsData(key: key, postId: postId)
        //
        //            selectedPostId = postId
        //
        //        }
        
        //        cell.vendorLabelButtonCallBack = { [self] in
        //
        //            selectedPointId = data["point_id"].stringValue
        //
        //            self.performSegue(withIdentifier: "goToPoint", sender: self)
        //
        //        }
        
        cell.byLabelButtonCallback = { [self] in
            
            selectedVendId = data["vendor_id"].stringValue
            
            self.performSegue(withIdentifier: "goToVend", sender: self)
            
        }
        
        //        cell.peerButtonCallback = { [self] in
        //
        //            guard isLogged else {
        //
        //                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
        //
        //                return
        //            }
        //
        //            showSimpleCircleAnimation(activityController: activityController)
        //
        //            ExportPeersDataManager(delegate: self).getExportPeersData(key: key)
        //
        //        }
        
        //        if thisPeerId != cell.peerId {
        //            cell.vigruzitLabel.text = "Выгрузить"
        //            cell.peerId = thisPeerId
        //            doneArray.removeAll()
        //        }
        //
        //        if doneArray.contains(postId){
        //            cell.vigruzitLabel.text = "Готово"
        //        }else{
        //            cell.vigruzitLabel.text = "Выгрузить"
        //        }
        
        //        cell.vigruzitButtonCallback = { [self] in
        //
        //            guard isLogged else {
        //
        //                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
        //
        //                return
        //            }
        //
        //            if favoritePostsData!["export"]["fast"].intValue == 0{
        //
        //                let editVigruzkaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditVigruzkaVC") as! EditVigruzkaViewController
        //
        //                editVigruzkaVC.thisPostId = postId
        //
        //                editVigruzkaVC.toExpQueueDataManagerCallback = {
        //
        //                    cell.vigruzitLabel.text = "Готово"
        //                    doneArray.append(postId)
        //
        //                }
        //
        //                present(editVigruzkaVC, animated: true, completion: nil)
        //
        //            }else{
        //
        //                ToExpQueueDataManager().getToExpQueueData(key: key, postId: postId, completionHandler: { data , error in
        //
        //                    DispatchQueue.main.async {
        //
        //                        if error != nil , data == nil {
        //                            print("Error with ToExpQueueDataManager : \(error!)")
        //                            return
        //                        }
        //
        //                        if data!["result"].intValue == 1{
        //
        //                            cell.vigruzitLabel.text = "Готово"
        //                            doneArray.append(postId)
        //
        //                            print("ToExpQueueDataManager Request Sent")
        //
        //                        }else{
        //
        //                            showSimpleAlertWithOkButton(title: "Ошибка отправки запроса", message: nil, dismissButtonText: "Закрыть")
        //
        //                        }
        //
        //                    }
        //
        //                })
        //
        //            }
        //
        //        }
        
        //        if let export = export{
        //
        //            let exportType = export["type"].stringValue
        //
        //            cell.vigruzitImageView.image = exportType == "vk" ? UIImage(named: "vk") : UIImage(named: "odno")
        //
        //        }
        
        cell.showDescription = false
        
        cell.postDescription = data["text"].stringValue != "" ?  data["text"].stringValue : nil
        
        cell.vendorLabel.text = data["vendor_capt"].stringValue
        
        cell.byLabel.text = data["by"].stringValue
        
        let price = data["price"].stringValue
        cell.priceLabel.text = "\(price == "0" ? "" : price + " руб")"
        
        cell.postedLabel.text = data["posted"].stringValue
        
        let sizesArray = sizes[index]
        //        let optionsArray = options[index]
        let imagesArray = images[index]
        
        cell.sizes = sizesArray
        cell.options = []
        cell.images = imagesArray
        
        //        isLogged ? (cell.likeButtonImageView.isHidden = false) : (cell.likeButtonImageView.isHidden = true)
        
        //        !isLogged ? (cell.vigruzitView.alpha = 0.6) : (cell.vigruzitView.alpha = 1)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (postsArray.count == 0) ? ((UIScreen.main.bounds.height / 2)) : K.postHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //        if indexPath.row == rowForPaggingUpdate{
        //
        //            page += 1
        //
        //            rowForPaggingUpdate += 16
        //
        //            myPostsDataManager.getMyPostsData(key: key, page: page)
        //
        //            print("Done a request for page: \(page)")
        //
        //        }
        
    }
    
}

//MARK: - PostCellCollectionViewActionsDelegate stuff

extension TovarImageSearchTableViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnOptionCell(option: String) {
        
        //        searchText = option
        //
        //        performSegue(withIdentifier: "goSearch", sender: self)
        
    }
    
    func didTapOnImageCell(index: Int, images: [PostImage], sizes : [String]) {
        
        let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        galleryVC.selectedImageIndex = index
        
        galleryVC.images = images
        
        galleryVC.sizes = sizes
        
        let navVC = UINavigationController(rootViewController: galleryVC)
        
        presentHero(navVC, navigationAnimationType: .fade)
        
    }
    
}


//MARK: - Image Search Stuff

extension TovarImageSearchTableViewController : SearchImageDataManagerDelegate{
    
    func imageSearch(){
        
        guard let imageHashText = imageHashText , imageHashSearch != "" , imageHashServer != "" else {return}
        
        SearchImageDataManager(delegate : self).getSearchImageData(urlString: imageHashSearch, ACRop: "", ANOCrop: imageHashText)
        
    }
    
    func didGetSearchImageData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            searchData = data
            
            postsArray = data["posts"].arrayValue
            
            tableView.reloadSections([0], with: .automatic)
            
            //            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingSearchImageDataWithError(error: String) {
        print("Error with  SearchImageDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension TovarImageSearchTableViewController {
    
    func loadUserData (){
        
        let userDataObjects = realm.objects(UserData.self)
        
        key = userDataObjects.first!.key
        
        isLogged = userDataObjects.first!.isLogged
        
        imageHashServer = userDataObjects.first!.imageHashServer
        imageHashSearch = userDataObjects.first!.imageHashSearch
        
    }
    
}
