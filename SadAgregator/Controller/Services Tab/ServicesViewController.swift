//
//  ServicesViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.03.2021.
//

import UIKit

class ServicesViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Сервисы"
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
}

//MARK: - UICollectionView

extension ServicesViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(60))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            section.interGroupSpacing = 8
            
            return section
            
            
            //            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
            //                                                  heightDimension: .fractionalHeight(1.0))
            //            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            //
            //            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
            //                                                   heightDimension: .estimated(40))
            //            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            //
            //            let section = NSCollectionLayoutSection(group: group)
            //            section.orthogonalScrollingBehavior = .continuous
            //            section.interGroupSpacing = 16
            //            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            //
            //            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath)
        
        if let cellImageView = cell.viewWithTag(1) as? UIImageView ,
           let serviceNameLabel = cell.viewWithTag(2) as? UILabel,
           let secondView = cell.viewWithTag(3){
            
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.backgroundColor = UIColor(named: "gray")
            
            secondView.layer.cornerRadius = 5
            
            switch indexPath.row {
            
            case 0:
                
                cellImageView.image = UIImage(systemName: "person.2")
                
                serviceNameLabel.text = "Клиенты"
                
            case 1:
                
                cellImageView.image = UIImage(systemName: "person.badge.plus")
                
                serviceNameLabel.text = "Поставщики"
                
            case 2:
                
                cellImageView.image = UIImage(systemName: "person.3")
                
                serviceNameLabel.text = "Посредники"
                
            case 3:
                
                cellImageView.image = UIImage(systemName: "person.2.square.stack")
                
                serviceNameLabel.text = "Закупки"
                
            case 4:
                
                cellImageView.image = UIImage(systemName: "shippingbox")
                
                serviceNameLabel.text = "Сборка"
                
            case 5:
                
                cellImageView.image = UIImage(systemName: "doc.text.viewfinder")
                
                serviceNameLabel.text = "Сортировка"
                 
                
            default:
                break
            }
            
            
        }
        
        return cell
        
    }
    
}
