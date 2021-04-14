//
//  PaymentTableViewCellEditTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import UIKit

class PaymentTableViewCellEditTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var textField : UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.text = ""
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
