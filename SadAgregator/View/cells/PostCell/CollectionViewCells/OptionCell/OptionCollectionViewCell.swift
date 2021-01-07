//
//  OptionCollectionViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.11.2020.
//

import UIKit

class OptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.backgroundColor = #colorLiteral(red: 0.9598904252, green: 0.9648228288, blue: 0.9732922912, alpha: 1)
        view.layer.cornerRadius = 8
    }

}
