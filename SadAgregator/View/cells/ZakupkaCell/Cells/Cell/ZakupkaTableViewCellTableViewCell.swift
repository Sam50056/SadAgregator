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
    @IBOutlet weak var rightSideButton : UIButton!
    
    var rightSideButtonPressed : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rightSideButton.setTitle("", for: .normal)
        rightSideButton.addTarget(self, action: #selector(rightSideButtonPressedAction), for: .touchUpInside)
 }
    
    @IBAction private func rightSideButtonPressedAction(_ sender : UIButton) {
        rightSideButtonPressed?()
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
