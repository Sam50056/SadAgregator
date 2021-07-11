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
    
    private var collectionViewItems = [CollectionViewItem]()
    
    private var tableViewItems = [TableViewItem]()
    
    var thisTovar : TovarCellItem?{
        
        didSet{
            
            guard let thisTovar = thisTovar else {return}
            
            var newItems = [TableViewItem]()
            
            if thisTovar.capt != "" {
                newItems.append(TableViewItem(label1Text: "Номер точки", label2Text: thisTovar.capt))
            }
            
            if thisTovar.purCost != ""{
                newItems.append(TableViewItem(label1Text: "Цена закупки", label2Text: thisTovar.purCost))
            }
            
            if thisTovar.sellCost != "" {
                newItems.append(TableViewItem(label1Text: "Цена продажи", label2Text: thisTovar.sellCost))
            }
            
            if thisTovar.size != "" {
                newItems.append(TableViewItem(label1Text: "Размер", label2Text: thisTovar.size))
            }
            
            if thisTovar.status != "" , !isZamena{
                newItems.append(TableViewItem(label1Text: "Статус", label2Text: thisTovar.status , shouldSecondLabelBeBlue: true))
            }
            
            if thisTovar.qr != "" , !isZamena{
                newItems.append(TableViewItem(label1Text: "QR-код", label2Text:  thisTovar.qr == "0" ? "Не привязан" : "Привязан", hasImage: true, image: "qrcode" , shouldSecondLabelBeBlue: true))
            }
            
            if thisTovar.clientName != "" {
                newItems.append(TableViewItem(label1Text: "Клиент", label2Text: thisTovar.clientName))
            }
            
            if thisTovar.payed != ""{
                newItems.append(TableViewItem(label1Text: "Оплачено", label2Text: thisTovar.payed == "1" ? "Да" : "Нет" ))
            }
            
            if thisTovar.isReplace != "" {
                newItems.append(TableViewItem(label1Text: "Это замена", label2Text: thisTovar.isReplace == "1" ? "Да" : "Нет" , shouldSecondLabelBeBlue: true))
            }
            
            if thisTovar.replaces != ""{
                newItems.append(TableViewItem(label1Text: "Замен по товару ", label2Text:  thisTovar.replaces == "0" ? "Нет" : thisTovar.replaces))
            }
            
            tableViewItems = newItems
            
            tableView.reloadData()
            
            //Setting the image
            tovarImageView.sd_setImage(with: URL(string: thisTovar.img), placeholderImage: UIImage(systemName: "cart"), options: .highPriority, context: nil)
            
            //Setting collection view's items
            collectionViewItems = [
                CollectionViewItem(image: "questionmark", type: .questionMark),
                CollectionViewItem(image: "magnifyingglass", type: .magnifyingGlass),
                CollectionViewItem(image: "info", type: .info),
                CollectionViewItem(image: "qrcode", type: .qr)
            ]
            
            collectionView.reloadData()
            
        }
        
    }
    
    var isZamena = false
    
    var tovarSelected : (() -> Void)?
    
    var tovarImageTapped : (() -> Void)?
    
    var qrCodeTapped : (() -> Void)?
    var magnifyingGlassTapped : (() -> Void)?
    
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

//MARK: - Actions

extension TovarTableViewCell{
    
    @IBAction func selectButtonTapped(_ sender : Any){
        
        guard let _ = thisTovar else {return}
        
        tovarSelected?()
        
    }
    
    @IBAction func tovarImageTapped(_ sender : Any){
        
        guard let thisTovar = thisTovar, thisTovar.img != "" else {return}
        
        print("In cell")
        tovarImageTapped?()
        
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
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard isZamena else {return nil}
        
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
        return isZamena ? 60 : 0
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
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: self.tovarImageView.frame.width / 5.2, bottom: 0, trailing: 0)
            
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
        return !isZamena ? collectionViewItems.count : 0
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
            
            
            
        }else if itemType == .magnifyingGlass{
            
            magnifyingGlassTapped?()
            
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
    
}

extension TovarTableViewCell{
    
    private enum CollectionViewCellType{
        case questionMark
        case info
        case qr
        case magnifyingGlass
    }
    
}
