//
//  FilterViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.02.2021.
//

import UIKit
import SwiftyJSON

class FilterViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var darkGray = #colorLiteral(red: 0.4717689157, green: 0.4718403816, blue: 0.4717532396, alpha: 1)
    
    var prices = [JSON]()
    var materials = [JSON]()
    var sizes = [JSON]()
    
    var selectedPrices = [String]()
    var selectedMaterials = [String]()
    var selectedSizes = [String]()
    
    var sbrositButtons = [String : UIButton]()
    
    var filterItemSelected : ((JSON) -> ())?
    
    var sbrositPressed : (([String]) -> ())?
//    var sectionForSbrosit : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = createLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y <= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            print("DRAG VELOCITY : \(dragVelocity)")
            if dragVelocity.y >= -2550 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
}

//MARK: - UICollectionView

extension FilterViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
                                                   heightDimension: .estimated(40))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            section.boundarySupplementaryItems = [self.createSectionHeader()]
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        // 1
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                             heightDimension: .estimated(60))
        
        // 2
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize,
                                                                              elementKind: UICollectionView.elementKindSectionHeader,
                                                                              alignment: .top)
        return layoutSectionHeader
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0{
            return prices.count
        }else if section == 1{
            return materials.count
        }else if section == 2{
            return sizes.count
        }else{
            fatalError("Error section")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterItemCell", for: indexPath)
        
        if let label = cell.viewWithTag(2) as? UILabel,
           let _ = cell.viewWithTag(1){
            
            if indexPath.section == 0{
                
                label.text = prices[indexPath.row]["c"].stringValue
                
                let id = prices[indexPath.row]["v"].stringValue
                
                if !selectedPrices.contains(id){
                    (cell.viewWithTag(1))?.backgroundColor = UIColor(named: "gray")
                    (cell.viewWithTag(2) as? UILabel)?.textColor = .darkGray
                }else{
                    (cell.viewWithTag(1))?.backgroundColor = .systemBlue
                    (cell.viewWithTag(2) as? UILabel)?.textColor = .white
                }
                
            }else if indexPath.section == 1{
                
                label.text = materials[indexPath.row]["c"].stringValue
                
                let id = materials[indexPath.row]["v"].stringValue
                
                if !selectedMaterials.contains(id){
                    (cell.viewWithTag(1))?.backgroundColor = UIColor(named: "gray")
                    (cell.viewWithTag(2) as? UILabel)?.textColor = .darkGray
                }else{
                    (cell.viewWithTag(1))?.backgroundColor = .systemBlue
                    (cell.viewWithTag(2) as? UILabel)?.textColor = .white
                }
                
            }else if indexPath.section == 2{
                
                label.text = sizes[indexPath.row]["c"].stringValue
                
                let id = sizes[indexPath.row]["v"].stringValue
                
                if !selectedSizes.contains(id){
                    (cell.viewWithTag(1))?.backgroundColor = UIColor(named: "gray")
                    (cell.viewWithTag(2) as? UILabel)?.textColor = .darkGray
                }else{
                    (cell.viewWithTag(1))?.backgroundColor = .systemBlue
                    (cell.viewWithTag(2) as? UILabel)?.textColor = .white
                }
                
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
        
        let section = indexPath.section
        
        if let label = header.viewWithTag(1) as? UILabel , let button = header.viewWithTag(2) as? UIButton{
            
            if section == 0{
                
                label.text = "Цена"
                
                sbrositButtons["0"] = button
                
                if selectedPrices.isEmpty{
                    sbrositButtons["\(section)"]!.isHidden = true
                }else{
                    sbrositButtons["\(section)"]!.isHidden = false
                }
                
                button.addTarget(self, action: #selector(sbrositButtonTapped(_:)), for: .touchUpInside)
                
                button.tag = section
                
            }else if section == 1{
                
                label.text = "Материал"
                
                sbrositButtons["1"] = button
                
                if selectedMaterials.isEmpty{
                    sbrositButtons["\(section)"]!.isHidden = true
                }else{
                    sbrositButtons["\(section)"]!.isHidden = false
                }
                
                button.addTarget(self, action: #selector(sbrositButtonTapped(_:)), for: .touchUpInside)
                
                button.tag = section
                
            }else if section == 2{
                
                label.text = "Размер"
                
                sbrositButtons["2"] = button
                
                if selectedSizes.isEmpty{
                    sbrositButtons["\(section)"]!.isHidden = true
                }else{
                    sbrositButtons["\(section)"]!.isHidden = false
                }
                
                button.addTarget(self, action: #selector(sbrositButtonTapped(_:)), for: .touchUpInside)
                
                button.tag = section
                
            }
            
        }
        
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 0{
            
            let selectedPriceId = prices[indexPath.row]["v"].stringValue
            
            filterItemSelected?(prices[indexPath.row])
            
            if selectedPrices.contains(selectedPriceId){
                selectedPrices.remove(at: selectedPrices.firstIndex(of: selectedPriceId)!)
            }else{
                selectedPrices.append(selectedPriceId)
            }
            
            if selectedPrices.isEmpty{
                sbrositButtons["\(section)"]?.isHidden = true
            }else{
                sbrositButtons["\(section)"]?.isHidden = false
            }
            
        }else if section == 1{
            
            let selectedMaterialId = materials[indexPath.row]["v"].stringValue
            
            filterItemSelected?(materials[indexPath.row])
            
            if selectedMaterials.contains(selectedMaterialId){
                selectedMaterials.remove(at: selectedMaterials.firstIndex(of: selectedMaterialId)!)
            }else{
                selectedMaterials.append(selectedMaterialId)
            }
            
            if selectedMaterials.isEmpty{
                sbrositButtons["\(section)"]?.isHidden = true
            }else{
                sbrositButtons["\(section)"]?.isHidden = false
            }
            
        }else if section == 2{
            
            let selectedSizeId = sizes[indexPath.row]["v"].stringValue
            
            filterItemSelected?(sizes[indexPath.row])
            
            if selectedSizes.contains(selectedSizeId){
                selectedSizes.remove(at: selectedSizes.firstIndex(of: selectedSizeId)!)
            }else{
                selectedSizes.append(selectedSizeId)
            }
            
            if selectedSizes.isEmpty{
                sbrositButtons["\(section)"]?.isHidden = true
            }else{
                sbrositButtons["\(section)"]?.isHidden = false
            }
            
        }
        
        collectionView.reloadItems(at: [indexPath])
        
    }
    
    //MARK: - Callback funcs
    
    @objc func sbrositButtonTapped(_ sender : UIButton) {
        
        let sectionForSbrosit = sender.tag
        
        if sectionForSbrosit == 0{
            sbrositPressed?(selectedPrices)
            selectedPrices.removeAll()
        }else if sectionForSbrosit == 1{
            sbrositPressed?(selectedMaterials)
            selectedMaterials.removeAll()
        }else if sectionForSbrosit == 2{
            sbrositPressed?(selectedSizes)
            selectedSizes.removeAll()
        }
        
        sbrositButtons["\(sectionForSbrosit)"]?.isHidden = true
        
        collectionView.reloadSections([sectionForSbrosit])
        
    }
    
    @objc func filterButtonTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
