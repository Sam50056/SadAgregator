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

extension VendTableViewCell : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.row {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "popCell", for: indexPath)
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
            
        default:
            print("IndexPath out of switch: \(indexPath.row)")
            
        }
        
        
        return cell
        
    }
    
    
}
