//
//  TovarImageSearchTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.07.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class TovarImageSearchTableViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    
    private let realm = try! Realm()
    
    private var key = ""
    private var isLogged = false
    
    private var imageHashSearch = ""
    private var imageHashServer = ""
    
    var imageHashText : String?
    
    var thisPointId : String?
    
    var thisPid : String?
    
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
    
    var vibratTochkaInPost : ((String) -> Void)?
    
    var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.frame)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        loadUserData()
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCell")
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        activityController.center = view.center
        
        imageSearch()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "?????????? ??????????"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(closeBarButtonTapped(_:)))
        
    }
    
    //MARK: - Actions
    
    @IBAction func closeBarButtonTapped(_ sender : Any){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData != nil ? !postsArray.isEmpty ? postsArray.count : 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if postsArray.isEmpty{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            
            (cell as! EmptyTableViewCell).label.text = "?????? ??????????????????????"
            
            (cell as! EmptyTableViewCell).emptyImageView.image = UIImage(systemName: "photo")
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let post = postsArray[indexPath.row]
            
            setUpPostCell(cell: cell , data: post, index: indexPath.row, export: nil)
            
            return cell
            
        }
        
    }
    
    //MARK: - Cell Set up
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int, export : JSON?){
        
        let postId = data["id"].stringValue
        
        //Change the bottom panel a bit (because we're in tovar)
        
        cell.soobshitButton.isHidden = true
        
        let newBottomViewFrame = CGRect(x: 0, y: 0, width: cell.bottomView.bounds.width + 30, height: cell.bottomView.bounds.height)
        
        let newBottomView = UIView(frame: newBottomViewFrame)
        cell.bottomView.addSubview(newBottomView)
        
        newBottomView.backgroundColor = UIColor(named: "whiteblack")
        
        let leftButton = UIButton()
        let rightButton = UIButton()
        
        let stackView = UIStackView(arrangedSubviews: [leftButton , rightButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.frame = newBottomViewFrame
        newBottomView.addSubview(stackView)
        
        leftButton.setTitle("?????????????? ?????? ??????????", for: .normal)
        rightButton.setTitle("????. ???????? ?? VK", for: .normal)
        leftButton.setTitleColor(.systemBlue, for: .normal)
        rightButton.setTitleColor(.systemBlue, for: .normal)
        
        rightButton.addTarget(cell, action: #selector(cell.smotretVkPostPressed(_:)), for: .touchUpInside)
        leftButton.addTarget(cell, action: #selector(cell.vibratTochkuTapped(_:)), for: .touchUpInside)
        
        cell.vibratTochkuButtonCallback = { [weak self] in
            
            guard let _ = self!.thisPointId , let thisPid = self!.thisPid else {return}
            
            AssemblySellThisPointDataManager().getAssemblySellThisPointData(key: self!.key, itemId: thisPid, postId: postId) { sellData, error in
                
                DispatchQueue.main.async {
                    
                    if let error = error , sellData == nil {
                        print("Error with : \(error)")
                        return
                    }
                    
                    if sellData!["result"].intValue == 1{
                        
                        self?.vibratTochkaInPost?(postId)
                        
                    }else{
                        
                        self!.showSimpleAlertWithOkButton(title: "????????????", message: sellData!["msg"].stringValue)
                        
                    }
                    
                }
                
            }
            
        }
        
        cell.delegate = self
        
        cell.key = key
        
        cell.id = postId
        
        let like = data["like"].stringValue
        cell.like = like
        
        like == "0" ? (cell.likeButtonImageView.image = UIImage(systemName: "heart")) : (cell.likeButtonImageView.image = UIImage(systemName: "heart.fill"))
        
        cell.vkLinkUrlString = data["vk_post"].stringValue
        
        cell.byLabelButtonCallback = { [self] in
            
            let selectedVendId = data["vendor_id"].stringValue
            
            let vendorVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VendorVC") as! PostavshikViewController
            
            vendorVC.thisVendorId = selectedVendId
            
            navigationController?.pushViewController(vendorVC, animated: true)
            
        }
        
        cell.showDescription = false
        
        cell.postDescription = data["text"].stringValue != "" ?  data["text"].stringValue : nil
        
        cell.vendorLabel.text = data["vendor_capt"].stringValue
        
        cell.byLabel.text = data["by"].stringValue
        
        let price = data["price"].stringValue
        cell.priceLabel.text = "\(price == "0" ? "" : price + " ??????")"
        
        cell.postedLabel.text = data["posted"].stringValue
        
        let sizesArray = sizes[index]
        let imagesArray = images[index]
        
        cell.sizes = sizesArray
        cell.options = []
        cell.images = imagesArray
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (postsArray.count == 0) ? ((UIScreen.main.bounds.height / 2)) : K.postHeight
    }
    
}

//MARK: - PostCellCollectionViewActionsDelegate stuff

extension TovarImageSearchTableViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnOptionCell(option: String) {
        //No option cells in this VC bitch
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
        
        showSimpleCircleAnimation(activityController: activityController)
        
        SearchImageDataManager(delegate : self).getSearchImageData(urlString: imageHashSearch, ACRop: "", ANOCrop: imageHashText)
        
    }
    
    func didGetSearchImageData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            searchData = data
            
            postsArray = data["posts"].arrayValue
            
            tableView.reloadData()
            
            stopSimpleCircleAnimation(activityController: activityController)
            
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
