//
//  PostTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.11.2020.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell , UICollectionViewDataSource  {
    
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias DataSource =  UICollectionViewDiffableDataSource<SectionLayoutKind, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, String>
    
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, String>!
    
    enum SectionLayoutKind : Int , CaseIterable{
        case size , option , photo
        var widthDimension : NSCollectionLayoutDimension{
            switch self {
            case .option:
                return .estimated(110)
            case .size:
                return .estimated(30)
            case .photo:
                return .fractionalWidth(0.5)
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
    
    var images = [String](){
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
        
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
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
            
            let section: NSCollectionLayoutSection
            
            if sectionLayoutKind == .size || sectionLayoutKind == .option{
                
                let widthDimension = sectionLayoutKind.widthDimension
                
                let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: sectionLayoutKind == .size ? .absolute(20) : .absolute(30))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
                
                let groupSize = sectionLayoutKind ==
                    .size ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(22))
                    :  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(32))
                
                let group = sectionLayoutKind == .size ? NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item]) : NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                group.interItemSpacing = sectionLayoutKind == .size ? .fixed(10) : .fixed(5)
                
                section = NSCollectionLayoutSection(group: group)
                //            section.interGroupSpacing = 1
                sectionLayoutKind == .size ? section.orthogonalScrollingBehavior = .continuous : nil
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0)
                
            }else if sectionLayoutKind == .photo{
                
                let leadingItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                                       heightDimension: .fractionalHeight(1)))
                leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let trailingItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(0.3)))
                trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let trailingGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                                       heightDimension: .fractionalHeight(1)),
                    subitem: trailingItem, count: 2)
                
                let nestedGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(0.77)),
                    subitems: [leadingItem, trailingGroup])
                
                section = NSCollectionLayoutSection(group: nestedGroup)
                
                section.orthogonalScrollingBehavior = .continuous
                
            }else {
                fatalError("Wrong section")
            }
            
            return section
        }
        
        return layout
        
    }
    
    func makeDataSource() {
        
        self.dataSource = DataSource(collectionView: collectionView){ (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            var cell = UICollectionViewCell()
            
            guard let section = SectionLayoutKind(rawValue: indexPath.section) else {return cell}
            
            if section == .size {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! SizeCollectionViewCell
                
                (cell as! SizeCollectionViewCell).label.text = item
                
            }else if section == .option {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! OptionCollectionViewCell
                
                (cell as! OptionCollectionViewCell).label.text = item
                
            }else if section == .photo {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
                
                if let url = URL(string: item){
                    
                    (cell as! PhotoCollectionViewCell).imageView.sd_setImage(with: url, placeholderImage:nil)
                    
                }
                
            }
            
            return cell
        }
        
    }
    
    func applySnapshot(animatingDifferences: Bool = false) {
        
        let sections = SectionLayoutKind.allCases
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        
        
        var sizesSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        sizesSnapshot.append(sizes)
        
        var optionsSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        optionsSnapshot.append(options)
        
        var photosSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        photosSnapshot.append(images)
        
        dataSource.apply(optionsSnapshot, to: .option, animatingDifferences: animatingDifferences)
        dataSource.apply(sizesSnapshot, to: .size, animatingDifferences: animatingDifferences)
        dataSource.apply(photosSnapshot,to: .photo , animatingDifferences: animatingDifferences)
        
    }
    
}
