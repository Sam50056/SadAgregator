//
//  TovarTableViewCellCollectionViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.04.2021.
//

import UIKit

class TovarTableViewCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView : UIImageView!
    
    @IBOutlet weak var bgView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
