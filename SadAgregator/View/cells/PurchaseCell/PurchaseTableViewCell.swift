//
//  PurchaseTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.03.2021.
//

import UIKit
import SwiftyJSON

class PurchaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    private var tableViewItems = [TableViewItem]()
    
    var thisItem : PurchaseTableViewCellItem?{
        didSet{
            
            guard let thisItem = thisItem else {return}
            
            if thisItem.status != ""{
                
                tableViewItems.append(TableViewItem(firstText: "Статус", secondText: thisItem.status))
                
            }
            
            tableViewItems.append(contentsOf: thisItem.money)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "PurchaseTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        tableView.register(UINib(nibName: "PurchaseTableViewCellTitleCellTableViewCell", bundle: nil), forCellReuseIdentifier: "titleLabel")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        //        tableViewItems.append(TableViewItem(firstText: "Баланс", secondText: "12323"))
        //        tableViewItems.append(TableViewItem(firstText: "В закупке", secondText: "33"))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}

//MARK: - TableView

extension PurchaseTableViewCell : UITableViewDelegate , UITableViewDataSource{
    
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
        
        guard let thisItem = thisItem else {return cell}
        
        if indexPath.section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "titleLabel", for: indexPath)
            
            (cell as! PurchaseTableViewCellTitleCellTableViewCell).captLabel.text = thisItem.capt
            (cell as! PurchaseTableViewCellTitleCellTableViewCell).dateLabel.text = thisItem.date
            
            (cell as! PurchaseTableViewCellTitleCellTableViewCell).captLabel.font = UIFont.boldSystemFont(ofSize: 17)
            
            (cell as! PurchaseTableViewCellTitleCellTableViewCell).dateLabel.font = UIFont.boldSystemFont(ofSize: 16)
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! PurchaseTableViewCellTableViewCell
            
            let item = tableViewItems[indexPath.row]
            
            (cell as! PurchaseTableViewCellTableViewCell).firstLabel.text = item.firstText
            (cell as! PurchaseTableViewCellTableViewCell).secondLabel.text = item.secondText
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 26
        }else{
            return 22
        }
    }
    
}

//MARK: - TableViewItem Struct

extension PurchaseTableViewCell {
    
    struct TableViewItem {
        
        var firstText : String
        var secondText : String
        
    }
    
}

struct PurchaseTableViewCellItem {
    
    var id : String
    
    var capt : String
    var date : String
    
    var status : String
    
    var money : [PurchaseTableViewCell.TableViewItem] = [PurchaseTableViewCell.TableViewItem]()
    
}
