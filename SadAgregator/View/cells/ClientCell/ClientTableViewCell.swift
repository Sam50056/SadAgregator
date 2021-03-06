//
//  ClientTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.03.2021.
//

import UIKit
import SwiftyJSON

class ClientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    private var tableViewItems = [TableViewItem]()
    
    var client : JSON?{
        didSet{
            
            if client?["balance"].stringValue != "" /*, client?["balance"].stringValue != "0"*/{
                
                tableViewItems.append(TableViewItem(firstText: "Баланс", secondText: (client?["balance"].stringValue)!))
                
            }
            
            if client?["in_process"].stringValue != "" , client?["in_process"].stringValue != "0"{
                
                tableViewItems.append(TableViewItem(firstText: "В закупке", secondText: (client?["in_process"].stringValue)!))
                
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ClientTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: - TableView

extension ClientTableViewCell : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else{
            return tableViewItems.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.section == 0{
            
            cell.textLabel?.text = client?["name"].stringValue
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ClientTableViewCellTableViewCell
            
            let item = tableViewItems[indexPath.row]
            
            (cell as! ClientTableViewCellTableViewCell).firstLabel.text = item.firstText
            (cell as! ClientTableViewCellTableViewCell).secondLabel.text = item.secondText
            
            if item.firstText == "Баланс" ,
               let balanceInt = Int(item.secondText),
               balanceInt < 0{
                (cell as! ClientTableViewCellTableViewCell).secondLabel.textColor = .red
            }else{
                (cell as! ClientTableViewCellTableViewCell).secondLabel.textColor = UIColor(named: "blackwhite")
            }
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 30
        }else{
            return 20
        }
    }
    
}

//MARK: - TableViewItem Struct

extension ClientTableViewCell {
    
    private struct TableViewItem {
        
        var firstText : String
        var secondText : String
        
    }
    
}
