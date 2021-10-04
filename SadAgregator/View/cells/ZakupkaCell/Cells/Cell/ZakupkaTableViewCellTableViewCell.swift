//
//  ZakupkaTableViewCellTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.09.2021.
//

import UIKit

class ZakupkaTableViewCellTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var dropDownImageView : UIImageView!
    @IBOutlet weak var label1 : UILabel!
    @IBOutlet weak var label2 : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
 }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label1.text?.removeAll()
        label2.text?.removeAll()
        
        iconImageView.image = nil
        dropDownImageView.image = nil
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
