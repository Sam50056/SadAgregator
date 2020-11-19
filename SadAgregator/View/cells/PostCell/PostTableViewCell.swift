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
    @IBOutlet weak var optionCollectionView: UICollectionView!
    
    @IBOutlet weak var sizesViewHeight: NSLayoutConstraint!
    
    var sizes : [String]?{
        didSet{
            sizeCollectionView.reloadData()
        }
    }
    
    var options : [String]? {
        didSet{
            optionCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sizeCollectionView.register(UINib(nibName: "SizeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "sizeCell")
        sizeCollectionView.dataSource = self
        
        optionCollectionView.register(UINib(nibName: "OptionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionCell")
        optionCollectionView.dataSource = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 1 ? sizes?.count ?? 0 : options?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if collectionView.tag == 1{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! SizeCollectionViewCell
            
            (cell as! SizeCollectionViewCell).label.text = sizes![indexPath.row]
            
        }else if collectionView.tag == 2 {
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! OptionCollectionViewCell
            
            (cell as! OptionCollectionViewCell).label.text = options![indexPath.row]
            
        }
        
        return cell
        
    }
    
}
