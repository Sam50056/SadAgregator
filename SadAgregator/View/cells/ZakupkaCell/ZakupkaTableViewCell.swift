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
    
    var thisPur : Zakupka?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var openTapped : ((OpenType) -> Void)?
    
    var purNameTapped : (() -> Void)?
    var dateTapped : (() -> Void)?
    
    var rightSideButtonPressedForCell : ((String) -> Void)?
    var tovarsSubItemTapped : ((Int) -> Void)?
    var clientTapped : ((String) -> Void)?
    var handlerTapped : (() -> Void)?
    var tochkaTapped : (() -> Void)?
    
    var documentImageTapped : ((Int) -> Void)?
    var documentImageRemoveButtonTapped : ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ZakupkaTableViewCellHeaderCell", bundle: nil), forCellReuseIdentifier: "headerCell")
        tableView.register(UINib(nibName: "ZakupkaTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "ZakupkaTableViewCellTableViewSubCell", bundle: nil), forCellReuseIdentifier: "subCell")
        tableView.register(UINib(nibName: "ZakupkaTableViewCellFooterCell", bundle: nil), forCellReuseIdentifier: "footerCell")
        tableView.register(UINib(nibName: "ZakupkaTableViewCellDocumentsTableViewCell", bundle: nil), forCellReuseIdentifier: "docsCell")
        
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
        
        thisPur = nil
        tableView.reloadData()
        
    }
    
}

//MARK: - TableView

