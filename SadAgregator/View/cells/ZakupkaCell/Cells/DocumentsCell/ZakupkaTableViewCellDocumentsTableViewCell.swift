//
//  ZakupkaTableViewCellDocumentsTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.10.2021.
//

import UIKit
import SDWebImage

class ZakupkaTableViewCellDocumentsTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView : UICollectionView!
    
    var images = [ZakupkaTableViewCell.ImageItem](){
        didSet{
            collectionView.reloadData()
        }
    }
    
    var removeImage : ((Int) -> Void)?
    var imageTapped : ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.collectionViewLayout = createLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ZakupkaTableViewCellDocumentsTableViewCellImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

//MARK: - CollectionView

extension ZakupkaTableViewCellDocumentsTableViewCell : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, NSCollectionViewLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let section: NSCollectionLayoutSection
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(74))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            group.interItemSpacing = .fixed(10)
            
            section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.orthogonalScrollingBehavior = .continuous
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 16, bottom: 0, trailing: 0)
            
            return section
            
        }
        
        return layout
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ZakupkaTableViewCellDocumentsTableViewCellImageCollectionViewCell
        
        let item = images[indexPath.row]
        
        cell.imageView.sd_setImage(with: URL(string: item.image), completed: nil)
        
        cell.imageView.layer.cornerRadius = 8
        cell.imageView.clipsToBounds = true
        
        cell.removeButtonTapped = { [weak self] in
            self?.removeImage?(indexPath.row)
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageTapped?(indexPath.row)
    }
    
}
