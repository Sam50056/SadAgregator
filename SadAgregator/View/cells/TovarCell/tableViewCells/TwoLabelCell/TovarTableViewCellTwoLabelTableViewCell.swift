//
//  TovarTableViewCellTwoLabelTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.04.2021.
//

import UIKit

class TovarTableViewCellTwoLabelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label1 : UILabel!
    @IBOutlet weak var label2 : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label1.text = ""
        label2.text = ""
        
        NSLayoutConstraint.activate([label2.leadingAnchor.constraint(equalTo: label1.trailingAnchor, constant: 8)])
        
        label1.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        label2.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label1.text = ""
        label2.text = ""
        
    }
    
}
