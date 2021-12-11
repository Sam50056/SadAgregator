//
//  ZakazTableViewCellHeaderTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.12.2021.
//

import UIKit

class ZakazTableViewCellHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var idLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var summLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        idLabel.text = ""
        dateLabel.text = ""
        nameLabel.text = ""
        summLabel.text = ""
        
    }
    
    override func prepareForReuse() {
        idLabel.text = ""
        dateLabel.text = ""
        nameLabel.text = ""
        summLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
