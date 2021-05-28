//
//  PeerViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.01.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class PeerViewController: UIViewController{
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var searchTextField : UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityController = UIActivityIndicatorView()
    
    let realm = try! Realm()
    
    var key = ""
    
    var peers : [JSON]?{
        didSet{
            filteredPeers = peers
        }
    }
    
    var filteredPeers : [JSON]?
    
    var selectedPeerIndex : Int?
    
    var setPeerCallback : ((_ type : String , _ newPeerId : String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        searchView.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldValueChanged(_:)), for: .editingChanged)
        
    }
    
    //MARK: - Actions
    
    @IBAction func otmenaButtonPressed(_ sendxer: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func listUpdateButtonPressed(_ sender: UIButton) {
        
        refreshAlbsData()
        
    }
    
    @IBAction func searchTextFieldValueChanged(_ sender : UITextField){
        
        guard let searchText = sender.text , let peers = peers else {return}
        
        if searchText == ""{
            
            filteredPeers = peers
            
        }else{
            
            var newArray = [JSON]()
            
            peers.forEach { peer in
                if peer["capt"].stringValue.lowercased().contains(searchText.lowercased()){
                    newArray.append(peer)
                }
            }
            
            filteredPeers = newArray
            
        }
        
        tableView.reloadData()
        
    }
    
}

//MARK: - RefreshAlbsDataManager

extension PeerViewController : RefreshAlbsDataManagerDelegate{
    
    func refreshAlbsData(){
        
        RefreshAlbsDataManager(delegate: self).getRefreshAlbsData(key: key)
        
        showSimpleCircleAnimation(activityController: activityController)
        
    }
    
    func didGetRefreshAlbsData(data: JSON) {
        
        DispatchQueue.main.async {
            self.checkAlbumRefreshProgress()
        }
        
    }
    
    func didFailGettingRefreshAlbsDataWithError(error: String) {
        print("Error with RefreshAlbsDataManager : \(error)")
    }
    
}

//MARK: - AlbumsInProgressDataManager

extension PeerViewController : AlbumsInProgressDataManagerDelegate{
    
    func checkAlbumRefreshProgress(){
        AlbumsInProgressDataManager(delegate: self).getAlbumsInProgressData(key: key)
    }
    
    func didGetAlbumsInProgressData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                self.stopSimpleCircleAnimation(activityController: self.activityController)
                
                self.dismiss(animated: true, completion: nil)
                
            }else{
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                    self.checkAlbumRefreshProgress()
                }
            }
            
        }
        
    }
    
    func didFailGettingAlbumsInProgressDataWithError(error: String) {
        print("Error with AlbumsInProgressDataManager : \(error)")
    }
    
}

//MARK: - SetDefaultPeerDataManagerDelegate

extension PeerViewController : SetDefaultPeerDataManagerDelegate{
    
    func didGetSetDefaultPeerData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                guard let setPeerCallback = setPeerCallback , let peers = peers , let selectedPeerIndex  = selectedPeerIndex else {return}
                
                let newType = peers[selectedPeerIndex]["type"].stringValue
                
                //                print("New Type : \(newType)")
                
                setPeerCallback(newType, peers[selectedPeerIndex]["peer_id"].stringValue)
                
                self.selectedPeerIndex = nil
                
            }
            
        }
        
    }
    
    func didFailGettingSetDefaultPeerDataWithError(error: String) {
        print("Error with SetDefaultPeerDataManager : \(error)")
    }
    
}

//MARK: - Table View Stuff

extension PeerViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPeers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard let peers = filteredPeers else { return cell }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
        
        setUpPeerCell(cell: cell, data: peers[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let id = filteredPeers?[indexPath.row]["peer_id"].stringValue{
            
            selectedPeerIndex = indexPath.row
            
            SetDefaultPeerDataManager(delegate: self).getSetDefaultPeerData(key: key, peerId: id)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Cell Set Up
    
    func setUpPeerCell(cell : UITableViewCell, data : JSON){
        
        if let imageView = cell.viewWithTag(1) as? UIImageView,
           let label = cell.viewWithTag(2) as? UILabel{
            
            let type = data["type"].stringValue
            
            imageView.image = type == "vk" ? UIImage(named: "vk") : UIImage(named: "odno")
            
            imageView.layer.cornerRadius = 8
            
            label.text = data["capt"].stringValue
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension PeerViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
