//
//  RatingTableViewCellWithImagesCollectionViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.08.2021.
//

import UIKit

class RatingTableViewCellWithImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }

}
