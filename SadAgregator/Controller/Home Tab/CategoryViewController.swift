//
//  CategoryViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.02.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    let activityController = UIActivityIndicatorView()
    
    let realm = try! Realm()
    
    var key = ""
    
    var isLogged = false
    
    var categoryData : JSON?
    
    var postsArray = [JSON]()
    
    var page = 1
    var rowForPaggingUpdate : Int = 15
    
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
    
    var selectedLineId : String?
    var selectedPointId : String?
    var selectedVendId : String?
    
    var selectedPostId = ""
    
    var searchImageHash : String?
    
    var thisPeerId = ""
    
    var thisCatId : String?
    
    var getCatpageDataManager = GetCatpageDataManager()
    
    var filter = ""
    
    var filters = [String]() {
        didSet{
            
            if filters.isEmpty{
                filter = ""
                return
            }
            
            filter = "|"
            
            for i in filters{
                filter.append("\(i)|")
            }
            
            print("HELLO FILTER : \(filter)")
            
        }
    }
    
    var max = ""
    var min = ""
    
    var sizeFilters = [String]()
    var materialFilters = [String]()
    
    var filterBarButton = UIBarButtonItem()
    
    var shouldMakeRequest = false{
        didSet{
            if shouldMakeRequest{
                if let safeId = thisCatId{
                    
                    postsArray.removeAll()
                    
                    getCatpageDataManager.getGetCatpageData(key: key, catId: safeId, page: page, filter: filter, min : min, max: max)
                }
            }
        }
    }
    
    var requestTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        filterBarButton = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(filterButtonTapped))
        
        navigationItem.rightBarButtonItem = filterBarButton
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        
        getCatpageDataManager.delegate = self
        
        if let safeId = thisCatId{
            getCatpageDataManager.getGetCatpageData(key: key, catId: safeId, page: page)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserData()
    }
    
    @objc func filterButtonTapped(){
        
        let filterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterVC") as! FilterViewController
        
        filterVC.modalPresentationStyle = .custom
        filterVC.transitioningDelegate = self
        
        filterVC.materials = categoryData?["filter"]["materials"].arrayValue ?? [JSON]()
        filterVC.sizes = categoryData?["filter"]["sizes"].arrayValue ?? [JSON]()
        
        filterVC.selectedMaterials = materialFilters
        filterVC.selectedSizes = sizeFilters
        
        filterVC.min = min
        filterVC.max = max
        
        filterVC.filterItemSelected = { [self] item , type in
            
            //Stoping the timer when a new filter is selected , we give time to user to select something else
            requestTimer.invalidate()
            
            let id = item["v"].stringValue
            
            sortFilterByType(type , item: id)
            
            if filters.contains(id){
                filters.remove(at: filters.firstIndex(of: id)!)
            }else{
                filters.append(id)
            }
            
            //Start counting 1 second to make a request, but if the user selects another filter again , the timer will be invalidated above
            requestTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                
                shouldMakeRequest = true
                print("Hello Timer")
                
            }
            
        }
        
        filterVC.minMaxChanged = { [self] minVal , maxVal in
            
            //Stoping the timer when a new filter is selected , we give time to user to select something else
            requestTimer.invalidate()
            
            min = minVal
            max = maxVal
            
            //Start counting 1 second to make a request, but if the user selects another filter again , the timer will be invalidated above
            requestTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                
                shouldMakeRequest = true
                print("Hello Timer")
                
            }
            
        }
        
        filterVC.sbrositPressed = { [self] items , type in
            
            //Type = 0 means it's price stuff
            if type == 0 {
                min = ""
                max = ""
            }else{
                
                for item in items{
                    
                    sortFilterByType(type , item: item)
                    
                    if filters.contains(item){
                        filters.remove(at: filters.firstIndex(of: item)!)
                    }
                    
                }
                
            }
            
            if let safeId = thisCatId{
                
                postsArray.removeAll()
                
                getCatpageDataManager.getGetCatpageData(key: key, catId: safeId, page: page, filter: filter, min : min, max: max)
            }
            
        }
        
        present(filterVC, animated: true, completion: nil)
        
    }
    
    func sortFilterByType(_ type : Int, item : String){
        
        switch type {
        case 1:
            
            if materialFilters.contains(item){
                materialFilters.remove(at: materialFilters.firstIndex(of: item)!)
            }else{
                materialFilters.append(item)
            }
        case 2:
            
            if sizeFilters.contains(item){
                sizeFilters.remove(at: sizeFilters.firstIndex(of: item)!)
            }else{
                sizeFilters.append(item)
            }
        default:
            break
        }
        
    }
    
}

