//
//  TovarTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.04.2021.
//

import UIKit

class TovarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    @IBOutlet weak var tovarImageView : UIImageView!
    var tovarImageViewButton : UIButton!
    
    @IBOutlet weak var bottomStackView : UIStackView!
    @IBOutlet weak var bottomStackViewLeftView : UIView!
    @IBOutlet weak var bottomStackViewRightView : UIView!
    @IBOutlet weak var bottomStackViewLeftViewLabel : UILabel!
    @IBOutlet weak var bottomStackViewRightViewLabel : UILabel!
    
    private var collectionViewItems = [CollectionViewItem]()
    
    private var tableViewItems = [TableViewItem]()
    
    var thisTovar : TovarCellItem?{
        
        didSet{
            
            guard let thisTovar = thisTovar else {return}
            
            var newItems = [TableViewItem]()
            
            if thisTovar.capt != "" {
                newItems.append(TableViewItem(label1Text: "Точка", label2Text: thisTovar.capt))
            }
            
            if thisTovar.purCost != ""{
                newItems.append(TableViewItem(label1Text: "Закупка", label2Text: thisTovar.purCost + " руб." , shouldSecondLabelBeBlue: thisTovar.chLvl != "0"))
            }
            
            if thisTovar.sellCost != "" {
                newItems.append(TableViewItem(label1Text: "Продажа", label2Text: thisTovar.sellCost + " руб." , shouldSecondLabelBeBlue: thisTovar.chLvl != "0"))
            }
            
            if thisTovar.size != "" {
                newItems.append(TableViewItem(label1Text: "Размер", label2Text: thisTovar.size , shouldSecondLabelBeBlue: thisTovar.chLvl != "0"))
            }
            
            if thisTovar.status != "" , thisTovar.status != "-1" , contentType != .zamena{
                newItems.append(TableViewItem(label1Text: "Статус", label2Text: thisTovar.status , shouldSecondLabelBeBlue: true))
            }
            
            if thisTovar.qr != "" , thisTovar.qr != "-1" , contentType != .zamena{
                newItems.append(TableViewItem(label1Text: "QR-код", label2Text:  thisTovar.qr == "0" ? "Не привязан" : "Привязан", hasImage: true, image: "qrcode" , shouldSecondLabelBeBlue: true))
            }
            
            if thisTovar.clientName != "" {
                newItems.append(TableViewItem(label1Text: "Клиент", label2Text: thisTovar.clientName , shouldSecondLabelBeBlue: thisTovar.clientId != "" ? true : false))
            }
            
            if thisTovar.payed != "" , thisTovar.payed != "0"{
                newItems.append(TableViewItem(label1Text: "Оплачено", label2Text: "Да" , shouldSecondLabelBeBlue: thisTovar.payedImage != ""))
            }
            
            if thisTovar.isReplace != "" , thisTovar.isReplace != "0" {
                newItems.append(TableViewItem(label1Text: "Это замена", label2Text: "Да" , shouldSecondLabelBeBlue: true))
            }
            
            if thisTovar.replaces != "" ,  thisTovar.replaces != "0"{
                newItems.append(TableViewItem(label1Text: "Замен по товару ", label2Text: thisTovar.replaces))
            }
            
            if thisTovar.shipmentImage != ""{
                newItems.append(TableViewItem(label1Text: "Фото посылки", label2Text: "Есть" , shouldSecondLabelBeBlue: true))
            }
            
            if thisTovar.defCheck == "1"{
                newItems.append(TableViewItem(label1Text: "Проверка на брак", label2Text: "Да"))
            }
            
            if thisTovar.withoutRep == "1"{
                newItems.append(TableViewItem(label1Text: "Без замен", label2Text: "Да"))
            }
            
            tableViewItems = newItems
            
            tableView.reloadData()
            
            //Setting the image
            let originalUrlString = thisTovar.img
            if !originalUrlString.isEmpty{
                
                let indexOfLastSlash = originalUrlString.lastIndex(of: "/")
                let indexOfDot = originalUrlString.lastIndex(of: ".")
                let firstPartOfURL = String(originalUrlString[originalUrlString.startIndex ..< indexOfLastSlash!])
                let secondPartOfURL = "/\(250)\(String(originalUrlString[indexOfDot! ..< originalUrlString.endIndex]))"
                let fullURL = "\(firstPartOfURL)\(secondPartOfURL)"
                
                tovarImageView.sd_setImage(with: URL(string: fullURL), placeholderImage: UIImage(systemName: "cart"), options: .highPriority, context: nil)
                
            }else{
                tovarImageView.image = UIImage(systemName: "cart")
            }
            
            guard oldValue == nil else {return}
            
            //Setting collection view's items
            collectionViewItems = [
                CollectionViewItem(image: "questionmark", type: .questionMark),
                CollectionViewItem(image: "magnifyingglass", type: .magnifyingGlass),
                CollectionViewItem(image: "info", type: .info)
            ]
            
            if thisTovar.qr != "-1"{
                collectionViewItems.append(CollectionViewItem(image: "qrcode", type: .qr))
            }
            
            collectionView.reloadData()
            
        }
        
    }
    
    var contentType : ContentType = .normal{
        didSet{
            if contentType == .order{
                bottomStackViewLeftView.isHidden = false
                bottomStackViewRightView.isHidden = false
            }else{
                bottomStackViewLeftView.isHidden = true
                bottomStackViewRightView.isHidden = true
            }
        }
    }
    
    var tovarSelected : (() -> Void)?
    
    var tovarImageTapped : (() -> Void)?
    
    var oplachenoTapped : (() -> Void)?
    var shipmentImageTapped : (() -> Void)?
    var clientNameTapped : (() -> Void)?
    var statusTapped : (() -> Void)?
    var zakupkaTapped : (() -> Void)?
    var prodazhaTapped : (() -> Void)?
    var razmerTapped : (() -> Void)?
    var infoTapped : (() -> Void)?
    var qrCodeTapped : (() -> Void)?
    var magnifyingGlassTapped : (() -> Void)?
    var questionMarkTapped : (() -> Void)?
    
    var bottomStackViewLeftViewButtonTapped : (() -> Void)?
    var bottomStackViewRightViewButtonTapped : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tovarImageViewButton = UIButton(frame: tovarImageView.frame)
        addSubview(tovarImageViewButton)
        tovarImageViewButton.addTarget(self, action: #selector(tovarImageTapped(_:)), for: .touchUpInside)
        
        tovarImageView.contentMode = .scaleAspectFill
        tovarImageView.layer.cornerRadius = 6
        
        collectionView.register(UINib(nibName: "TovarTableViewCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        tableView.register(UINib(nibName: "TovarTableViewCellTwoLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "twoLabelCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.collectionViewLayout = createLayout()
        
        //        collectionView.isScrollEnabled = false
        
        tovarImageView.tintColor = .systemGray2
        
        bottomStackViewLeftView.layer.cornerRadius = 8
        bottomStackViewRightView.layer.cornerRadius = 8
        bottomStackViewRightViewLabel.text = "Нет в наличии"
        bottomStackViewLeftViewLabel.text = "Есть в наличии"
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thisTovar = nil
        
        tableView.reloadData()
    }
    
}

//MARK: - Enums

extension TovarTableViewCell {
    
    enum ContentType {
        case normal
        case zamena
        case order
    }
    
}

//MARK: - Actions

extension TovarTableViewCell{
    
    @IBAction func selectButtonTapped(_ sender : Any){
        
        guard let _ = thisTovar else {return}
        
        tovarSelected?()
        
    }
    
    @IBAction func tovarImageTapped(_ sender : Any){
        
        guard let thisTovar = thisTovar, thisTovar.img != "" else {return}
        
        tovarImageTapped?()
        
    }
    
    @IBAction func bottomStackViewLeftViewButtonTapped(_ sender : Any){
        
        bottomStackViewLeftViewButtonTapped?()
        
    }
    
    @IBAction func bottomStackViewRightViewButtonTapped(_ sender : Any){
        
        bottomStackViewRightViewButtonTapped?()
        
    }
    
}

//MARK: - TableView

extension TovarTableViewCell : UITableViewDataSource , UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let item = tableViewItems[indexPath.row]
        
        cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath) as! TovarTableViewCellTwoLabelTableViewCell
        
        (cell as! TovarTableViewCellTwoLabelTableViewCell).label1.text = item.label1Text
        
        (cell as! TovarTableViewCellTwoLabelTableViewCell).label2.text = item.label2Text
        
        (cell as! TovarTableViewCellTwoLabelTableViewCell).label1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        (cell as! TovarTableViewCellTwoLabelTableViewCell).label1.textColor = .systemGray
        
        (cell as! TovarTableViewCellTwoLabelTableViewCell).label2.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        (cell as! TovarTableViewCellTwoLabelTableViewCell).label2.textColor = item.shouldSecondLabelBeBlue ? .systemBlue : UIColor(named: "blackwhite")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = tableViewItems[indexPath.row]
        
        if item.label1Text == "QR-код"{
            
            qrCodeTapped?()
            
        }else if item.label1Text == "Оплачено" , item.shouldSecondLabelBeBlue{
            
            //if item.shouldSecondLabelBeBlue , it means there is a payedImage
            
            oplachenoTapped?()
            
        }else if item.label1Text == "Фото посылки"{
            
            shipmentImageTapped?()
            
        }else if item.label1Text == "Клиент" , item.shouldSecondLabelBeBlue{
            
            clientNameTapped?()
            
        }else if item.label1Text == "Статус"{
            
            statusTapped?()
            
        }else if item.label1Text == "Закупка" , item.shouldSecondLabelBeBlue{
            
            zakupkaTapped?()
            
        }else if item.label1Text == "Продажа" , item.shouldSecondLabelBeBlue{
            
            prodazhaTapped?()
            
        }else if item.label1Text == "Размер" , item.shouldSecondLabelBeBlue{
            
            razmerTapped?()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard contentType == .zamena else {return nil}
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.backgroundColor = .none
        
        let bgView = UIView(frame: CGRect(x: 8, y: 8, width: footerView.bounds.width - 16, height: footerView.bounds.height - 16))
        
        bgView.backgroundColor = UIColor(named: "gray")
        
        bgView.layer.cornerRadius = 6
        
        footerView.addSubview(bgView)
        
        let button = UIButton(frame: CGRect(x: 8, y: 8, width: bgView.bounds.width - 16, height: bgView.bounds.height - 16))
        
        button.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        
        button.setTitle("ВЫБРАТЬ ДЛЯ ЗАМЕНЫ", for: .normal)
        
        button.setTitleColor(.systemBlue, for: .normal)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        bgView.addSubview(button)
        
        return footerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return contentType == .zamena ? 60 : 0
    }
    
}

