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
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var key = ""
    
    var peers : [JSON]?
    
    var selectedPeerIndex : Int?
    
    var setPeerCallback : ((_ type : String , _ newPeerId : String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        searchView.layer.cornerRadius = 8
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //MARK: - Actions
    
    @IBAction func otmenaButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func listUpdateButtonPressed(_ sender: UIButton) {
        
        ExportPeersDataManager(delegate: self).getExportPeersData(key: key)
        
    }
    
}

//MARK: - ExportPeersDataManagerDelegate

extension PeerViewController : ExportPeersDataManagerDelegate{
    
    func didGetExportPeersData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                peers = data["peers"].arrayValue
                
                tableView.reloadData()
                
            }else{
                
                showSimpleAlertWithOkButton(title: "Ошибка обновления страницы", message: nil)
                
            }
            
        }
        
    }
    
    func didFailGettingExportPeersDataWithError(error: String) {
        print("Error with ExportPeersDataManager : \(error)")
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
        
        guard let peers = peers else { return cell }
        
        cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
        
        setUpPeerCell(cell: cell, data: peers[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let id = peers?[indexPath.row]["peer_id"].stringValue{
            
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
