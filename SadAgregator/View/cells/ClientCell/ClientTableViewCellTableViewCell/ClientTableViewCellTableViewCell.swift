//
//  ClientTableViewCellTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.03.2021.
//

import UIKit

class ClientTableViewCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstLabel : UILabel!
    
    @IBOutlet weak var secondLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        firstLabel.text = ""
        secondLabel.text = ""
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
