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
    
    var images : [String]  = []
    
    var selectedImageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.scrollToItem(at: IndexPath(row: selectedImageIndex, section: 0), at: .centeredHorizontally, animated: false)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(pan)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        enableHero()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableHero()
        
    }
    
    @objc func handleTap(_ sender: UIPanGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
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
    
    
}
