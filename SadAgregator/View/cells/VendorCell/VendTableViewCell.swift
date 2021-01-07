//
//  VendTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.11.2020.
//

import UIKit
import SwiftyJSON

class VendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var actLabel : UILabel!
    @IBOutlet weak var peoplesLabel : UILabel!
    @IBOutlet weak var revLabel: UILabel!
    
    @IBOutlet weak var peoplesImageView : UIImageView!
    @IBOutlet weak var revImageView: UIImageView!
    
    var data : JSON?
    
    var rating : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var phone : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var pop : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "ratingCell")
        tableView.register(UINib(nibName: "PopTableViewCell", bundle: nil), forCellReuseIdentifier: "popCell")
        tableView.register(UINib(nibName: "PhoneTableViewCell", bundle: nil), forCellReuseIdentifier: "phoneCell")
        
        tableView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

//MARK: - UITableViewDataSource

extension VendTableViewCell : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        
        if pop != nil {
            count += 1
        }
        
        if phone != nil{
            count += 1
        }
        
        if rating != nil {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.row {
        
        case 0:
            
            if rating != nil {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath)
                
                setUpRatingCell(cell: cell as! RatingTableViewCell, data: rating!)
                
            }else if phone != nil{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
                
                setUpPhoneCell(cell: cell as! PhoneTableViewCell, data: phone!)
                
            }else {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "popCell", for: indexPath)
                
                setUpPopCell(cell: cell as! PopTableViewCell, data: pop!)
            }
            
        case 1:
            
            if phone != nil , rating != nil{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
                
                setUpPhoneCell(cell: cell as! PhoneTableViewCell, data: phone!)
                
            }else if pop != nil {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "popCell", for: indexPath)
                
                setUpPopCell(cell: cell as! PopTableViewCell, data: pop!)
                
            }
            
        case 2:
            
            //If it came to 3 elements in table View , it means that the last is 100% popCell
            cell = tableView.dequeueReusableCell(withIdentifier: "popCell", for: indexPath)
            
            setUpPopCell(cell: cell as! PopTableViewCell, data: pop!)
            
        default:
            print("IndexPath out of switch: \(indexPath.row)")
        }
        
        
        return cell
        
    }
    
    
    //MARK: - Cell SetUp
    
    func setUpRatingCell(cell : RatingTableViewCell , data : String){
        
        cell.ratingView.rating = Double(data)!
        
        cell.ratingLabel.text = data
        
    }
    
    func setUpPhoneCell(cell : PhoneTableViewCell , data : String){
        
        cell.label.text = data
        
    }
    
    func setUpPopCell(cell : PopTableViewCell , data : String){
        
        cell.label.text = data
        
    }
    
}
