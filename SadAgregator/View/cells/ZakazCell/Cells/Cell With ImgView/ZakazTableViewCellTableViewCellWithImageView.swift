//
//  ZakazTableViewCellTableViewCellWithImageView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 28.01.2022.
//

import UIKit

class ZakazTableViewCellTableViewCellWithImageView: UITableViewCell {
    
    @IBOutlet weak var imgView1 : UIImageView!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var imgView2 : UIImageView!
    @IBOutlet weak var imgView2Button : UIButton!
    
    var imgView2ButtonTapped : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = ""
        
        imgView1.image = nil
        imgView2.image = nil
        
    }
    
    override func prepareForReuse() {
        
        label.text = ""
        
        imgView1.image = nil
        imgView2.image = nil
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    //MARK: - Actions
    
    @IBAction private func imgView2ButtonTapped(_ sender : UIButton){
        imgView2ButtonTapped?()
    }
    
}
