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
    
    var summ : String? {
        didSet{
            
            if summ != nil , summ != "" {
                
                var newItemsArray = [TableViewItem]()
                
                newItemsArray.append(TableViewItem(firstText: "Сумма", secondText: summ! + " руб"))
                
                tableViewItems = newItemsArray
                
                tableView.reloadData()
                
            }
            
        }
    }
    
    var clientName : String? {
        didSet{
            tableView.reloadData()
        }
    }
    
    var clientId : String?
    
    var comment : String? {
        didSet{
            tableView.reloadData()
        }
    }
    
    var pid : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var dt : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var clientSelected : ((String) -> ())?
    
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

//MARK: - Actions

extension PaymentTableViewCell{
    
    @objc func clientCellTapped(_ sender : UIButton){
        
        guard let clientId = clientId else {return}
        
        clientSelected?(clientId)
        
    }
    
}

//MARK: - UITableView

extension PaymentTableViewCell : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return pid == "" ? 0 : 1
        case 1:
            return clientName == "" ? 0 : 1
        case 2:
            return tableViewItems.count
        case 3:
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
            
            guard let pid = pid else { return cell }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! PaymentTableViewCellTableViewCell
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.font = UIFont.systemFont(ofSize: 15)
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.textColor = .systemBlue
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.text = pid
            
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.font = UIFont.systemFont(ofSize: 15)
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.textColor = .systemGray
            
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.text = dt ?? ""
            
        case 1:
            
            guard let name = clientName else {return cell}
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.textLabel?.text = name
            
            let button = UIButton(frame: cell.contentView.frame)
            
            cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(button)
            
            NSLayoutConstraint.activate([button.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor), button.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),button.topAnchor.constraint(equalTo: cell.contentView.topAnchor),button.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)])
            
            button.addTarget(self, action: #selector(clientCellTapped(_:)), for: .touchUpInside)
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
            
            let item = tableViewItems[indexPath.row]
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.text = item.firstText
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.text = item.secondText
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
            
            (cell as! PaymentTableViewCellEditTableViewCell).textField.placeholder = "Редактировать"
            
            (cell as! PaymentTableViewCellEditTableViewCell).bgView.layer.cornerRadius = 6
            
            (cell as! PaymentTableViewCellEditTableViewCell).bgView.backgroundColor = UIColor(named: "gray")
            
            (cell as! PaymentTableViewCellEditTableViewCell).textField.text = comment
            
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
