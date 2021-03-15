//
//  PaymentTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import UIKit
import SwiftyJSON

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    var payment : JSON?{
        didSet{
            
            if let sum = payment?["summ"].string , sum != "" {
                
                tableViewItems.append(TableViewItem(firstText: "Сумма", secondText: sum))
                
            }
            
        }
    }
    
    private var tableViewItems = [TableViewItem]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "PaymentTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        tableView.register(UINib(nibName: "PaymentTableViewCellEditTableViewCell", bundle: nil), forCellReuseIdentifier: "editCell")
        
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: - UITableView

extension PaymentTableViewCell : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return payment?["pid"].stringValue == "" ? 0 : 1
        case 1:
            return payment?["client_name"].stringValue == "" ? 0 : 1
        case 2:
            return tableViewItems.count
        case 3:
            return payment?["comment"].stringValue == "" ? 0 : 1
        case 4:
            return 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        var cell = UITableViewCell()
        
        switch section {
        case 0:
            
            guard let pid = payment?["pid"].string else { return cell }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! PaymentTableViewCellTableViewCell
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.font = UIFont.systemFont(ofSize: 15)
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.textColor = .systemBlue
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.text = pid
            
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.font = UIFont.systemFont(ofSize: 15)
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.textColor = .systemGray
            
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.text = payment?["dt"].string ?? ""
            
        case 1:
            
            guard let name = payment?["client_name"].string else {return cell}
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.textLabel?.text = name
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
            
            let item = tableViewItems[indexPath.row]
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.text = item.firstText
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.text = item.secondText
            
        case 3:
            
            guard let comment = payment?["comment"].string else {return cell}
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.text = comment
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
            
            (cell as! PaymentTableViewCellEditTableViewCell).textField.placeholder = "Редактировать"
            
            (cell as! PaymentTableViewCellEditTableViewCell).bgView.layer.cornerRadius = 6
            
            (cell as! PaymentTableViewCellEditTableViewCell).bgView.backgroundColor = UIColor(named: "gray")
            
        default:
            return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            return 20
        case 1:
            return 30
        case 2:
            return 20
        case 3:
            return 30
        case 4:
            return 50
        default:
            return 0
        }
        
    }
    
}

//MARK: - TableViewItem Struct

extension PaymentTableViewCell {
    
    private struct TableViewItem {
        
        var firstText : String
        var secondText : String
        
    }
    
}

