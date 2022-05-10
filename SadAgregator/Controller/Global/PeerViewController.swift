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
    
    var catWorkDomain = ""
    
    var exportPeersDataManager = ExportPeersDataManager()
    
    var peers : [JSON]?
    
    var page = 1
    var rowForPaggingUpdate : Int = 15
    
    var selectedPeerIndex : Int?
    
    var setPeerCallback : ((_ type : String , _ newPeerId : String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        searchView.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        
        exportPeersDataManager.delegate = self
        
        searchTextField.addTarget(self, action: #selector(searchTextFieldValueChanged(_:)), for: .editingChanged)
        
    }
    
    //MARK: - Functions
    
    func update(){
        
        exportPeersDataManager.getExportPeersData(domain: catWorkDomain, key: key, query: searchTextField.text ?? "" , page: page)
        
    }
    
    //MARK: - Actions
    
    @IBAction func otmenaButtonPressed(_ sendxer: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func listUpdateButtonPressed(_ sender: UIButton) {
        
        refreshAlbsData()
        
    }
    
    @IBAction func searchTextFieldValueChanged(_ sender : UITextField){
        
        guard let _ = sender.text else {return}
        
        page = 1
        rowForPaggingUpdate = 15
        
        peers?.removeAll()
        
        tableView.reloadData()
        
        update()
        
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
        return peers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard peers != nil , !peers!.isEmpty else {return cell}
        
        cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
        
        setUpPeerCell(cell: cell, data: peers![indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let id = peers?[indexPath.row]["peer_id"].stringValue{
            
            selectedPeerIndex = indexPath.row
            
            SetDefaultPeerDataManager(delegate: self).getSetDefaultPeerData(key: key, peerId: id)
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 15
            
            update()
            
            print("Done a request for page: \(page)")
            
        }
        
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
        
        catWorkDomain = userDataObject.first!.catWork
        
    }
    
}

//MARK: - ExportPeersDataManager

extension PeerViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            stopSimpleCircleAnimation(activityController: activityController)
            
            if data["result"].intValue == 1{
                
                guard peers != nil else {return}
                
                peers!.append(contentsOf: data["peers"].arrayValue)
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingExportPeersDataWithError(error: String) {
        print("Error with ExportPeersDataManager : \(error)")
    }
    
}
