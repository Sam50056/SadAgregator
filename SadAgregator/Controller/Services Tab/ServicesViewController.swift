//
//  ServicesViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.03.2021.
//

import UIKit
import SwiftUI

class ServicesViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Сервисы"
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
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
            
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath)
        
        if let cellImageView = cell.viewWithTag(1) as? UIImageView ,
           let serviceNameLabel = cell.viewWithTag(2) as? UILabel,
           let secondView = cell.viewWithTag(3){
            
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.backgroundColor = UIColor(named: "gray")
            
            secondView.layer.cornerRadius = 5
            
            secondView.isHidden = true
            
            switch indexPath.row {
            
            case 0:
                
                cellImageView.image = UIImage(systemName: "person.2")
                
                serviceNameLabel.text = "Клиенты"
                
            case 1:
                
                cellImageView.image = UIImage(systemName: "star.fill")
                
                serviceNameLabel.text = "Рейтинг Поставщиков"
                
            case 2:
                
                cellImageView.image = UIImage(systemName: "shippingbox")
                
                serviceNameLabel.text = "Сборка"
                
            case 3:
                
                cellImageView.image = UIImage(systemName: "person.3")
                
                serviceNameLabel.text = "Посредники"
                
            case 4:
                
                cellImageView.image = UIImage(systemName: "person.2.square.stack")
                
                serviceNameLabel.text = "Закупки"
                
            case 5:
                
                cellImageView.image = UIImage(systemName: "person.badge.plus")
                
                serviceNameLabel.text = "Поставщики"
                
            case 6:
                
                cellImageView.image = UIImage(systemName: "doc.text.viewfinder")
                
                serviceNameLabel.text = "Сортировка"
                
                
            default:
                break
            }
            
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 1{
            
            let ratingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VendsRatingVC") as! VendsPopularityRatingViewController
            
            navigationController?.pushViewController(ratingVC, animated: true)
            
        }else if indexPath.row == 0{
            
            let clientsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientsVC") as! ClientsViewController
            
            navigationController?.pushViewController(clientsVC, animated: true)
            
        }else if indexPath.row == 2{
            
            let sborkaView = SborkaView()
            
            sborkaView.sborkaViewModel.key = getKey()!
            
            let sborkaVC = UIHostingController(rootView: sborkaView)
            
            navigationController?.pushViewController(sborkaVC, animated: true)
            
        }
        
    }
    
}
