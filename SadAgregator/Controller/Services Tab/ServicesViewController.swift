//
//  ServicesViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.03.2021.
//

import UIKit
import SwiftUI
import RealmSwift
import SwiftyJSON

class ServicesViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    let realm = try! Realm()
    
    private var key = ""
    private var isLogged = false
    private var isVendor = false
    
    let dataManager = NoAnswerDataManager()
    
    var servicesJsonData : JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Сервисы"
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dismiss(animated: true) //This is for content VC if it's slided from QR VC 
        
        navigationController?.isNavigationBarHidden = false
        
        loadUserData()
        
        if isLogged{
            
            refresh()
            
        }
        
    }
    
}

//MARK: - Functions

extension ServicesViewController {
    
    func refresh(){
        
        dataManager.sendNoAnswerDataRequest(urlString: "https://agrapi.tk-sad.ru/agr_services.GetInfo?AKey=\(key)") { data, error in
            
            DispatchQueue.main.async { [weak self] in
                
                if let error = error {
                    print("Error with Services Get Info : \(error)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    self?.servicesJsonData = data!["services"]
                    
                    self?.collectionView.reloadData()
                    
                }else{
                    
                    if let errorText = data!["msg"].string , errorText != ""{
                        self?.showSimpleAlertWithOkButton(title: "Ошибка", message: errorText)
                    }
                    
                }
                
            }
            
        }
        
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
           let secondLabel = cell.viewWithTag(3) as? UILabel{
            
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.backgroundColor = UIColor(named: "gray")
            
            secondLabel.textColor = .systemBlue
            secondLabel.text = ""
            
            if indexPath.section == 0{
                
                switch indexPath.row {
                    
                case 0:
                    
                    cellImageView.image = UIImage(systemName: "person.2")
                    
                    serviceNameLabel.text = "Клиенты"
                    
                    if let clientsBalance = servicesJsonData?["clients_balance"].string , clientsBalance != ""  , clientsBalance != "0" , isLogged{
                        secondLabel.text = clientsBalance + " руб"
                        if clientsBalance.contains("-"){
                            secondLabel.textColor = .red
                        }
                    }
                    
                case 1:
                    
                    cellImageView.image = UIImage(systemName: "person.2.square.stack")
                    
                    serviceNameLabel.text = "Мои закупки"
                    
                    if let pursCount = servicesJsonData?["purs_cnt"].string , pursCount != "" , pursCount != "0" , isLogged{
                        secondLabel.text = pursCount
                    }
                    
                case 2:
                    
                    cellImageView.image = UIImage(systemName: "shippingbox")
                    
                    serviceNameLabel.text = "Сборка"
                    
                    if let servicesJsonData = servicesJsonData {
                        
                        let assemblyWaitItems = servicesJsonData["assembly_wait_items"].stringValue
                        let assemblyWaitCost = servicesJsonData["assembly_wait_cost"].stringValue
                        
                        if !assemblyWaitItems.isEmpty && assemblyWaitItems != "0" && !assemblyWaitCost.isEmpty && assemblyWaitCost != "0" , isLogged{
                            secondLabel.text = assemblyWaitItems + " / " + assemblyWaitCost + " руб"
                        }
                        
                    }
                    
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
                
                if let ordersCount = servicesJsonData?["orders_cnt"].string , ordersCount != ""{
                    secondLabel.text = ordersCount
                }
                
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
                
                let myZakupkiVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyZakupkiVC") as! MyZakupkiViewController
                
                navigationController?.pushViewController(myZakupkiVC, animated: true)
                
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
            
            let myZakaziVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyZakaziVC") as! MyZakaziViewController
            
            navigationController?.pushViewController(myZakaziVC, animated: true)
            
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
