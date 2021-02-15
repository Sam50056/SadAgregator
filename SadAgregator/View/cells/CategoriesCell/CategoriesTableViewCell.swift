//
//  CategoriesTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.02.2021.
//

import UIKit
import SwiftyJSON

class CategoriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    var categoryCellTapped : ((String) -> ())?
    
    var categories = [JSON]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

//MARK: - UICollectionView

extension CategoriesTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count == 0 ? 0 : categories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.view.layer.cornerRadius = 8
        
        //This is an additional cell
        if indexPath.row == 0{
            
            cell.firstLabel.text = "См. все"
            cell.secondLabel.text = "Категории"
            
            return cell
        }
       
        let category = categories[indexPath.row - 1] //We do -1 because we added one more cell above
        
        cell.firstLabel.text = category["capt"].stringValue
        
        cell.secondLabel.text = category["descr"].stringValue
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categoryCellTapped?(categories[indexPath.row]["id"].stringValue)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
    
}
