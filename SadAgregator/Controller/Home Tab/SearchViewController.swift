//
//  SearchViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.11.2020.
//

import UIKit
import SwiftyJSON
import RealmSwift

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    let activityController = UIActivityIndicatorView()
    
    var key = ""
    
    var isLogged = false
    
    var imageHashSearch = ""
    var imageHashServer = ""
    
    var searchText : String = ""
    var imageHashText : String?
    
    var page : Int = 1
    var rowForPaggingUpdate : Int = 15
    
    var hintCellShouldBeShown = true
    
    lazy var getSearchPageDataManager = GetSearchPageDataManager()
    
    var searchData : JSON?
    
    var postsArray = [JSON]()
    
    var cntList : [JSON]?
    
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
    var selectedPointId = ""
    var selectedVendId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        getSearchPageDataManager.delegate = self
        
        searchView.layer.cornerRadius = 10
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.delegate = self
        
        searchTextField.text = searchText
        
        if imageHashText != nil{
            
            imageSearch()
            
        }else{
            getSearchPageDataManager.getSearchPageData(key: key, query: searchText, page: page)
        }
        
        showSimpleCircleAnimation(activityController: activityController)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Поиск"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUserData()
    }
    
}

//MARK: - Actions

extension SearchViewController {
    
    @IBAction func photoSearchButtonPressed(_ sender : UIButton){
        
        showImagePickerController(sourceType: .photoLibrary)
        
    }
    
}

//MARK: - UIImagePickerControlller

extension SearchViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let safeFileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL , imageHashServer != ""{
            
            SendFileDataManager(delegate: self).sendPhotoMultipart(urlString: imageHashServer, fileUrl: safeFileUrl)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - SendFileDataManagerDelegate

extension SearchViewController : SendFileDataManagerDelegate{
    
    func didGetSendPhotoData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let fullHash = data["hash"].stringValue
            
            imageHashText = fullHash
            
            imageSearch()
            
        }
        
    }
    
    func didFailGettingSendPhotoDataWithErorr(error: String) {
        print("Error with SendFileDataManager : \(error)")
    }
    
    
}

//MARK: - Image Search Stuff

extension SearchViewController : SearchImageDataManagerDelegate{
    
    func imageSearch(){
        
        guard let imageHashText = imageHashText , imageHashSearch != "" , imageHashServer != "" else {return}
        
        var aCrop = ""
        var aNoCrop = ""
        
        let indexOfDash = imageHashText.firstIndex(of: "-")!
        
        aNoCrop = String(imageHashText[imageHashText.startIndex..<indexOfDash])
        
        aCrop = String(imageHashText[indexOfDash..<imageHashText.endIndex])
        
        aCrop.removeFirst() //Remove "-" symbol
        
        print("A Crop : \(aCrop) , A No Crop : \(aNoCrop)")
        
        SearchImageDataManager(delegate : self).getSearchImageData(urlString: imageHashSearch, ACRop: aCrop, ANOCrop: aNoCrop)
        
    }
    
    func didGetSearchImageData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            searchData = nil
            
            postsArray = data["posts"].arrayValue
            
            cntList = nil
            
            tableView.reloadSections([0,1,2], with: .none)
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingSearchImageDataWithError(error: String) {
        print("Error with  SearchImageDataManager : \(error)")
    }
    
}

//MARK: - Segue Stuff

extension SearchViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToPoint"{
            
            let destinationVC = segue.destination as! PointViewController
            
            destinationVC.thisPointId = selectedPointId
            
        }else if segue.identifier == "goToVend"{
            
            let destinationVC = segue.destination as! PostavshikViewController
            
            destinationVC.thisVendorId = selectedVendId
            
        }
        
    }
    
}


//MARK: - Data Manipulation Methods

extension SearchViewController {
    
    func loadUserData (){
        
        let userDataObjects = realm.objects(UserData.self)
        
        key = userDataObjects.first!.key
        
        isLogged = userDataObjects.first!.isLogged
        
        imageHashServer = userDataObjects.first!.imageHashServer
        imageHashSearch = userDataObjects.first!.imageHashSearch
        
    }
    
}

//MARK: - GetSearchPageDataManagerDelegate Stuff

extension SearchViewController : GetSearchPageDataManagerDelegate {
    
    func didGetSearchPageData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            searchData = data
            
            postsArray.append(contentsOf: data["posts"].arrayValue)
            
            cntList = data["cnt_list"].arrayValue
            
            tableView.reloadSections([0,1,2], with: .none)
            
