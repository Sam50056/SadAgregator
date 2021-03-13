//
//  ClientViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.03.2021.
//

import UIKit
import SwiftyJSON

class ClientViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var hideLabel :  UILabel?
    private var hideLabelImageView : UIImageView?
    
    private var isInfoShown = true
    
    var thisClientId : String?
    
    private var clientDataManager = ClientDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "PurchaseTableViewCell", bundle: nil), forCellReuseIdentifier: "purchaseCell")
        
        if let thisClientId = thisClientId{
            clientDataManager.getClientData(key: "part_2_test", clientId: thisClientId)
        }
        
    }
    
}

//MARK: - TableView Stuff

extension ClientViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return isInfoShown ? 3 : 0
        case 2:
            return 0
        case 3:
            return 1
        case 4:
            return 5
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let section = indexPath.section
        
        switch section{
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
            
            if let hideLabel = cell.viewWithTag(1) as? UILabel,
               let hideLabelImageView = cell.viewWithTag(2) as? UIImageView{
                
                hideLabel.text = isInfoShown ? "Скрыть" : "Показать"
                
                hideLabelImageView.image = isInfoShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
                
                self.hideLabel = hideLabel
                
                self.hideLabelImageView = hideLabelImageView
                
            }
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            if let firstLabel = cell.viewWithTag(1) as? UILabel ,
               let secondLabel = cell.viewWithTag(2) as? UILabel{
                
                firstLabel.text = "Клиенты"
                
                secondLabel.text = "3"
            }
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! PurchaseTableViewCell
            
        //            (cell  as! PurchaseTableViewCell).client = clients[indexPath.row]
        
        default:
            return cell
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 0{
            
            isInfoShown.toggle()
            
            tableView.reloadSections([1], with: .top)
            
            hideLabel?.text = isInfoShown ? "Скрыть" : "Показать"
            hideLabelImageView?.image = isInfoShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            
            UIView.animate(withDuration: 0.3){ [self] in
                view.layoutIfNeeded()
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4{
            return 85 - 20
        }
        return K.simpleHeaderCellHeight
    }
    
}

//MARK: - ClientDataManagerDelegate

extension ClientViewController : ClientDataManagerDelegate{
    
    func didGetClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let clientHeaderData = data["client_header"]
                
                if let name = clientHeaderData["name"].string , name != ""{
                    navigationItem.title = name
                }
                
            }
            
        }
        
    }
    
    func didFailGettingClientDataWithError(error: String) {
        print("Error with ClientDataManager : \(error)")
    }
    
}
