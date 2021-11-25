//
//  ZakupkaTableViewCellHeaderCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.09.2021.
//

import UIKit

class ZakupkaTableViewCellHeaderCell: UITableViewCell {
    
    @IBOutlet weak var firstView : UIView!
    @IBOutlet weak var secondView : UIView!
    
    @IBOutlet weak var firstLabel : UILabel!
    @IBOutlet weak var secondLabel : UILabel!
    
    @IBOutlet weak var firstViewButton : UIButton!
    @IBOutlet weak var secondViewButton : UIButton!
    
    @IBOutlet weak var firstImageView : UIImageView!
    @IBOutlet weak var secondImageView : UIImageView!

    var firstButtonTapped : (() -> ())?
    var secondButtonTapped : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstViewButton.addTarget(self, action: #selector(firstViewButtonTapped(_:)), for: .touchUpInside)
        secondViewButton.addTarget(self, action: #selector(secondViewButtonTapped(_:)), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        firstLabel.text?.removeAll()
        secondLabel.text?.removeAll()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func firstViewButtonTapped(_ sender : UIButton){
        firstButtonTapped?()
    }
    
    @objc func secondViewButtonTapped(_ sender : UIButton){
        secondButtonTapped?()
    }
    
}
