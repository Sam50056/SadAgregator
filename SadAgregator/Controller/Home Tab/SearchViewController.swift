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
    
    var key = ""
    
    var isLogged = false
    
    var searchText : String = ""
    var page : Int = 1
    var rowForPaggingUpdate : Int = 15
    
    var hintCellShouldBeShown = true
    
    lazy var getSearchPageDataManager = GetSearchPageDataManager()
    
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
        
        getSearchPageDataManager.getSearchPageData(key: key, query: searchText, page: page)
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


//MARK: - Data Manipulation Methods

extension SearchViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - GetSearchPageDataManagerDelegate Stuff

extension SearchViewController : GetSearchPageDataManagerDelegate {
    
    func didGetSearchPageData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.postsArray.append(contentsOf: data["posts"].arrayValue)
            
            self.tableView.reloadSections([0,1], with: .none)
            
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case 0:
            return hintCellShouldBeShown ? 1 : 0
        case 1:
            return postsArray.count
            
        default:
            fatalError("Invalid section")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section{
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
            
            setUpHintCell(cell: cell)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            
            let post = postsArray[indexPath.row]
            
            setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: indexPath.row)
            
        default:
            fatalError("Invalid Section")
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        
        case 0:
            
            return K.simpleCellHeight
            
        case 1:
            
            return K.postHeight
            
        default:
            fatalError("Invalid Section")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
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
        
        tableView.reloadSections([0], with: .automatic)
        
    }
    
    //MARK: - Cell SetUp
    
    func setUpHintCell(cell : UITableViewCell){
        
        if let closeButton = cell.viewWithTag(3) as? UIButton {
            closeButton.addTarget(self, action: #selector(removeHintCell(_: )), for: .touchUpInside)
        }
        
    }
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int){
        
        cell.photoDelegate = self
        
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

extension SearchViewController : PhotoCollectionViewCellDelegate{
    
    func didTapOnCell(index: Int, images: [String]) {
        
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
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionsArray.forEach { (action) in
                
                let alertAction = UIAlertAction(title: action["capt"].stringValue, style: .default) { (_) in
                    
                    let actionid = (action["id"].stringValue)
                    
                    SetPostActionsDataManager(delegate: self).getSetPostActionsData(key: key, actionId: actionid, postId: selectedPostId)
                    
                }
                
                alertController.addAction(alertAction)
                
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
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
            
        }
        
    }
    
    func didFailGettingSetPostActionsDataWithError(error: String) {
        print("Error with SetPostActionsDataManager : \(error)")
    }
    
}


