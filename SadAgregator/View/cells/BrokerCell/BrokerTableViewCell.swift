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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
