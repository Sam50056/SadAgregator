//
//  GalleryViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.12.2020.
//

import UIKit
import Hero
import SDWebImage

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var imageIndexLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    var images : [String]  = []
    
    var selectedImageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.scrollToItem(at: IndexPath(row: selectedImageIndex, section: 0), at: .centeredHorizontally, animated: false)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(pan)
        
        collectionView.heroID = images[selectedImageIndex]
        
        collectionView.isPagingEnabled = true
        
        imageIndexLabel.text = "Фото \(currentIndexPathOf(collectionView).row + 1) из \(images.count)"
        
        buttonView.layer.cornerRadius = 8
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableHero()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableHero()
        
    }
    
    //MARK: - Actions
    
    @objc func handleTap(_ sender: UIPanGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        
        let currentImageLink = images[(currentIndexPathOf(collectionView).row)]
        
        guard let imageData = try? Data(contentsOf: URL(string: currentImageLink)!) else {return}
        
        // image to share
        let image = UIImage(data: imageData)
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.saveToCameraRoll, UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToTwitter]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
}

//MARK: - UICollectionView stuff

extension GalleryViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath)
        
        if let scrollView = cell.viewWithTag(1) as? UIScrollView ,
           let imageView = cell.viewWithTag(2) as? UIImageView{
            
            imageView.image = nil
            
            scrollView.maximumZoomScale = 4
            scrollView.minimumZoomScale = 1
            
            scrollView.delegate = self
            scrollView.zoomScale = 1
            
            imageView.contentMode = .scaleAspectFit
            
            imageView.clipsToBounds = true
            
            let originalUrlString = images[indexPath.row]
            
            //            let indexOfLastSlash = originalUrlString.lastIndex(of: "/")
            //            let indexOfDot = originalUrlString.lastIndex(of: ".")
            //            let firstPartOfURL = String(originalUrlString[originalUrlString.startIndex ..< indexOfLastSlash!])
            //            let secondPartOfURL = "/550\(String(originalUrlString[indexOfDot! ..< originalUrlString.endIndex]))"
            //            let fullURL = "\(firstPartOfURL)\(secondPartOfURL)"
            
            imageView.load(url: URL(string: originalUrlString)!)
            
        }
        
        return cell
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func currentIndexPathOf(_ collectionVeiw : UICollectionView) -> IndexPath{
        
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        let indexPath = collectionView.indexPathForItem(at: visiblePoint)!
        
        return indexPath
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        imageIndexLabel.text = "Фото \(currentIndexPathOf(collectionView).row + 1) из \(images.count)"
        
    }
    
    
}
