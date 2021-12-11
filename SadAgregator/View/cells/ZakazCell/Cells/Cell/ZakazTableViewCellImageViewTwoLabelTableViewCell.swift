//
//  ZakazTableViewCellImageViewTwoLabelTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.12.2021.
//

import UIKit

class ZakazTableViewCellImageViewTwoLabelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var zakazImageView : UIImageView!
    @IBOutlet weak var label1 : UILabel!
    @IBOutlet weak var label2 : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label1.text = ""
        label2.text = ""
        
        zakazImageView.image = nil
        
    }
    
    override func prepareForReuse() {
        
        label1.text = ""
        label2.text = ""
        
        zakazImageView.image = nil
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
