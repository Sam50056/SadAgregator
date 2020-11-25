//
//  VendTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.11.2020.
//

import UIKit

class VendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "ratingCell")
        tableView.register(UINib(nibName: "PopTableViewCell", bundle: nil), forCellReuseIdentifier: "popCell")
        
        tableView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

extension VendTableViewCell : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch indexPath.row {
        
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath)
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "popCell", for: indexPath)
            
        default:
            print("IndexPath out of switch: \(indexPath.row)")
            
        }
        
        
        return cell
        
    }
    
    
}
