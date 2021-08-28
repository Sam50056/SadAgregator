//
//  SortirovkaContentViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 27.08.2021.
//

import UIKit

class SortirovkaContentViewController: UIViewController {
    
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var closeButtonImageView: UIImageView!
    @IBOutlet weak var closeButtonViewButton: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraViewButton: UIButton!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBOutlet weak var dotsView: UIView!
    @IBOutlet weak var dotsViewButton: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    //    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tableView : UITableView!
    
    var closeButtonPressed : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.roundCorners(.allCorners, radius: 20)
        dotsView.roundCorners(.allCorners, radius: 20)
        
        closeButtonViewButton.setTitle(nil, for: .normal)
        cameraViewButton.setTitle(nil, for: .normal)
        dotsViewButton.setTitle(nil, for: .normal)
        
//        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        timeProgressView.transform = timeProgressView.transform.scaledBy(x: 1, y: 2)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 1.5)
        
//        nameLabel.text = "Закупка №2131\nИванова Светлана"
        
        progressLabel.text = "18/26"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = UIColor(named: "whiteblack")
        
    }
 
    @IBAction func closeButtonPressed(_ sender : Any?){
        closeButtonPressed?()
    }
    
}

//MARK: - TableView

extension SortirovkaContentViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let _ = indexPath.section
        
        var cell = UITableViewCell()
        
        if index == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "oneLabelCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Закупка №2131\nИванова Светлана"
            (cell.viewWithTag(1) as! UILabel).font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            (cell.viewWithTag(1) as! UILabel).numberOfLines = 0
            (cell.viewWithTag(1) as! UILabel).textAlignment = .center
            
        }
        
        cell.backgroundColor = UIColor(named: "whiteblack")
        cell.contentView.backgroundColor = UIColor(named: "whiteblack")
        
        return cell
    }
    
}
