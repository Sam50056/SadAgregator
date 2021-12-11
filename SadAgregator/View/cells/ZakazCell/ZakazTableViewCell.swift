//
//  ZakazTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.12.2021.
//

import UIKit

class ZakazTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    var thisZakaz : Zakaz?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ZakazTableViewCellHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        tableView.register(UINib(nibName: "ZakazTableViewCellCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        tableView.register(UINib(nibName: "ZakazTableViewCellImageViewTwoLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.isScrollEnabled = false
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

//MARK: - TableView

extension ZakazTableViewCell  : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let thisZakaz = thisZakaz else {return 0}
        
        if section == 0{
            return 1
        }else if section == 1 , !thisZakaz.clientBalance.isEmpty , thisZakaz.clientBalance != "0" {
            return 1
        }else if section == 2 , !thisZakaz.itemsCount.isEmpty , thisZakaz.itemsCount != "0"{
            return 1
        }else if section == 3 , !thisZakaz.deliveryType.isEmpty{
            return 1
        }else if section == 4 , !thisZakaz.statusName.isEmpty{
            return 1
        }else if section == 5 , !thisZakaz.comment.isEmpty{
            return 1
        }else if section == 6{
            return 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let thisZakaz = thisZakaz else {return UITableViewCell()}
        
        let section = indexPath.section
        let _ = indexPath.row
        
        if section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! ZakazTableViewCellHeaderTableViewCell
            
            cell.idLabel.text = "#" + thisZakaz.id
            cell.dateLabel.text = thisZakaz.date
            cell.nameLabel.text = thisZakaz.clientName
            cell.summLabel.text = thisZakaz.orderSumm + " руб."
            
            return cell
            
        }else if section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCellImageViewTwoLabelTableViewCell
            
            cell.zakazImageView.image = UIImage(systemName: "rublesign.circle.fill")
            
            cell.zakazImageView.tintColor = .systemGray
            
            cell.label1.text = "Баланс клиента"
            cell.label2.text = thisZakaz.clientBalance + " руб."
            
            cell.label1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.textColor = .systemGray
            cell.label2.textColor = thisZakaz.clientBalance.contains("-") ? .systemRed : .systemGreen
            
            return cell
            
        }else if section == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCellImageViewTwoLabelTableViewCell
            
            cell.zakazImageView.image = UIImage(systemName: "cart")
            
            cell.zakazImageView.tintColor = .systemGray
            
            cell.label1.text = "Товары"
            cell.label2.text = thisZakaz.itemsCount
            
            cell.label1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.textColor = .systemGray
            
            return cell
            
        }else if section == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCellImageViewTwoLabelTableViewCell
            
            cell.zakazImageView.image = UIImage(systemName: "paperplane.fill")
            
            cell.zakazImageView.tintColor = .systemGray
            
            cell.label1.text = thisZakaz.deliveryType
            cell.label2.text = thisZakaz.deliveryName
            
            cell.label1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.textColor = .systemGray
            
            return cell
            
        }else if section == 4{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCellImageViewTwoLabelTableViewCell
            
            cell.zakazImageView.image = UIImage(systemName: "doc.text")
            
            cell.zakazImageView.tintColor = .systemGray
            
            cell.label1.text = "Статус заказа"
            cell.label2.text = thisZakaz.statusName
            
            cell.label1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.textColor = .systemGray
            
            return cell
            
        }else if section == 5{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let thisZakaz = thisZakaz else {return 0}
        
        let section = indexPath.section
        
        if section == 0{
            return 70
        }else if section == 5{
            if thisZakaz.comment.count >= 150{
                return 150
            }else if thisZakaz.comment.count >= 100{
                return 120
            }else{
                return 100
            }
        }else{
            return 38
        }
        
    }
    
}

//MARK: - Structs

extension ZakazTableViewCell {
    
    struct Zakaz {
        
        var id : String
        var date : String
        var itemsCount : String
        var replaces : String
        var clientBalance : String
        var orderSumm : String
        var comment : String
        var clientName : String
        var clientId : String
        var deliveryName : String
        var deliveryType : String
        var statusName : String
        var status : String
        var payCheckImg : String
        var orderQr : String
        
    }
    
}
