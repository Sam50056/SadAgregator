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
    
    private var purchasesDelZonePriceDataManager = PurchasesDelZonePriceDataManager()
    
    private var key = ""
    
    private var zones = [PurchaseZone]()
    
    var doneChanges : (() -> Void)?
    
    var hasDoneChanges = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key = "part_2_test"
        
        purchasesZonesPriceDataManager.delegate = self
        
        update()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Диапазоны наценки"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusTapped(_:)))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if hasDoneChanges{
            doneChanges?()
        }
        
    }
    
}

//MARK: - Functions

extension CenovieDiapazoniViewController{
    
    func update() {
        purchasesZonesPriceDataManager.getPurchasesZonesPrice(key: key)
    }
    
}

//MARK: - Actions

extension CenovieDiapazoniViewController {
    
    @IBAction func plusTapped(_ sender : Any){
        
        let createDiapazonVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateDiapazonVC") as! CreateDiapazonViewController
        
        createDiapazonVC.createdDiapazon = { [self] in
            hasDoneChanges = true
            update()
        }
        
        navigationController?.pushViewController(createDiapazonVC, animated: true)
        
    }
    
}

//MARK: - TableView Stuff

extension CenovieDiapazoniViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "diapazonCell", for: indexPath)
        
        if let firstTitleLabel = cell.viewWithTag(1) as? UILabel,
           let firstValueLabel = cell.viewWithTag(2) as? UILabel ,
           let secondTitleLabel = cell.viewWithTag(3) as? UILabel,
           let secondValueLabel = cell.viewWithTag(4) as? UILabel,
           let nacenkaLabel = cell.viewWithTag(5) as? UILabel,
           let okruglenieLabel = cell.viewWithTag(6) as? UILabel ,
           let fixNadbavkaTextLabel = cell.viewWithTag(7) as? UILabel,
           let fixNadbavkaLabel = cell.viewWithTag(8) as? UILabel,
           let okruglenieTextLabel = cell.viewWithTag(9) as? UILabel{
            
            let zone = zones[indexPath.row]
            
            if zone.to == "0" || zone.from == "0"{
                
                if zone.to == "0"{
                    firstTitleLabel.text = "от"
                    firstValueLabel.text = zone.from + " руб."
                }else if zone.from == "0"{
                    firstTitleLabel.text = "до"
                    firstValueLabel.text = zone.to + " руб."
                }
                
                secondTitleLabel.text = ""
                secondValueLabel.text = ""
                
            }else{
                
                firstTitleLabel.text = "от"
                firstValueLabel.text = zone.from + " руб."
                secondTitleLabel.text = "до"
                secondValueLabel.text = zone.to + " руб."
                
            }
            
            nacenkaLabel.text = zone.marge + (zone.marge.contains("%") ? "" : " руб.")
            
            okruglenieLabel.text = zone.trunc
            
            if zone.marge.contains("%"){
                fixNadbavkaTextLabel.isHidden = false
                fixNadbavkaLabel.isHidden = false
                fixNadbavkaLabel.text = zone.fix
                okruglenieLabel.isHidden = false
                okruglenieTextLabel.isHidden = false
            }else{
                fixNadbavkaTextLabel.isHidden = true
                fixNadbavkaLabel.text = ""
                fixNadbavkaLabel.isHidden = true
                okruglenieLabel.isHidden = true
                okruglenieTextLabel.isHidden = true
            }
            
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let zone = zones[indexPath.row]
        
        if zone.marge.contains("%") , zone.fix != "0"{
            return 150
        }else if !zone.marge.contains("%"){
            return 80
        }else{
            return 115
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [self] action, view, completion in
            
            let createDiapazonVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateDiapazonVC") as! CreateDiapazonViewController
            
            createDiapazonVC.createdDiapazon = { [self] in
                hasDoneChanges = true
                update()
            }
            
            createDiapazonVC.thisZone = zones[indexPath.row]
            
            navigationController?.pushViewController(createDiapazonVC, animated: true)
            
            completion(true)
            
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] action, view, completion in
            
            let zone = zones[indexPath.row]
            
            purchasesDelZonePriceDataManager.getPurchasesDelZonePriceData(key: key, zoneId: zone.id) { data, error in
                
                if let error = error , data == nil {
                    print("Error with purchasesDelZonePriceDataManager : \(error)")
                    return
                }
                
                guard let data = data else {return}
                
                if data["result"].intValue == 1{
                    
                    DispatchQueue.main.async { [self] in
                        
                        hasDoneChanges = true
                        
                        zones.remove(at: indexPath.row)
                        
                        completion(true)
                        
                        tableView.reloadSections([0], with: .automatic)
                        
                    }
                    
                }
                
            }
            
        }
        
        editAction.backgroundColor = .gray
        editAction.image = UIImage(systemName: "pencil")
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        
    }
    
}

//MARK: - PurchasesZonesPriceDataManagerDelegate

extension CenovieDiapazoniViewController : PurchasesZonesPriceDataManagerDelegate{
    
    func didGetPurchasesZonesPrice(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let jsonZones = data["zones"].arrayValue
                
                var newZones = [PurchaseZone]()
                
                for jsonZone in jsonZones{
                    
                    let zone = PurchaseZone(id: jsonZone["zone_id"].stringValue, from: jsonZone["from"].stringValue, to: jsonZone["to"].stringValue, marge: jsonZone["marge"].stringValue, fix: jsonZone["fix"].stringValue, trunc: jsonZone["trunc"].stringValue)
                    
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

struct PurchaseZone{
    
    let id : String
    let from : String
    let to : String
    let marge : String
    let fix : String
    let trunc : String
    
}
