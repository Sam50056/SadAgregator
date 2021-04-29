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
        
        collectionView.collectionViewLayout = createLayout()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

//MARK: - UICollectionView

extension CategoriesTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, NSCollectionViewLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            
            let section: NSCollectionLayoutSection
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(60))
            
            let group =  NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            group.interItemSpacing = .fixed(10)
            
            section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.orthogonalScrollingBehavior = .continuous
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 5, trailing: 0)
            
            return section
            
        }
        
        return layout
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count == 0 ? 0 : categories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        
        cell.view.layer.cornerRadius = 8
        
        //This is an additional cell
        if indexPath.row == 0{
            
            cell.firstLabel.text = "Категории"
            
            return cell
        }
       
        let category = categories[indexPath.row - 1] //We do -1 because we added one more cell above
        
        cell.firstLabel.text = category["capt"].stringValue
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard indexPath.row != 0 else {
            categoryCellTapped?("")
            return
        }
        
        categoryCellTapped?(categories[indexPath.row - 1]["id"].stringValue)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
//    }
    
}
