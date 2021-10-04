//
//  ZakupkaTableViewCellHeaderCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.09.2021.
//

import UIKit

class ZakupkaTableViewCellHeaderCell: UITableViewCell {
    
    @IBOutlet weak var firstView : UIView!
    @IBOutlet weak var secondView : UIView!
    
    @IBOutlet weak var firstLabel : UILabel!
    @IBOutlet weak var secondLabel : UILabel!
    
    @IBOutlet weak var firstViewButton : UIButton!
    @IBOutlet weak var secondViewButton : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        firstLabel.text?.removeAll()
        secondLabel.text?.removeAll()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
