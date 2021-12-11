//
//  ZakazTableViewCellCommentTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.12.2021.
//

import UIKit

class ZakazTableViewCellCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var commentImageView : UIImageView!
    @IBOutlet weak var commentLabel : UILabel!
    @IBOutlet weak var commentTextView : UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 8
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
