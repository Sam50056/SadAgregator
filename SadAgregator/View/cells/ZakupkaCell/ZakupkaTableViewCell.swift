//
//  ZakupkaTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.09.2021.
//

import UIKit
import SwiftyJSON

class ZakupkaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    var thisPur : Zakupka?
    
    var purchaseData : JSON?{
        didSet{
            
            guard let purchaseData = purchaseData else {return}
            
            let jsonMoneyArray = purchaseData["money"].arrayValue
            var newMoneySubItems = [TableViewItem]()
            var newTovarsSubItems = [TableViewItem]()
            
            if purchaseData["items"]["wait"].intValue > 1{
                newTovarsSubItems.append(TableViewItem(label1: "В ожидании:", label2: purchaseData["items"]["wait"].stringValue, label3: purchaseData["items"]["wait_cost"].stringValue + " руб.", haveClickableLabel: true))
            }
            
            if let bought = purchaseData["items"]["bought"].string , bought != "" , bought != "0"{
                newTovarsSubItems.append(TableViewItem(label1: "Выкуплено:", label2: bought, label3: purchaseData["items"]["bought_cost"].stringValue + " руб.", haveClickableLabel: true))
            }
            
            if let notAviable = purchaseData["items"]["not_aviable"].string , notAviable != "" , notAviable != "0"{
                newTovarsSubItems.append(TableViewItem(label1: "Не выкуплено:", label2: notAviable, label3: purchaseData["items"]["not_aviable_cost"].stringValue + " руб.", haveClickableLabel: true))
            }
            
            jsonMoneyArray.forEach { jsonMoneyItem in
                newMoneySubItems.append(TableViewItem(label1: jsonMoneyItem["capt"].stringValue, label2: "", label3: jsonMoneyItem["value"].stringValue))
            }
            
            moneySubItems = newMoneySubItems
            tovarsSubItems = newTovarsSubItems
            
            tableView.reloadData()
            
        }
    }
    
    var tovarsSubItems = [TableViewItem]()
    private var moneySubItems = [TableViewItem]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ZakupkaTableViewCellHeaderCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        tableView.register(UINib(nibName: "ZakupkaTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "ZakupkaTableViewCellTableViewSubCell", bundle: nil), forCellReuseIdentifier: "subCell")
        tableView.register(UINib(nibName: "ZakupkaTableViewCellFooterCell", bundle: nil), forCellReuseIdentifier: "footerCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.isScrollEnabled = false
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        purchaseData = nil
        tovarsSubItems.removeAll()
        moneySubItems.removeAll()
        tableView.reloadData()
        
    }
    
}

//MARK: - TableView

extension ZakupkaTableViewCell : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        11
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let purchaseData = purchaseData else {return 0}
        
        if section == 0 , purchaseData["capt"].stringValue != ""{
            return 1
        }else if section == 1 , purchaseData["cnt_items"]  .stringValue != ""{
            return 1
        }else if section == 2 , purchaseData["cnt_items"]  .stringValue != "" , purchaseData["cnt_items"].stringValue != "0" , !tovarsSubItems.isEmpty{
            return tovarsSubItems.count
        }else if section == 3 , purchaseData["cnt_clients"].stringValue != "" , purchaseData["cnt_clients"].stringValue != "0"{
            return 1
        }else if section == 4 , !moneySubItems.isEmpty{
            return 1
        }else if section == 5, !moneySubItems.isEmpty{
            return moneySubItems.count
        }else if section == 6 , purchaseData["cnt_points"].stringValue != "" , purchaseData["cnt_points"].stringValue != "0"{
            return 1
        }else if section == 7 , purchaseData["handler_type"].stringValue != ""{
            return 1
        }else if section == 8 , purchaseData["profit"].stringValue != "" , purchaseData["profit"].stringValue != "0"{
            return 1
        }else if section == 9 , purchaseData["postage_cost"].stringValue != "" , purchaseData["postage_cost"].stringValue != "0"{
            return 1
        }else if section == 10{
            return 1
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let purchaseData = purchaseData else {return UITableViewCell()}
        
        let section = indexPath.section
        let index = indexPath.row
        
        switch section{
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! ZakupkaTableViewCellHeaderCell
            
            cell.firstLabel.text = "N2432"
            cell.firstLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.firstLabel.textColor = .systemBlue
            
            cell.secondLabel.text = "01.09.2021"
            cell.secondLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            cell.secondLabel.textColor = .systemGray
            
            cell.firstViewButton.setTitle("", for: .normal)
            cell.secondViewButton.setTitle("", for: .normal)
            
            cell.firstView.layer.cornerRadius = 6
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            let itemsCount = purchaseData["cnt_items"].stringValue
            
            cell.label1.text = "Товары"
            cell.label2.text = itemsCount
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = itemsCount == "0" ? UIColor(named: "blackwhite") : .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "cart")
            
            cell.dropDownImageView.isHidden = tovarsSubItems.isEmpty
            
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell", for: indexPath) as! ZakupkaTableViewCellTableViewSubCell
            
            let item = tovarsSubItems[index]
            
            cell.label1.text = item.label1
            cell.label2.text = item.label2
            cell.label3.text = item.label3
            
            cell.label1.font = UIFont.systemFont(ofSize: 15 , weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            cell.label3.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            
            cell.label1.textColor = .systemGray
            cell.label3.textColor = .systemGray
            cell.label2.textColor = item.haveClickableLabel ? .systemBlue : UIColor(named: "blackwhite")
            
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            cell.label1.text = "Клиенты"
            cell.label2.text = purchaseData["cnt_clients"].stringValue
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "person.2")
            
            cell.dropDownImageView.isHidden = true
            
            return cell
            
        case 4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            cell.label1.text = "Финансы"
            cell.label2.text = ""
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.iconImageView.image = UIImage(systemName: "dollarsign.square")
            
            cell.dropDownImageView.isHidden = false
            
            return cell
            
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell", for: indexPath) as! ZakupkaTableViewCellTableViewSubCell
            
            let item = moneySubItems[index]
            
            cell.label1.text = item.label1
            cell.label2.text = item.label2
            cell.label3.text = item.label3
            
            cell.label1.font = UIFont.systemFont(ofSize: 15 , weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            cell.label3.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            
            cell.label1.textColor = .systemGray
            cell.label3.textColor = .systemGray
            cell.label2.textColor = item.haveClickableLabel ? .systemBlue : UIColor(named: "blackwhite")
            
            return cell
            
        case 6:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            cell.label1.text = "Точки"
            cell.label2.text = purchaseData["cnt_points"].stringValue
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "mappin.and.ellipse")
            
            cell.dropDownImageView.isHidden = true
            
            return cell
            
        case 7:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            let handlerType = purchaseData["handler_type"].stringValue
            
            if handlerType == "0"{
                cell.label1.text = "Посредник"
            }else if handlerType == "1"{
                cell.label1.text = "Поставщик"
            }else if handlerType == "2"{
                cell.label1.text = "Клиент"
            }
            
            cell.label2.text = purchaseData["handler_name"].stringValue
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "person")
            
            cell.dropDownImageView.isHidden = true
            
            return cell
            
        case 10:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell", for: indexPath) as! ZakupkaTableViewCellFooterCell
            
            cell.bgView.backgroundColor = UIColor(named: "gray")
            
            cell.bgView.layer.cornerRadius = 6
            
            cell.label.text = purchaseData["status"].stringValue
            
            cell.label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            
            return cell
            
        default:
            
            return UITableViewCell()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        
        if section == 0{
            return 45
        }else if section == 2 || section == 5{
            return 30
        }else if section == 10{
            return 50
        }else{
            return 38
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - Structs

extension ZakupkaTableViewCell{
    
    struct Zakupka{
        
        var capt : String
        var countItems : String
        var tovarSubItems : [TableViewItem]
        var countClients : String
        var moneySubItems : [TableViewItem]
        var countPoints : String
        var handlerType : String
        var profit : String
        var postageCost : String
        
    }
    
    struct TableViewItem {
        
        var label1 : String
        var label2 : String
        var label3 : String
        
        var haveClickableLabel : Bool = false
        
    }
    
}
