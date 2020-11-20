//
//  PostTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.11.2020.
//

import UIKit

class PostTableViewCell: UITableViewCell , UICollectionViewDataSource  {
    
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias DataSource =  UICollectionViewDiffableDataSource<SectionLayoutKind, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, String>
    
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, String>!
    
    enum SectionLayoutKind : Int , CaseIterable{
        case size , option
        var widthDimension : NSCollectionLayoutDimension{
            switch self {
            case .option:
                return .estimated(110)
            case .size:
                return .estimated(30)
            }
        }
    }
    
    var sizes = [String](){
        didSet{
            applySnapshot()
        }
    }
    
    var options = [String]() {
        didSet{
            applySnapshot()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.collectionViewLayout = createLayout()
        makeDataSource()
        
        collectionView.register(UINib(nibName: "SizeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "sizeCell")
        
        collectionView.register(UINib(nibName: "OptionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionCell")
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == 1 ? sizes.count : options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if collectionView.tag == 1{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! SizeCollectionViewCell
            
            (cell as! SizeCollectionViewCell).label.text = sizes[indexPath.row]
            
        }else if collectionView.tag == 2 {
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! OptionCollectionViewCell
            
            (cell as! OptionCollectionViewCell).label.text = options[indexPath.row]
            
        }
        
        cell.backgroundColor = .red
        
        return cell
        
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, NSCollectionViewLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex)else{return nil}
            
            let widthDimension = sectionLayoutKind.widthDimension
            
            let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: sectionLayoutKind == .size ? .absolute(20) : .fractionalHeight(0.8))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
            
            let groupSize = sectionLayoutKind ==
                .size ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(26))
                :  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.18))
            
            let group = sectionLayoutKind == .size ? NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item]) : NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            group.interItemSpacing = sectionLayoutKind == .size ? .fixed(10) : .fixed(5)
            
            let section = NSCollectionLayoutSection(group: group)
//            section.interGroupSpacing = 1
            sectionLayoutKind == .size ? section.orthogonalScrollingBehavior = .continuous : nil
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0)
            
            return section
        }
        
        return layout
        
    }
    
    func makeDataSource() {
        
        self.dataSource = DataSource(collectionView: collectionView){ (collectionView, indexPath, text) -> UICollectionViewCell? in
            
            var cell = UICollectionViewCell()
            
            guard let section = SectionLayoutKind(rawValue: indexPath.section) else {return cell}
            
            //            let maxIndexForSizes = sizes.count - 1
            //            let maxIndexForOptions = maxIndexForSizes + options.count
            
            if section == .size {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! SizeCollectionViewCell
                
                (cell as! SizeCollectionViewCell).label.text = text
                
            }else if section == .option {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! OptionCollectionViewCell
                
                (cell as! OptionCollectionViewCell).label.text = text
                
            }
            
            return cell
        }
        
    }
    
    func applySnapshot(animatingDifferences: Bool = false ) {
        
        let sections = SectionLayoutKind.allCases
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        
        var sizesSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        sizesSnapshot.append(sizes)
        
        var optionsSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        optionsSnapshot.append(options)
        dataSource.apply(optionsSnapshot, to: .option, animatingDifferences: animatingDifferences)
        dataSource.apply(sizesSnapshot, to: .size, animatingDifferences: animatingDifferences)
        
    }
    
}
