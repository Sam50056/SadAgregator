//
//  PurchaseTableViewCellTitleCellTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.06.2021.
//

import UIKit

class PurchaseTableViewCellTitleCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        captLabel.text = ""
        dateLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
