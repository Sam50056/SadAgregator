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
    
    private var imageHashSearch = ""
    private var imageHashServer = ""
    
    var imageHashText : String?
    
    private var searchData : JSON?
    
    private var postsArray = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
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
        
        UITableViewCell()
        
    }
    
}
//MARK: - Image Search Stuff

extension TovarImageSearchTableViewController : SearchImageDataManagerDelegate{
    
    func imageSearch(){
        
        guard let imageHashText = imageHashText , imageHashSearch != "" , imageHashServer != "" else {return}
        
        //        var aCrop = ""
        //        var aNoCrop = ""
        //
        //        let indexOfDash = imageHashText.firstIndex(of: "-")!
        //
        //        aNoCrop = String(imageHashText[imageHashText.startIndex..<indexOfDash])
        //
        //        aCrop = String(imageHashText[indexOfDash..<imageHashText.endIndex])
        //
        //        aCrop.removeFirst() //Remove "-" symbol
        //
        //        print("A Crop : \(aCrop) , A No Crop : \(aNoCrop)")
        
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
        
        imageHashServer = userDataObjects.first!.imageHashServer
        imageHashSearch = userDataObjects.first!.imageHashSearch
        
    }
    
}
