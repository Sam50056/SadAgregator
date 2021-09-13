//
//  ServicesViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.03.2021.
//

import UIKit
import SwiftUI
import RealmSwift

class ServicesViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    let realm = try! Realm()
    
    private var key = ""
    private var isLogged = false
    private var isVendor = false
    
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
        
        loadUserData()
        
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
        config.interSectionSpacing = 32
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }else if section == 1 , isVendor , isLogged{
            return 1
        }else if section == 2{
            return 2
        }else{
            return 0
        }
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
            
            if indexPath.section == 0{
                
                switch indexPath.row {
                    
                case 0:
                    
                    cellImageView.image = UIImage(systemName: "person.2")
                    
                    serviceNameLabel.text = "Клиенты"
                    
                case 1:
                    
                    cellImageView.image = UIImage(systemName: "person.2.square.stack")
                    
                    serviceNameLabel.text = "Мои закупки"
                    
                case 2:
                    
                    cellImageView.image = UIImage(systemName: "shippingbox")
                    
                    serviceNameLabel.text = "Сборка"
                    
                case 3:
                    
                    cellImageView.image = UIImage(systemName: "doc.text.viewfinder")
                    
                    serviceNameLabel.text = "Сортировка"
                    
                default:
                    break
                }
                
                !isLogged ? (cell.contentView.alpha = 0.5) : (cell.contentView.alpha = 1)
                
            }else if indexPath.section == 1{
                
                cellImageView.image = UIImage(systemName: "cart")
                
                serviceNameLabel.text = "Мои заказы"
                
                cell.contentView.alpha = 1
                
            }else if indexPath.section == 2{
                
                switch indexPath.row{
                    
                case 0:
                    
                    cellImageView.image = UIImage(systemName: "star.fill")
                    
                    serviceNameLabel.text = "Рейтинг поставщиков"
                    
                case 1:
                    
                    cellImageView.image = UIImage(systemName: "star.fill")
                    
                    serviceNameLabel.text = "Рейтинг посредников"
                    
                    
                default:
                    
                    break
                    
                }
                
                cell.contentView.alpha = 1
                
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let index = indexPath.row
        
        if section == 0, isLogged{
            
            if index == 0{
                
                let clientsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientsVC") as! ClientsViewController
                
                navigationController?.pushViewController(clientsVC, animated: true)
                
            }else if index == 1{
                
                
                
            }else if index == 2{
                
                let sborkaView = SborkaView()
                
                let sborkaVC = UIHostingController(rootView: sborkaView)
                
                navigationController?.pushViewController(sborkaVC, animated: true)
                
            }else if index == 3{
                
                let sortVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SortirovkaVC") as! SortirovkaViewController
                
                sortVC.assembly = "1"
                
                navigationController?.pushViewController(sortVC, animated: true)
                
            }
            
        }else if section == 0 , !isLogged{
            
            showSimpleAlertWithOkButton(title: "Требуется авторизация", message: nil)
            
        }else if section == 1{
            
            
            
        }else if section == 2{
            
            if index == 0{
                
                let ratingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VendsRatingVC") as! VendsPopularityRatingViewController
                
                navigationController?.pushViewController(ratingVC, animated: true)
                
            }else if index == 1{
                
                let brokerPopVC = BrokersPopularityViewController()
                
                navigationController?.pushViewController(brokerPopVC, animated: true)
                
            }
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension ServicesViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        let userDataFirst = userDataObject.first
        
        print("Key Realm: \(String(describing: userDataFirst?.key))")
        
        key = userDataFirst?.key ?? ""
        isLogged = userDataFirst?.isLogged ?? false
        isVendor = (userDataFirst?.isVendor ?? "") == "1" ? true : false
        
        collectionView.reloadData()
        
    }
    
}
