//
//  FilterViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.02.2021.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterItemCell", for: indexPath)
        
        if let bgView = cell.viewWithTag(1),
           let label = cell.viewWithTag(2) as? UILabel{
            
            label.text = "SAM"
            
        }
        
        return cell
        
    }
    
}