            stopSimpleCircleAnimation(activityController: activityController)
            
        }
        
    }
    
    func didFailGettingSearchPageData(error: String) {
        print("Error with GetSearchPageDataManager: \(error)")
    }
    
}

//MARK: - UITextField Stuff

extension SearchViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != ""{
            
            page = 1
            
            searchText = textField.text!
            
            postsArray.removeAll()
            
            getSearchPageDataManager.getSearchPageData(key: key, query: searchText, page: page)
            
        }
        
        return true 
        
    }
    
}

//MARK: - UITableView Stuff

extension SearchViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case 0:
            return cntList == nil ? 0 : 1
        case 1:
            return searchData?["help"] != nil ? (hintCellShouldBeShown ? 1 : 0) : 0
        case 2:
            return postsArray.count
            
        default:
            fatalError("Invalid section")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section{
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "searchResultsCell", for: indexPath)
            
            guard let cntList = cntList else { return cell }
            
            setUpSearchResultsCell(cell: cell, data: cntList)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
            
            guard let help = searchData?["help"] else {return cell}
            
            setUpHintCell(cell: cell, data: help)
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let post = postsArray[indexPath.row]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: indexPath.row , export: searchData?["export"])
            
        default:
            fatalError("Invalid Section")
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        
        case 0:
            
            return 40
            
        case 1:
            
            return K.simpleCellHeight
            
        case 2:
            
            return K.postHeight
            
        default:
            fatalError("Invalid Section")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            if let help = searchData?["help"] , let url = URL(string: help["url"].stringValue){
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard imageHashText == nil else {return}
        
        if indexPath.section == 2{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                getSearchPageDataManager.getSearchPageData(key: key, query: searchText, page: page)
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
    @IBAction func removeHintCell(_ sender : Any) {
        
        hintCellShouldBeShown = false
        
        tableView.reloadSections([1], with: .automatic)
        
    }
    
    //MARK: - Cell SetUp
    
    func setUpSearchResultsCell(cell : UITableViewCell , data : [JSON]){
        
        if let todayLabel = cell.viewWithTag(1) as? UILabel ,
           let yesterdaylabel = cell.viewWithTag(2) as? UILabel ,
           let othersLabel = cell.viewWithTag(3) as? UILabel{
            
            let cntList = data
            
            cntList.forEach { (item) in
                
                let itemType = item["type"].stringValue
                
                let vsegoText = item["cnt"].stringValue
                
                if vsegoText == "0"{
                    
                    todayLabel.text = ""
                    yesterdaylabel.text = "Нет результатов"
                    othersLabel.text = ""
                    
                }else{
                    
                    if itemType == "today"{
                        todayLabel.text = "Сегодня: \(item["cnt"].stringValue)"
                    }else if itemType == "ystd"{
                        yesterdaylabel.text = "Вчера: \(item["cnt"].stringValue)"
                    }else if itemType == "others"{
                        othersLabel.text = "Всего: \(vsegoText)"
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func setUpHintCell(cell : UITableViewCell , data : JSON){
        
        if let closeButton = cell.viewWithTag(3) as? UIButton,
           let label = cell.viewWithTag(2) as? UILabel{
            
            label.text = data["str"].stringValue
            
            closeButton.addTarget(self, action: #selector(removeHintCell(_: )), for: .touchUpInside)
            
        }
        
    }
    
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

extension SearchViewController : PostCellCollectionViewActionsDelegate{
    
    func didTapOnOptionCell(option: String) {
        
        postsArray.removeAll()
        
        cntList = nil
        
        searchText = option
        
        searchTextField.text = option
        
        tableView.reloadSections([0,2], with: .automatic)
        
        getSearchPageDataManager.getSearchPageData(key: key, query: option, page: page)
        
        self.tableView.setContentOffset( CGPoint(x: 0, y: 0) , animated: true)
        
    }
    
    func didTapOnImageCell(index: Int, images: [String]) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
        
        vc.selectedImageIndex = index
        
        vc.images = images
        
        presentHero(vc, navigationAnimationType: .fade)
        
    }
    
}

//MARK: -  GetPostActionsDataManagerDelegate Stuff

extension SearchViewController : GetPostActionsDataManagerDelegate{
    
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

extension SearchViewController : SetPostActionsDataManagerDelegate{
    
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

extension SearchViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let peerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PeerVC") as! PeerViewController
                
                peerVC.peers = data["peers"].array
                
                peerVC.setPeerCallback = { (newType) in
                    
                    peerVC.dismiss(animated: true) {
                        
                        searchData!["export"]["type"].stringValue = newType
                        
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
