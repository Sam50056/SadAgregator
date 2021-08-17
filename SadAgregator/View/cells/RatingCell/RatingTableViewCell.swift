//
//  RatingTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.08.2021.
//

import UIKit
import Cosmos

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel : UILabel!
    @IBOutlet weak var ratingView : CosmosView!
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var dateLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        authorLabel.text?.removeAll()
        textView.text?.removeAll()
        dateLabel.text?.removeAll()
        ratingView.rating = 0
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
