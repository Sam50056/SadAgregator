//
//  SizeCollectionViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.11.2020.
//

import UIKit

class SizeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.layer.cornerRadius = 5
        view.backgroundColor = #colorLiteral(red: 0.9591086507, green: 0.9659582973, blue: 0.9731834531, alpha: 1)
        
    }

}
