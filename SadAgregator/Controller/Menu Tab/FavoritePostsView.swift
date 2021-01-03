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
    
    var postsArray = [JSON]()
    
    var selectedVendId : String?
    
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
    
    override func viewDidLoad() {
        
        loadUserData()
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        tableView.separatorStyle = .none
        
        myPostsDataManager.delegate = self
        
        myPostsDataManager.getMyPostsData(key: key, page: page)
        
    }
    
    //MARK: - Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let post = postsArray[indexPath.row]
        
        setUpPostCell(cell: cell, data: post, index: indexPath.row)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.postHeight
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
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int){
        
        cell.photoDelegate = self
        
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
        
    }
    
}

//MARK: - PhotoCollectionViewCellDelegate stuff

extension FavoritePostsViewController : PhotoCollectionViewCellDelegate{
    
    func didTapOnCell(index: Int, images: [String]) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        vc.selectedImageIndex = index
        
        vc.images = images
        
        presentHero(vc, navigationAnimationType: .fade)
        
    }
    
}


//MARK: - MyVendorsDataManagerDelegate

extension FavoritePostsViewController : MyPostsDataManagerDelegate {
    
    func didGetMyPostsData(data: JSON) {
        
        DispatchQueue.main.async {
            
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

