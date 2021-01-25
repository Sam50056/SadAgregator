//
//  EmptyTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.01.2021.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var label : UILabel!
    
    @IBOutlet weak var emptyImageView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
