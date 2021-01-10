//
//  PostTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.11.2020.
//

import UIKit
import SDWebImage
import Hero
import SwiftyJSON

class PostTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var vendorLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var postedLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var vigruzitImageView: UIImageView!
    @IBOutlet weak var vigruzitView : UIView!
    
    @IBOutlet weak var likeButtonImageView: UIImageView!
    @IBOutlet weak var likeButton : UIButton!
    
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
            if !sizes.isEmpty{sizes.insert("Размеры:", at: 0)}
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
    
    let contentInsets : CGFloat = 2
    
    var height : CGFloat {
        
        if options.isEmpty{
            
            if sizes.isEmpty{
                return 0.95
            }
            
            return 0.92
            
        }else{
            
            if options.count > 3 {
                
                if options.count >= 5{
                    
                    if options.count >= 8 {
                        return 0.68
                    }
                    
                    return 0.76
                    
                }
                
                return 0.78
                
            }
            
            return 0.83
            
        }
        
    }
    
    var compression : Int{
        
        if self.images.count >= 6{
            
            if self.images.count >= 8{
                return 250
            }
            
            return 340
            
        }else{
            
            if self.images.count > 4{
                
                return 340
                
            }
            
            return 550
            
        }
        
    }
    
    var delegate : PostCellCollectionViewActionsDelegate?
    
    lazy var postLikeDataManager = PostLikeDataManager()
    
    var like : String = ""
    
    var key : String?
    var id : String?
    
    var vkLinkUrlString : String?
    
    var vendorLabelButtonCallBack : (() -> ())?
    var byLabelButtonCallback : (() -> ())?
    var soobshitButtonCallback : (() -> ())?
    
    //MARK: - Cell Stuff
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.collectionViewLayout = createLayout()
        makeDataSource()
        
        collectionView.register(UINib(nibName: "SizeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "sizeCell")
        
        collectionView.register(UINib(nibName: "OptionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "optionCell")
        
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        
        collectionView.register(UINib(nibName: "TextLabelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "textLabelCell")
        
        vigruzitImageView.layer.cornerRadius = 5
        
        postLikeDataManager.delegate = self
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK: - Compositional Layout
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [self] (sectionIndex, NSCollectionViewLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex)else{return nil}
            
            let section: NSCollectionLayoutSection
            
            if sectionLayoutKind == .option{
                
                let widthDimension = sectionLayoutKind.widthDimension
                
                let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension:.fractionalHeight(0.8))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: !options.isEmpty ? .fractionalHeight(0.08) : .absolute(0))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                group.interItemSpacing = .fixed(8)
                
                section = NSCollectionLayoutSection(group: group)
                //            section.interGroupSpacing = 1
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0)
                
            } else if sectionLayoutKind == .size {
                
                let widthDimension = sectionLayoutKind.widthDimension
                
                let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .fractionalHeight(1))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: !sizes.isEmpty ? .fractionalHeight(0.05) : .absolute(0))
                
                let group =  NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                group.interItemSpacing = .fixed(10)
                
                section = NSCollectionLayoutSection(group: group)
                //            section.interGroupSpacing = 1
                section.orthogonalScrollingBehavior = .continuous
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0)
                
            }else if sectionLayoutKind == .photo {
                
                if self.images.count == 1 {
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(height)), subitems: [leadingItem])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 2 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(height)), subitem: leadingItem, count: 2)
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 3 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1)), subitem: trailingItem, count: 2)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingItem, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 4 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1)), subitem: trailingItem, count: 3)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingItem, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 5 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1)), subitem: leadingItem, count: 2)
                    
                    let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1)), subitem: trailingItem, count: 3)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingGroup, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 6 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let trailingTopItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
                    trailingTopItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let trailingBottomItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
                    trailingBottomItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let trailingBottomHGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitem: trailingBottomItem, count: 2)
                    
                    let trailingBottomVGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitem: trailingBottomHGroup, count: 2)
                    
                    let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)), subitems: [trailingTopItem, trailingBottomVGroup])
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingItem, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 7 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)), subitem: leadingItem, count: 2)
                    
                    let middleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)))
                    middleItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let middleGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)), subitem: middleItem, count: 4)
                    
                    let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingGroup, middleGroup, trailingItem])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 8 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)), subitem: leadingItem, count: 2)
                    
                    let middleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)))
                    middleItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let middleGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)), subitem: middleItem, count: 4)
                    
                    let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)), subitem: trailingItem, count: 2)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingGroup, middleGroup, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 9 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)), subitem: leadingItem, count: 2)
                    
                    let middleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)))
                    middleItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let middleGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)), subitem: middleItem, count: 4)
                    
                    let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.33)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)), subitem: trailingItem, count: 3)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingGroup, middleGroup, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else if self.images.count == 10 {
                    
                    let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)), subitem: leadingItem, count: 2)
                    
                    let middleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)))
                    middleItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let middleGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)), subitem: middleItem, count: 4)
                    
                    let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1)), subitem: trailingItem, count: 4)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(height)),
                                                                         subitems: [leadingGroup, middleGroup, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    section.orthogonalScrollingBehavior = .none
                    
                    return section
                    
                } else {
                    
                    let leadingItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                                           heightDimension: .fractionalHeight(1)))
                    leadingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    
                    let trailingItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .fractionalHeight(0.3)))
                    trailingItem.contentInsets = NSDirectionalEdgeInsets(top: contentInsets, leading: contentInsets, bottom: contentInsets, trailing: contentInsets)
                    let trailingGroup = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                                           heightDimension: .fractionalHeight(1)),
                        subitem: trailingItem, count: 2)
                    
                    let nestedGroup = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                           heightDimension: .fractionalHeight(0.75)),
                        subitems: [leadingItem, trailingGroup])
                    
                    section = NSCollectionLayoutSection(group: nestedGroup)
                    
                    section.orthogonalScrollingBehavior = .continuous
                }
                
            } else {
                fatalError("Wrong section")
            }
            
            return section
            
        }
        
        return layout
        
    }
    
    //MARK: - Data Source
    
    func makeDataSource() {
        
        self.dataSource = DataSource(collectionView: collectionView){ (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            var cell = UICollectionViewCell()
            
            guard let section = SectionLayoutKind(rawValue: indexPath.section) else {return cell}
            
            if section == .size {
                
                if indexPath.row == 0 {
                    
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textLabelCell", for: indexPath) as! TextLabelCollectionViewCell
                    
                    (cell as! TextLabelCollectionViewCell).label.text = item
                    
                    (cell as! TextLabelCollectionViewCell).label.font = UIFont.boldSystemFont(ofSize: 14)
                    
                }else{
                    
                    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! SizeCollectionViewCell
                    
                    (cell as! SizeCollectionViewCell).label.text = item
                    
                }
                
            }else if section == .option {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "optionCell", for: indexPath) as! OptionCollectionViewCell
                
                (cell as! OptionCollectionViewCell).label.text = item
                
                (cell as! OptionCollectionViewCell).button.tag = indexPath.row
                (cell as! OptionCollectionViewCell).button.addTarget(self, action: #selector(self.optionCellTapped(_:)), for: .touchUpInside)
                
            }else if section == .photo {
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
                
                cell.hero.id = item
                
                let originalUrlString = item
                
                let indexOfLastSlash = originalUrlString.lastIndex(of: "/")
                let indexOfDot = originalUrlString.lastIndex(of: ".")
                let firstPartOfURL = String(originalUrlString[originalUrlString.startIndex ..< indexOfLastSlash!])
                let secondPartOfURL = "/\(self.compression)\(String(originalUrlString[indexOfDot! ..< originalUrlString.endIndex]))"
                let fullURL = "\(firstPartOfURL)\(secondPartOfURL)"
                
                //                print("FULL URL: \(fullURL)")
                
                if let url = URL(string: fullURL){
                    
                    (cell as! PhotoCollectionViewCell).imageView.sd_setImage(with: url, placeholderImage:nil)
                    
                    (cell as! PhotoCollectionViewCell).button.tag = indexPath.row
                    (cell as! PhotoCollectionViewCell).button.addTarget(self, action: #selector(self.imageCellTapped(_:)), for: .touchUpInside)
                    
                }
                
            }
            
            return cell
        }
        
    }
    
    //MARK: - Snapshot Stuff
    
    func applySnapshot(animatingDifferences: Bool = false) {
        
        var snapshot = Snapshot()
        
        snapshot.appendSections(SectionLayoutKind.allCases)
        
        snapshot.appendItems(sizes, toSection: .size)
        snapshot.appendItems(options, toSection: .option)
        snapshot.appendItems(images,toSection: .photo)
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        
    }
    
    //MARK: - Actions
    
    @IBAction func vendorLabelTapped(_ sender: UIButton) {
        
        guard let vendorLabelButtonCallBack = vendorLabelButtonCallBack else {
            return
        }
        
        vendorLabelButtonCallBack()
        
    }
    
    @IBAction func byLabelTapped(_ sender: UIButton) {
        
        guard let byLabelButtonCallback = byLabelButtonCallback else {
            return
        }
        
        byLabelButtonCallback()
        
    }
    
    
    @IBAction func imageCellTapped (_ sender : UIButton){
        
        let index = sender.tag
        
        let imageURL = self.images[index]
        
        print("Selected Image Link : \(imageURL)")
        
        delegate?.didTapOnImageCell(index: index, images: images)
        
    }
    
    @IBAction func optionCellTapped(_ sender : UIButton){
        
        let index = sender.tag
        
        let selectedOption = options[index]
        
        print("Selected option : \(selectedOption) with index in the array : \(index)")
        
        delegate?.didTapOnOptionCell(option: selectedOption)
        
    }
    
    @IBAction func likeButtonPressed(_ sender : UIButton){
        
        guard let safeId = id, let safeKey = key else {return}
        
        let newStatus = like == "0" ? 1 : 0
        
        postLikeDataManager.getPostLikeData(key: safeKey, id: safeId, status: newStatus)
        
    }
    
    @IBAction func smotretVkPostPressed(_ sender : UIButton){
        
        guard let urlString = vkLinkUrlString ,let url = URL(string: urlString) else {return}
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func soobshitButtonPressed(_ sender : UIButton){
        
        guard let soobshitButtonCallback = soobshitButtonCallback else {return}
        
        soobshitButtonCallback()
    }
    
}

//MARK: - PostLikeDataManagerDelegate

extension PostTableViewCell : PostLikeDataManagerDelegate{
    
    func didGetPostLikeData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                like == "0" ? (likeButtonImageView.image = UIImage(systemName: "heart.fill")) : (likeButtonImageView.image = UIImage(systemName: "heart"))
                
                like = like == "0" ? "1" : "0"
                
            }
            
        }
        
    }
    
    func didFailGettingPostLikeDataWithError(error: String) {
        print("Error with PostLikeDataManager : \(error)")
    }
    
}

//MARK: - PhotoCollectionViewCellDelegate

protocol PostCellCollectionViewActionsDelegate {
    func didTapOnImageCell(index: Int, images : [String])
    func didTapOnOptionCell(option : String)
}
