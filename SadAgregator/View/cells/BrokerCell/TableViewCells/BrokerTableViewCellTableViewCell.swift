//
//  BrokerTableViewCellTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.07.2021.
//

import UIKit

class BrokerTableViewCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView : UIImageView!
    @IBOutlet weak var label1 : UILabel!
    @IBOutlet weak var label2 : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label1.text = ""
        label2.text = ""
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        label1.text = ""
        label2.text = ""
        imgView.image = nil
    }
    
}