//MARK: - CollectionView

extension TovarTableViewCell : UICollectionViewDataSource , UICollectionViewDelegate{
    
    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalHeight(0.4))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            group.interItemSpacing = .fixed(16)
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
            
            section.interGroupSpacing = 16
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentType == .normal ? collectionViewItems.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TovarTableViewCellCollectionViewCell
        
        let item = collectionViewItems[indexPath.row]
        
        cell.imageView.image = UIImage(systemName: item.image)
        
        cell.imageView.tintColor = .systemBlue
        
        cell.bgView.backgroundColor = UIColor(named: "gray")
        
        cell.roundCorners(.allCorners, radius: 8)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = collectionViewItems[indexPath.row]
        
        let itemType = item.type
        
        if itemType == .qr{
            
            qrCodeTapped?()
            
        }else if itemType == .info{
            
            infoTapped?()
            
        }else if itemType == .magnifyingGlass{
            
            magnifyingGlassTapped?()
            
        }else if itemType == .questionMark{
            
            questionMarkTapped?()
            
        }
        
    }
    
}

//MARK: - Structs

extension TovarTableViewCell{
    
    private struct CollectionViewItem {
        
        var image : String
        var type : CollectionViewCellType
        
    }
    
    private struct TableViewItem{
        
        var label1Text : String
        var label2Text : String
        var hasImage : Bool = false
        var image : String = ""
        
        var shouldSecondLabelBeBlue : Bool = false
        
    }
    
}

struct TovarCellItem {
    
    var pid : String
    var capt : String
    var size : String
    var payed : String
    var purCost : String
    var sellCost : String
    var hash : String
    var link : String
    var clientId : String
    var clientName : String
    var comExt : String
    var qr : String
    var status : String
    var isReplace : String
    var forReplacePid : String
    var replaces : String
    var img : String
    var chLvl : String
    var defCheck : String
    var withoutRep : String
    var payedImage : String
    var shipmentImage : String
    
}

extension TovarTableViewCell{
    
    private enum CollectionViewCellType{
        case questionMark
        case info
        case qr
        case magnifyingGlass
    }
    
}
