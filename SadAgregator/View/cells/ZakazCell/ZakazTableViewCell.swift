//
//  ZakazTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.12.2021.
//

import UIKit

class ZakazTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    var thisZakaz : Zakaz?{
        didSet{
            
            tableView.reloadData()
            
//            if let thisZakaz = thisZakaz , thisZakaz.isShownForOneZakaz {
//                tableView.isUserInteractionEnabled = true
//            }else{
//                tableView.isUserInteractionEnabled = false
//            }
            
        }
    }
    
    var tableViewTapped : (() -> ())?
    
    var deliveryButtonTapped : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ZakazTableViewCellHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        tableView.register(UINib(nibName: "ZakazTableViewCellCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        tableView.register(UINib(nibName: "ZakazTableViewCellImageViewTwoLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "ZakazTableViewCellTableViewCellWithImageView", bundle: nil), forCellReuseIdentifier: "cellWithImgView")
        tableView.register(UINib(nibName: "ZakazTableViewCellBgViewTableViewCell", bundle: nil), forCellReuseIdentifier: "bgViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.isScrollEnabled = false
        
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

//MARK: - TableView

extension ZakazTableViewCell  : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let thisZakaz = thisZakaz else {return 0}
        
        if section == 0{
            return 1
        }else if section == 1 , !thisZakaz.clientBalance.isEmpty , thisZakaz.clientBalance != "0" {
            return 1
        }else if section == 2 , !thisZakaz.itemsCount.isEmpty , thisZakaz.itemsCount != "0"{
            return 1
        }else if section == 3 , !thisZakaz.replaces.isEmpty , thisZakaz.replaces != "0"{
            return 1
        }else if section == 4 , !thisZakaz.deliveryType.isEmpty{
            return 1
        }else if section == 5 , !thisZakaz.statusName.isEmpty{
            return 1
        }else if section == 6 , !thisZakaz.comment.isEmpty{
            return 1
        }else if section == 7{
            return thisZakaz.isShownForOneZakaz ? 1 : 0
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
            
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
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
            
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
            return cell
            
        }else if section == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCellImageViewTwoLabelTableViewCell
            
            cell.zakazImageView.image = UIImage(systemName: "return")
            
            cell.zakazImageView.tintColor = .systemGray
            
            cell.label1.text = "Замены"
            cell.label2.text = thisZakaz.replaces
            
            cell.label1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.textColor = .systemGray
            
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
            return cell
            
        }else if section == 4{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithImgView", for: indexPath) as! ZakazTableViewCellTableViewCellWithImageView
            
            cell.imgView1.image = UIImage(systemName: "paperplane.fill")
            cell.imgView2.image = UIImage(systemName: "shippingbox")
            
            cell.imgView1.tintColor = .systemGray
            cell.imgView2.tintColor = .systemBlue
            
            cell.label.text = thisZakaz.deliveryType
            
            cell.label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
            cell.imgView2ButtonTapped = { [weak self] in
                self?.deliveryButtonTapped?()
            }
            
            return cell
            
        }else if section == 5{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakazTableViewCellImageViewTwoLabelTableViewCell
            
            cell.zakazImageView.image = UIImage(systemName: "doc.text")
            
            cell.zakazImageView.tintColor = .systemGray
            
            cell.label1.text = "Статус заказа"
            cell.label2.text = thisZakaz.statusName
            
            cell.label1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            cell.label2.textColor = .systemGray
            
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
            return cell
            
        }else if section == 6{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! ZakazTableViewCellCommentTableViewCell
            
            cell.commentTextView.text = thisZakaz.comment.replacingOccurrences(of: "<br>", with: "\n")
            
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
            return cell
            
        }else if section == 7{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "bgViewCell", for: indexPath) as! ZakazTableViewCellBgViewTableViewCell
            
            cell.bgView.layer.cornerRadius = 8
            
            cell.label.text = "Отправить сообщение заказчику"
            cell.imgView.image = UIImage(systemName: "bubble.right")
            
            cell.contentView.backgroundColor = UIColor(named: "whiteblack")
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let _ = indexPath.section
        
        tableViewTapped?()
        
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //
    //        guard let thisZakaz = thisZakaz else {return 0}
    //
    //        let section = indexPath.section
    //
    //        if section == 0{
    //            return 70
    //        }else if section == 5{
    //            if thisZakaz.comment.count >= 150{
    //                return 150
    //            }else if thisZakaz.comment.count >= 100{
    //                return 120
    //            }else{
    //                return 100
    //            }
    //        }else{
    //            return 38
    //        }
    //
    //    }
    
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
        
        var isShownForOneZakaz : Bool = false
        
    }
    
}
