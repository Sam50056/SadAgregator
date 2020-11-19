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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.backgroundColor = #colorLiteral(red: 0.8250553269, green: 0.8415564335, blue: 0.8415564335, alpha: 1)
        view.layer.cornerRadius = 8
    }

}
