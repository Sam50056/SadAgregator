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
    
    var materials = [JSON]()
    var sizes = [JSON]()
    
    var min = ""
    var max = ""
    
    var selectedMaterials = [String]()
    var selectedSizes = [String]()
    
    var sbrositButtons = [String : UIButton]()
    
    var filterItemSelected : ((JSON , Int) -> ())?
    var minMaxChanged : ((String , String) -> ())?
    
    var sbrositPressed : (([String] , Int) -> ())?
    
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
            
            if sectionIndex == 0{
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                section.boundarySupplementaryItems = [self.createSectionHeader()]
                
                return section
                
            }
            
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
        return getNumberOfSections()
    }
    
    func getNumberOfSections() -> Int{
        
        var number = 0
        
        //Always have price section
        number = number + 1
        
        if !materials.isEmpty{
            number = number + 1
        }
        
        if !sizes.isEmpty {
            number = number + 1
        }
        
        return number
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else if section == 1{
            return materials.count
        }else if section == 2{
            return sizes.count
        }else{
            fatalError("Error section")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if indexPath.section == 0 {
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pricesCell", for: indexPath)
            
            if let minView = cell.viewWithTag(1),
               let maxView = cell.viewWithTag(3),
               let minTextField = cell.viewWithTag(2) as? UITextField,
               let maxTextField = cell.viewWithTag(4) as? UITextField{
                
                minView.layer.cornerRadius = 16
                maxView.layer.cornerRadius = 16
                
                minTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
                maxTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
                
                minTextField.text = min
                maxTextField.text = max
                
            }
            
            return cell
            
        }
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterItemCell", for: indexPath)
        
        if let label = cell.viewWithTag(2) as? UILabel,
           let _ = cell.viewWithTag(1){
            
             if indexPath.section == 1{
                
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
                
                if min == "" && max == ""{
                    sbrositButtons["\(section)"]?.isHidden = true
                }else{
                    sbrositButtons["\(section)"]?.isHidden = false
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
        
        if section == 1{
            
            let selectedMaterialId = materials[indexPath.row]["v"].stringValue
            
            filterItemSelected?(materials[indexPath.row], section)
            
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
            
            filterItemSelected?(sizes[indexPath.row], section)
            
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
        
        var indexPaths = [IndexPath]()
        
        if sectionForSbrosit == 0{
            sbrositPressed?([min , max], sectionForSbrosit)
            min = ""
            max = ""
            indexPaths.append(IndexPath(row: 0, section: sectionForSbrosit))
        }else if sectionForSbrosit == 1{
            sbrositPressed?(selectedMaterials, sectionForSbrosit)
            selectedMaterials.removeAll()
            
            for i in 0...materials.count - 1 {
                indexPaths.append(IndexPath(row: i, section: sectionForSbrosit))
            }
            
        }else if sectionForSbrosit == 2{
            sbrositPressed?(selectedSizes, sectionForSbrosit)
            selectedSizes.removeAll()
            
            for i in 0...sizes.count - 1 {
                indexPaths.append(IndexPath(row: i, section: sectionForSbrosit))
            }
            
        }
        
        sbrositButtons["\(sectionForSbrosit)"]?.isHidden = true
        
        collectionView.reloadItems(at: indexPaths)
        
    }
    
    @objc func filterButtonTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITextField

extension FilterViewController : UITextFieldDelegate{
    
    @objc func textFieldEditingChanged(_ sender : UITextField){
        
        if sender.tag == 2{
            
            min = sender.text ?? ""
            
        }else if sender.tag == 4 {
            
            max = sender.text ?? ""
            
        }
        
        minMaxChanged?(min,max)
        
        if min == "" && max == ""{
            sbrositButtons["0"]?.isHidden = true
        }else{
            sbrositButtons["0"]?.isHidden = false
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if min == "" && max == ""{
            sbrositButtons["0"]?.isHidden = true
        }else{
            sbrositButtons["0"]?.isHidden = false
        }
        
    }
    
}
