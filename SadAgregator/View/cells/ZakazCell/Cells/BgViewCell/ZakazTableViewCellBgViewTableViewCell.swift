//
//  ZakazTableViewCellBgViewTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.12.2021.
//

import UIKit

class ZakazTableViewCellBgViewTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var imgView : UIImageView!
    @IBOutlet weak var label : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
