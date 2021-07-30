//
//  BrokerTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.07.2021.
//

import UIKit
import Cosmos

class BrokerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var brokerImageView : UIImageView!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var ratingLabel : UILabel!
    @IBOutlet weak var ratingView : CosmosView!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var verifyImageView : UIImageView!
    
    var otherItems = [TableViewItem](){
        didSet{
            tableView.reloadData()
        }
    }
    var rateItems = [TableViewItem](){
        didSet{
            tableView.reloadData()
        }
    }
    var parcelItems = [TableViewItem](){
        didSet{
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "BrokerTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        otherItems.removeAll()
        rateItems.removeAll()
        parcelItems.removeAll()
    }
    
}

//MARK: - TableView

extension BrokerTableViewCell : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return otherItems.count
        }else if section == 1{
            return rateItems.count
        }else if section == 2{
            return parcelItems.count
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let section = indexPath.section
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BrokerTableViewCellTableViewCell
        
        if section == 0{
            
            let item = otherItems[index]
            
            cell.imgView.image = UIImage(systemName: item.image)
            cell.label1.text = item.label1Text
            cell.label2.text = item.label2Text
            
        }else if section == 1{
            
            let item = rateItems[index]
            
            if index == 0{
                
                cell.imgView.image = UIImage(systemName: item.image)
                cell.label1.text = item.label1Text
                cell.label2.text = item.label2Text
                return cell
            }
            
            cell.imgView.image = nil
            cell.label1.text = ""
            cell.label2.text = item.label2Text
            
        }else if section == 2{
            
            let item = parcelItems[index]
            
            if index == 0{
                
                cell.imgView.image = UIImage(systemName: item.image)
                cell.label1.text = item.label1Text
                cell.label2.text = item.label2Text
                return cell
            }
            
            cell.imgView.image = nil
            cell.label1.text = ""
            cell.label2.text = item.label2Text
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}

//MARK: - Structs

extension BrokerTableViewCell {
    
    struct TableViewItem {
        
        var image : String
        var label1Text : String
        var label2Text : String
        
    }
    
}
