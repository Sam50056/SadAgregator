//
//  SearchViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.11.2020.
//

import UIKit
import SwiftyJSON

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let key = UserDefaults.standard.string(forKey: "key")!
    
    var searchText : String = ""
    var page : Int = 1
    var rowForPaggingUpdate : Int = 10
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSearchPageDataManager.delegate = self
        
        searchView.layer.cornerRadius = 10
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.text = searchText
        
        getSearchPageDataManager.getSearchPageData(key: key, query: searchText, page: page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Поиск"
        
    }
    
}

//MARK: - GetSearchPageDataManagerDelegate Stuff

extension SearchViewController : GetSearchPageDataManagerDelegate {
    
    func didGetSearchPageData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.postsArray.append(contentsOf: data["posts"].arrayValue)
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingSearchPageData(error: String) {
        print("Error with GetSearchPageDataManager: \(error)")
    }
    
}

//MARK: - UITableView Stuff

extension SearchViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (hintCellShouldBeShown ? 1 : 0) + postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        var indexForPosts : Int
        
        if hintCellShouldBeShown{
            
            if indexPath.row == 0 {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
                
                setUpHintCell(cell: cell)
                
                return cell
            }
            
            indexForPosts = indexPath.row - 1
        }else {indexForPosts = indexPath.row}
        
        cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let post = postsArray[indexForPosts]
        
        setUpPostCell(cell: cell as! PostTableViewCell, data: post, index: indexForPosts)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var indexForPosts : Int
        
        if hintCellShouldBeShown{
            
            if indexPath.row == 0 {
                return 50
            }
            
            indexForPosts = indexPath.row - 1
            
        }else{indexForPosts = indexPath.row}
        
        if options[indexForPosts].count > 4{
            return 500
        }
        
        if options.count > 6 {
            return 560
        }
        
        return 460
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == rowForPaggingUpdate{

            page += 1
            
            rowForPaggingUpdate += 9
            
            getSearchPageDataManager.getSearchPageData(key: key, query: searchText, page: page)
            
            print("Done a request for page: \(page)")
            
        }

    }
    
    @IBAction func removeHintCell(_ sender : Any) {
        
        hintCellShouldBeShown = false
        
        tableView.reloadData()
        
    }
    
    //MARK: - Cell SetUp
    
    func setUpHintCell(cell : UITableViewCell){
        
        if let closeButton = cell.viewWithTag(3) as? UIButton {
            closeButton.addTarget(self, action: #selector(removeHintCell(_: )), for: .touchUpInside)
        }
        
    }
    
    func setUpPostCell(cell: PostTableViewCell , data : JSON, index : Int){
        
        cell.vendorLabel.text = data["vendor_capt"].stringValue
        
        cell.byLabel.text = data["by"].stringValue
        
        cell.priceLabel.text = "\(data["price"].stringValue) руб"
        
        let sizesArray = sizes[index]
        let optionsArray = options[index]
        let imagesArray = images[index]
        
        cell.sizes = sizesArray
        cell.options = optionsArray
        cell.images = imagesArray
        
    }
    
}