//MARK: - UIViewControllerTransitioningDelegate

extension CategoryViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let aboveViewControllerPresentationController = AboveViewControllerPresentationController(presentedViewController: presented, presenting: presenting)
        
        //        aboveViewControllerPresentationController.navBarHeightY = self.navigationController?.navigationBar.frame.maxY
        //        aboveViewControllerPresentationController.navBarHeight = self.navigationController?.navigationBar.frame.height
        
        var height : CGFloat = 430
        
        if(categoryData?["filter"]["materials"].arrayValue.isEmpty)!{
            height = height - 96
        }
        
        if (categoryData?["filter"]["sizes"].arrayValue.isEmpty)!{
            height = height - 96
        }
        
        aboveViewControllerPresentationController.height = height
        
        return aboveViewControllerPresentationController
        
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideDownPresentationController(isPresentation: true)
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return SlideDownPresentationController(isPresentation: false)
    }
    
}


//MARK: - Data Manipulation Methods

extension CategoryViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - GetCatpageDataManagerDelegate

extension CategoryViewController : GetCatpageDataManagerDelegate{
    
    func didGetGetCatpageData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if categoryData == nil { categoryData = data}
            
            postsArray.append(contentsOf: data["posts"].arrayValue)
            
            tableView.reloadData()
            
            //This is only available when page is 1 , that's why it's in the if block ))
            if page == 1 {
                navigationItem.title = data["cat_name"].stringValue == "" ? "Категория" : data["cat_name"].stringValue
            }
            
        }
        
    }
    
    func didFailGettingGetCatpageDataWithError(error: String) {
        print("Error with GetCatpageDataManager : \(error)")
    }
    
}

//MARK: - UITableView

extension CategoryViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard !postsArray.isEmpty else {return cell}
        
        cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let post = postsArray[indexPath.row]
        
        setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: indexPath.row, export: categoryData?["export"])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            if let safeId = thisCatId{
                getCatpageDataManager.getGetCatpageData(key: key, catId: safeId, page: page, filter: filter, min : min, max: max)
            }
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.postHeight
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
        }
        
        cell.vigruzitButtonCallback = { [self] in
            
            guard isLogged else {
                
                showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
                
                return
            }
            
            if categoryData?["export"]["fast"].intValue == 0{
                
                let editVigruzkaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditVigruzkaVC") as! EditVigruzkaViewController
                
                editVigruzkaVC.thisPostId = postId
                
                editVigruzkaVC.toExpQueueDataManagerCallback = {
                    
                    cell.vigruzitLabel.text = "Готово"
                    
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

//MARK: - PostCellCollectionViewActionsDelegate stuff

extension CategoryViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnOptionCell(option: String) {
        
        let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SearchVC") as! SearchViewController
        
        searchVC.searchText = option
        
        self.navigationController?.pushViewController(searchVC, animated: true)
        
    }
    
    func didTapOnImageCell(index: Int, images: [String]) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        vc.selectedImageIndex = index
        
        vc.images = images
        
        presentHero(vc, navigationAnimationType: .fade)
        
    }
    
}

//MARK: -  GetPostActionsDataManagerDelegate Stuff

extension CategoryViewController : GetPostActionsDataManagerDelegate{
    
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

extension CategoryViewController : SetPostActionsDataManagerDelegate{
    
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

extension CategoryViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            stopSimpleCircleAnimation(activityController: activityController)
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType , newPeerId) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        categoryData!["export"]["type"].stringValue = newType
                        
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
