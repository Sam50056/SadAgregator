//
//  RatingTableViewCellWithImages.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.08.2021.
//

import UIKit
import Cosmos
import SDWebImage

class RatingTableViewCellWithImages: UITableViewCell {

    @IBOutlet weak var authorLabel : UILabel!
    @IBOutlet weak var ratingView : CosmosView!
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var collectionView : UICollectionView!
    
    var images : [String]?{
        didSet{
            collectionView.reloadData()
        }
    }
    
    var imageSelected : ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "RatingTableViewCellWithImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        images = nil
        authorLabel.text?.removeAll()
        textView.text?.removeAll()
        dateLabel.text?.removeAll()
        ratingView.rating = 0
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
//RatingTableViewCellWithImagesCollectionViewCell
//MARK: - Collection View

extension RatingTableViewCellWithImages : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RatingTableViewCellWithImagesCollectionViewCell
        
        cell.imageView.sd_setImage(with: URL(string: images?[indexPath.row] ?? ""), completed: nil)
        
        cell.imageView.layer.cornerRadius = 8
        
        cell.imageView.contentMode = .scaleAspectFill
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageSelected?(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 80, height: 70)
        }

    
}
