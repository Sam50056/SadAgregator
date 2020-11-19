//
//  PostTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.11.2020.
//

import UIKit

class PostTableViewCell: UITableViewCell , UICollectionViewDataSource  {
    
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var ramzmeriLabel: UILabel!
    
    @IBOutlet weak var sizeCollectionView: UICollectionView!
    
    var sizes : [String]?{
        didSet{
            
            sizeCollectionView.reloadData()
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sizeCollectionView.register(UINib(nibName: "SizeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "sizeCell")
        sizeCollectionView.dataSource = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sizes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! SizeCollectionViewCell
        
        cell.label.text = sizes![indexPath.row]
        
        return cell
        
    }
    
}
