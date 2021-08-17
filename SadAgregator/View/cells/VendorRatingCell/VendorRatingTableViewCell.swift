//
//  VendorRatingTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.01.2021.
//

import UIKit

class VendorRatingTableViewCell: UITableViewCell , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var posLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var captLabel: UILabel!
    
    @IBOutlet weak var peoplesLabel : UILabel!
    @IBOutlet weak var revLabel: UILabel!
    @IBOutlet weak var imgsLabel : UILabel!
    
    @IBOutlet weak var peoplesImageView : UIImageView!
    @IBOutlet weak var revImageView: UIImageView!
    @IBOutlet weak var imgsImageView : UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var rating : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var pop : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var prices : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var pricesAvg : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "VendTableViewCellRatingTableViewCell", bundle: nil), forCellReuseIdentifier: "ratingCell")
        tableView.register(UINib(nibName: "VendTableViewCellPopTableViewCell", bundle: nil), forCellReuseIdentifier: "popCell")
        tableView.register(UINib(nibName: "VendTableViewCellPhoneTableViewCell", bundle: nil), forCellReuseIdentifier: "phoneCell")
        tableView.register(UINib(nibName: "PricesTableViewCell", bundle: nil), forCellReuseIdentifier: "pricesCell")
        
        tableView.dataSource = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK: - TableViewStuff
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        
        case 0:
            return rating != nil ? 1 : 0
        case 1:
            return prices != nil ? 1 : 0
        case 2:
            return pop != nil ? 1 : 0
        default:
            fatalError("Invalid Section")
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.section {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath)
            
            setUpRatingCell(cell: cell as! VendTableViewCellRatingTableViewCell, data: rating!)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "pricesCell", for: indexPath)
            
            setUpPricesCell(cell: cell as! PricesTableViewCell, prices: prices!, pricesAvg: pricesAvg!)
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "popCell", for: indexPath)
            
            setUpPopCell(cell: cell as! VendTableViewCellPopTableViewCell, data: pop!)
            
        default:
            print("Invalid Section")
            
        }
        
        return cell
        
    }
    
    //MARK: - Cell SetUp
    
    func setUpRatingCell(cell : VendTableViewCellRatingTableViewCell , data : String){
        
        cell.ratingView.settings.fillMode = .precise
        
        cell.ratingView.rating = Double(data)!
        
        cell.ratingLabel.text = data
        
    }
    
    func setUpPopCell(cell : VendTableViewCellPopTableViewCell , data : String){
        
        cell.label.text = data
        
    }
    
    func setUpPricesCell(cell : PricesTableViewCell, prices : String, pricesAvg : String){
        
        cell.label.text = "\(prices) , \(pricesAvg)"
        
    }
    
}
