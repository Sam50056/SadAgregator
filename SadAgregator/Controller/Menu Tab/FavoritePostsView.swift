//
//  FavoritePostsView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.12.2020.
//

import SwiftUI
import UIKit
import SwiftyJSON
import RealmSwift

//MARK: - ViewController Representable

struct FavoritePostsView : UIViewControllerRepresentable{
    
    func makeUIViewController(context: Context) -> FavoritePostsViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoritePostsVC") as! FavoritePostsViewController
        
    }
    
    func updateUIViewController(_ uiViewController: FavoritePostsViewController, context: Context) {
        
    }
    
}

//MARK: - ViewController

class FavoritePostsViewController : UITableViewController {
    
    let realm = try! Realm()
    
    var key = ""
    
    var isLogged = false
    
    lazy var myPostsDataManager = MyPostsDataManager()
    
    var page = 1
    var rowForPaggingUpdate : Int = 10
    
    var favoritePostsData : JSON?
    
    var postsArray = [JSON]()
    
    var selectedVendId : String?
    
    var selectedPointId : String?
    
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
    
    var images : Array<[String]> {
        get{
            var thisArray = Array<[String]>()
            
            for post in postsArray {
                
                let imagesForThisPost = post["images"].arrayValue
                
                var stringImagesForThisPost = [String]()
                
                for image in imagesForThisPost {
                    stringImagesForThisPost.append(image["img"].stringValue)
                }
                
                thisArray.append(stringImagesForThisPost)
            }
            
            return thisArray
        }
    }
    
    var selectedPostId = ""
    
    var searchText = ""
    
    override func viewDidLoad() {
        
        loadUserData()
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCell")
        
        tableView.separatorStyle = .none
        
        myPostsDataManager.delegate = self
        
        myPostsDataManager.getMyPostsData(key: key, page: page)
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPoint"{
            
            guard let selectedPointId = selectedPointId else {return}
            
            let destinationVC = segue.destination as! PointViewController
            
            destinationVC.thisPointId = selectedPointId
            
        }else if segue.identifier == "goToVend"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
        }else if segue.identifier == "goSearch" {
            
            let destinationVC = segue.destination as! SearchViewController
            
            destinationVC.searchText = searchText
            
        }
        
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count == 0 ? 1 : postsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if postsArray.isEmpty{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            
            (cell as! EmptyTableViewCell).label.text = "Вы еще не добавили публикаций в избранное"
            
            return cell
            
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let post = postsArray[indexPath.row]
        
        setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: indexPath.row, export: favoritePostsData?["export"])
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (postsArray.count == 0) ? ((UIScreen.main.bounds.height / 2)) : K.postHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 9
            
            myPostsDataManager.getMyPostsData(key: key, page: page)
            
            print("Done a request for page: \(page)")
            
        }
        
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
        
        cell.soobshitButtonCallback = { [self] in
            
            GetPostActionsDataManager(delegate: self).getGetPostActionsData(key: key, postId: postId)
            
            selectedPostId = postId
            
        }
        
        cell.vendorLabelButtonCallBack = { [self] in
            
            selectedPointId = data["point_id"].stringValue
            
            self.performSegue(withIdentifier: "goToPoint", sender: self)
            
        }
        
        cell.byLabelButtonCallback = { [self] in
            
            selectedVendId = data["vendor_id"].stringValue
            
            self.performSegue(withIdentifier: "goToVend", sender: self)
            
        }
        
        cell.peerButtonCallback = { [self] in
            
            ExportPeersDataManager(delegate: self).getExportPeersData(key: key)
            
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

//MARK: - PostCellCollectionViewActionsDelegate stuff

extension FavoritePostsViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnOptionCell(option: String) {
        
        searchText = option
        
        performSegue(withIdentifier: "goSearch", sender: self)
        
    }
    
    func didTapOnImageCell(index: Int, images: [String]) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        vc.selectedImageIndex = index
        
        vc.images = images
        
        presentHero(vc, navigationAnimationType: .fade)
        
    }
    
}

//MARK: -  GetPostActionsDataManagerDelegate Stuff

extension FavoritePostsViewController : GetPostActionsDataManagerDelegate{
    
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

extension FavoritePostsViewController : SetPostActionsDataManagerDelegate{
    
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

extension FavoritePostsViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        favoritePostsData!["export"]["type"].stringValue = newType
                        
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

//MARK: - MyVendorsDataManagerDelegate

extension FavoritePostsViewController : MyPostsDataManagerDelegate {
    
    func didGetMyPostsData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.favoritePostsData = data
            
            self.postsArray.append(contentsOf: data["posts"].arrayValue)
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingMyPostsDataWithError(error: String) {
        print("Error with MyPostsDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension FavoritePostsViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}

