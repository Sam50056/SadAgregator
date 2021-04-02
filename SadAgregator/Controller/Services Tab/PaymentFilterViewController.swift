//
//  PaymentFilterViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.03.2021.
//

import UIKit

class PaymentFilterViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    var maxSumFromApi : String?
    var minDateFromApi : String?{
        didSet{
            
            let firstIndex = minDateFromApi!.index(minDateFromApi!.startIndex, offsetBy: 2)
            let secondIndex = minDateFromApi!.index(minDateFromApi!.startIndex, offsetBy: 5)
            
            minDateFromApi!.insert(".", at: firstIndex)
            minDateFromApi!.insert(".", at: secondIndex)
        }
    }
    
    var source : Int?
    var opType : Int?
    var commentQuery : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Фильтр"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(closeBarButtonTapped(_:)))
        
        enableHero()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableHero()
    }
    
}

//MARK: - Actions

extension PaymentFilterViewController{
    
    @IBAction func closeBarButtonTapped(_ sender : UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - CollectionView

extension PaymentFilterViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            if sectionIndex == 0 || sectionIndex == 2 || sectionIndex == 4 || sectionIndex == 7{
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                return section
                
            }else if sectionIndex == 6{
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 10, bottom: 0, trailing: 10)
                
                return section
                
            }else if sectionIndex == 9{
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
                
                return section
                
            }else if sectionIndex == 10{
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                                       heightDimension: .estimated(40))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 10, bottom: 0, trailing: 10)
                
                return section
                
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                                   heightDimension: .estimated(30))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.interGroupSpacing = 24
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 11
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 || section == 2 || section == 4 || section == 6 || section == 7 {
            return 1
        }else if section == 9 || section == 10{
            return 1
        }else{
            return 2
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        let section = indexPath.section
        
        if section == 0{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            setUpHeaderCell(with: "Тип операции", for: cell)
            
            
        }else if section == 1{
            
            switch indexPath.row {
            case 0:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Пополнение"
                
                cell.contentView.layer.cornerRadius = 8
                
                cell.contentView.backgroundColor = opType != indexPath.row ? UIColor(named: "gray") : .systemBlue
                label.textColor = opType != indexPath.row ? UIColor(named: "blackwhite") : .white
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Списание"
                
                cell.contentView.layer.cornerRadius = 8
                
                cell.contentView.backgroundColor = opType != indexPath.row ? UIColor(named: "gray") : .systemBlue
                label.textColor = opType != indexPath.row ? UIColor(named: "blackwhite") : .white
                
            default:
                return cell
            }
            
        }else if section == 2{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            setUpHeaderCell(with: "Источник операции", for: cell)
            
            
        }else if section == 3{
            
            switch indexPath.row {
            case 0:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Ручная"
                
                cell.contentView.layer.cornerRadius = 8
                
                cell.contentView.backgroundColor = source != indexPath.row ? UIColor(named: "gray") : .systemBlue
                label.textColor = source != indexPath.row ? UIColor(named: "blackwhite") : .white
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Системная"
                
                cell.contentView.layer.cornerRadius = 8
                
                cell.contentView.backgroundColor = source != indexPath.row ? UIColor(named: "gray") : .systemBlue
                label.textColor = source != indexPath.row ? UIColor(named: "blackwhite") : .white
                
            default:
                return cell
            }
            
            
        }else if section == 4{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            setUpHeaderCell(with: "Цена", for: cell)
            
        }else if section == 5{
            
            switch indexPath.row {
            case 0:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "от 16477"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "до \(maxSumFromApi ?? "")"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            default:
                return cell
            }
            
        }else if section == 6{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
            
            let margin: CGFloat = 4
            let width = cell.bounds.width - (2 * margin)
            let height: CGFloat = 12
            
            let rangeSlider = RangeSlider(frame: CGRect(x: 0, y: 0,width: width, height: height))
            
            rangeSlider.trackHighlightTintColor = .systemBlue
            rangeSlider.trackTintColor = UIColor(named: "gray")!
            rangeSlider.thumbImage = #imageLiteral(resourceName: "Oval")
            rangeSlider.highlightedThumbImage = #imageLiteral(resourceName: "HighlightedOval")
            
            cell.addSubview(rangeSlider)
            
            rangeSlider.translatesAutoresizingMaskIntoConstraints = false
            
            var constraints = [NSLayoutConstraint]()
            
            constraints.append(rangeSlider.centerYAnchor.constraint(equalTo: cell.centerYAnchor))
            constraints.append(rangeSlider.centerXAnchor.constraint(equalTo: cell.centerXAnchor))
            
            constraints.append(rangeSlider.widthAnchor.constraint(equalToConstant: width))
            constraints.append(rangeSlider.heightAnchor.constraint(equalToConstant: height))
            
            NSLayoutConstraint.activate(constraints)
            
            
            rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)),
                                  for: .valueChanged)
            
        }else if section == 7{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            setUpHeaderCell(with: "Дата", for: cell)
            
        }else if section == 8{
            
            switch indexPath.row {
            case 0:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "с \(minDateFromApi ?? "")"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "по 1.10.2020"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            default:
                return cell
            }
            
        }else if section == 9{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFIeldCell", for: indexPath)
            
            guard let bgView = cell.viewWithTag(1) , let textField = cell.viewWithTag(2) as? UITextField else {return cell}
            
            textField.placeholder = "Комментарий"
            
            bgView.layer.cornerRadius = 6
            
        }else if section == 10{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Показать операции"
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 17)
            
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.backgroundColor = .systemBlue
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 1{
            opType = indexPath.row
            collectionView.reloadSections([section])
        }else if section == 3{
            source = indexPath.row
            collectionView.reloadSections([section])
        }
        
        print("Index path row : \(indexPath.row) , section : \(indexPath.section)")
        
    }
    
    //MARK: - Cells Setup
    
    func setUpHeaderCell(with header : String, for cell : UICollectionViewCell){
        
        guard let label = cell.viewWithTag(1) as? UILabel else {return}
        
        label.text = header
        
    }
    
    func setUpSingleLabelCell(with text : String, for cell : UICollectionViewCell){
        
        guard let label = cell.viewWithTag(1) as? UILabel else {return}
        
        label.text = text
        
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.backgroundColor = UIColor(named: "gray")
        
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        let values = "(\(rangeSlider.lowerValue) \(rangeSlider.upperValue))"
        print("Range slider value changed: \(values)")
    }
    
}
