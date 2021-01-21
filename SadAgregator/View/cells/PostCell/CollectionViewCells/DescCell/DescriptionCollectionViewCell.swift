//
//  DescriptionCollectionViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.01.2021.
//

import UIKit

class DescriptionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView : UIView!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var button : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 12
        
    }
    
}
