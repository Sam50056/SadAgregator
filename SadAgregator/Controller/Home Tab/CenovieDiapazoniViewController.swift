//
//  CenovieDiapazoniViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.05.2021.
//

import UIKit
import SwiftyJSON

class CenovieDiapazoniViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private var purchasesZonesPriceDataManager = PurchasesZonesPriceDataManager()
    
    private var key = ""
    
    private var zones = [Zone]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            key = "part_2_test"
            
            purchasesZonesPriceDataManager.delegate = self
            
            purchasesZonesPriceDataManager.getPurchasesZonesPrice(key: key)
            
            tableView.delegate = self
            tableView.dataSource = self
            
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Диапазоны наценки"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusTapped(_:)))
        
    }
    
}

//MARK: - Actions

extension CenovieDiapazoniViewController {
    
    @IBAction func plusTapped(_ sender : Any){
        
        navigationController?.popViewController(animated: true)
        
    }
    
}

//MARK: - TableView Stuff

extension CenovieDiapazoniViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "diapazonCell", for: indexPath)
        
        if let otLabel = cell.viewWithTag(1) as? UILabel ,
           let doLabel = cell.viewWithTag(2) as? UILabel,
           let nacenkaLabel = cell.viewWithTag(3) as? UILabel,
           let okruglenieLabel = cell.viewWithTag(4) as? UILabel ,
           let fixNadbavkaLabel = cell.viewWithTag(5) as? UILabel {
            
            let zone = zones[indexPath.row]
            
            otLabel.text = zone.from + " руб."
            
            doLabel.text = zone.to + " руб."
            
            nacenkaLabel.text = zone.marge
            
            okruglenieLabel.text = zone.trunc
            
            fixNadbavkaLabel.text = zone.fix
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - PurchasesZonesPriceDataManagerDelegate

extension CenovieDiapazoniViewController : PurchasesZonesPriceDataManagerDelegate{
    
    func didGetPurchasesZonesPrice(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let jsonZones = data["zones"].arrayValue
                
                var newZones = [Zone]()
                
                for jsonZone in jsonZones{
                    
                    let zone = Zone(id: jsonZone["zone_id"].stringValue, from: jsonZone["from"].stringValue, to: jsonZone["to"].stringValue, marge: jsonZone["marge"].stringValue, fix: jsonZone["fix"].stringValue, trunc: jsonZone["trunc"].stringValue)
                    
                    newZones.append(zone)
                    
                }
                
                zones = newZones
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesZonesPriceWithError(error: String) {
        print("Error with PurchasesZonesPriceDataManager : \(error)")
    }
    
}

//MARK: - Zone

extension CenovieDiapazoniViewController {
    
    private struct Zone{
        
        let id : String
        let from : String
        let to : String
        let marge : String
        let fix : String
        let trunc : String
        
    }
    
}