extension ZakupkaTableViewCell : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        13
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let thisPur = thisPur else {return 0}
        
        if section == 0 , thisPur.capt != ""{
            return 1
        }else if section == 1{
            return 1
        }else if section == 2 , thisPur.countItems != "" , thisPur.countItems != "0" , !thisPur.tovarsSubItems.isEmpty , thisPur.openTovars{
            return thisPur.tovarsSubItems.count
        }else if section == 3 , thisPur.countClients != "" , thisPur.countClients != "0"{
            return 1
        }else if section == 4 , !thisPur.money.isEmpty{
            return 1
        }else if section == 5, !thisPur.money.isEmpty , thisPur.openMoney{
            return thisPur.money.count
        }else if section == 6 , thisPur.countPoints != "" , thisPur.countPoints != "0"{
            return 1
        }else if section == 7 , thisPur.handlerType != ""{
            return 1
        }else if section == 8 , thisPur.profit != "" , thisPur.profit != "0"{
            return 1
        }else if section == 9 , thisPur.postageCost != "" ,thisPur.postageCost != "0"{
            return 1
        }else if section == 10 , !thisPur.images.isEmpty{
            return 1
        }else if section == 11 , !thisPur.images.isEmpty , thisPur.openDocs{
            return 1
        }else if section == 12{
            return 1
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let thisPur = thisPur else {return UITableViewCell()}
        
        let section = indexPath.section
        let index = indexPath.row
        
        switch section{
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! ZakupkaTableViewCellHeaderCell
            
            cell.firstLabel.text = thisPur.capt
            cell.firstLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.firstLabel.textColor = .systemBlue
            
            cell.secondLabel.text = thisPur.dt
            cell.secondLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            cell.secondLabel.textColor = .systemGray
            
            cell.firstViewButton.setTitle("", for: .normal)
            cell.secondViewButton.setTitle("", for: .normal)
            
            cell.firstView.layer.cornerRadius = 6
            
            cell.firstButtonTapped = { [weak self] in
                self?.purNameTapped?()
            }
            
            cell.secondButtonTapped = { [weak self] in
                self?.dateTapped?()
            }
            
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            let itemsCount = thisPur.countItems
            
            cell.label1.text = "Товары"
            cell.label2.text = itemsCount == "" ? "0" : itemsCount
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = itemsCount == "0" ? UIColor(named: "blackwhite") : .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "cart")
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.image = UIImage(systemName: !thisPur.openTovars ? "chevron.down" : "chevron.up")
            
            cell.dropDownImageView.isHidden = thisPur.tovarsSubItems.isEmpty
            
            cell.rightSideButtonPressed = { [weak self] in
                self?.rightSideButtonPressedForCell?("tovars")
            }
            
            cell.rightSideButton.isEnabled = true
            
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell", for: indexPath) as! ZakupkaTableViewCellTableViewSubCell
            
            let item = thisPur.tovarsSubItems[index]
            
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
            cell.label2.text = thisPur.countClients
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "person.2")
            
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.isHidden = true
            
            cell.rightSideButton.isEnabled = false
            
            return cell
            
        case 4:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            cell.label1.text = "Финансы"
            cell.label2.text = ""
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.iconImageView.image = UIImage(systemName: "dollarsign.square")
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.image = UIImage(systemName: !thisPur.openMoney ? "chevron.down" : "chevron.up")
            
            cell.dropDownImageView.isHidden = false
            
            cell.rightSideButton.isEnabled = false
            
            return cell
            
        case 5:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "subCell", for: indexPath) as! ZakupkaTableViewCellTableViewSubCell
            
            let item = thisPur.money[index]
            
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
            cell.label2.text = thisPur.countPoints
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "mappin.and.ellipse")
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.isHidden = true
            
            cell.rightSideButton.isEnabled = false
            
            return cell
            
        case 7:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            let handlerType = thisPur.handlerType
            
            if handlerType == "0"{
                cell.label1.text = "Посредник"
            }else if handlerType == "1"{
                cell.label1.text = "Поставщик"
            }else if handlerType == "2"{
                cell.label1.text = "Клиент"
            }
            
            cell.label2.text = thisPur.handlerName
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "person")
            
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.isHidden = true
            
            cell.rightSideButton.isEnabled = false
            
            return cell
            
        case 8:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            cell.label1.text = "Заработок"
            cell.label2.text = thisPur.profit + " руб."
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "rublesign.circle.fill")
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.isHidden = true
            
            cell.rightSideButton.isEnabled = false
            
            return cell
            
        case 9:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            cell.label1.text = "Почта России"
            cell.label2.text = thisPur.postageCost + " руб."
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.label2.textColor = .systemBlue
            
            cell.iconImageView.image = UIImage(systemName: "shippingbox.fill")
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.isHidden = true
            
            cell.rightSideButton.isEnabled = false
            
            return cell
            
        case 10:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellTableViewCell
            
            cell.label1.text = "Документы"
            cell.label2.text = ""
            
            cell.label1.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            cell.label2.font = UIFont.systemFont(ofSize: 16)
            
            cell.iconImageView.image = UIImage(systemName: "doc.plaintext")
            cell.iconImageView.tintColor = .systemGray
            
            cell.dropDownImageView.image = UIImage(systemName: !thisPur.openDocs ? "chevron.down" : "chevron.up")
            
            cell.dropDownImageView.isHidden = false
            
            cell.rightSideButton.isEnabled = false
            
            return cell
            
        case 11:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "docsCell", for: indexPath) as! ZakupkaTableViewCellDocumentsTableViewCell
            
            cell.images = thisPur.images
            
            cell.removeImage = { [weak self] i in
                self?.documentImageRemoveButtonTapped?(i)
            }
            
            cell.imageTapped = { [weak self] i in
                self?.documentImageTapped?(i)
            }
            
            return cell
            
        case 12:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell", for: indexPath) as! ZakupkaTableViewCellFooterCell
            
            cell.bgView.backgroundColor = UIColor(named: "gray")
            
            cell.bgView.layer.cornerRadius = 6
            
            cell.label.text = thisPur.status
            
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
        }else if section == 12{
            return 50
        }else if section == 11{
            return 80
        }else{
            return 38
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let thisPur = thisPur else {return}
        
        let section = indexPath.section
        let _ = indexPath.row
        
        if section == 1 , !thisPur.tovarsSubItems.isEmpty{
            openTapped?(.tovars)
        }else if section == 2{
            tovarsSubItemTapped?(indexPath.row)
        }else if section == 3{
            clientTapped?(thisPur.clientId)
        }else if section == 4{
            openTapped?(.finance)
        }else if section == 6{
            tochkaTapped?()
        }else if section == 7{
            handlerTapped?()
        }else if section == 10{
            openTapped?(.docs)
        }
        
    }
    
}

//MARK: - Structs

extension ZakupkaTableViewCell{
    
    struct Zakupka{
        
        var purId : String
        var statusId : String
        
        var capt : String
        var dt : String
        
        var countItems : String
        var replaces : String
        var countClients : String
        var countPoints : String
        
        var money : [TableViewItem]
        
        var clientId : String
        
        var handlerType : String
        var handlerId : String
        var handlerName : String
        
        var actAv : String
        var status : String
        var profit : String
        var postageCost : String
        
        var itemsWait : String
        var itemsWaitCost : String
        var itemsBought : String
        var itemsBoughtCost : String
        var itemsNotAvailable : String
        var itemsNotAvailableCost : String
        
        var tovarsSubItems : [TableViewItem] = []
        var images : [ImageItem] = []
        
        var openTovars : Bool = false
        var openMoney : Bool = false
        var openDocs : Bool = false
        
    }
    
    struct TableViewItem {
        
        var label1 : String
        var label2 : String
        var label3 : String
        
        var haveClickableLabel : Bool = false
        
    }
    
    struct ImageItem {
        
        var image : String
        var id : String
        
    }
    
}

//MARK: - Enums

extension ZakupkaTableViewCell{
    
    enum OpenType {
        case tovars
        case finance
        case docs
    }
    
}
