//
//  ZakupkaTableViewCellDocumentsTableViewCellImageCollectionViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.10.2021.
//

import UIKit

class ZakupkaTableViewCellDocumentsTableViewCellImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var removeButtonView : UIView!
    @IBOutlet weak var removeButton : UIButton!
    
    var removeButtonTapped : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        removeButtonView.layer.cornerRadius = removeButtonView.bounds.width / 2
        removeButton.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        
    }

}

//MARK: - Actions

extension ZakupkaTableViewCellDocumentsTableViewCellImageCollectionViewCell {
    
    @objc func removeButtonTapped(_ sender : Any){
        removeButtonTapped?()
    }
    
}
