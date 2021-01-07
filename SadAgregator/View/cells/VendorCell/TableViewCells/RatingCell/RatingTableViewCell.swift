//
//  RatingTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.11.2020.
//

import UIKit
import Cosmos

class RatingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ratingView : CosmosView!
    @IBOutlet weak var ratingLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
