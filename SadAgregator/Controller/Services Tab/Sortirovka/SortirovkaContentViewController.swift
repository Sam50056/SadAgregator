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
    
    @IBOutlet weak var tableView : UITableView!
    
    var state = 1{
        didSet{
            UIView.animate(withDuration: 1) { [weak self] in
                self?.tableView.reloadData()
                self?.view.layoutIfNeeded()
            }
        }
    } // 1 is bottom , 2 is half , 3 is full
    
    var closeButtonPressed : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.roundCorners(.allCorners, radius: 20)
        dotsView.roundCorners(.allCorners, radius: 20)
        
        closeButtonViewButton.setTitle(nil, for: .normal)
        cameraViewButton.setTitle(nil, for: .normal)
        dotsViewButton.setTitle(nil, for: .normal)
        
        timeProgressView.transform = timeProgressView.transform.scaledBy(x: 1, y: 2)
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 1.5)
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if state == 1{
            return 3
        }else if state == 2{
            return 3
        }else if state == 3{
            return 3
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 0
        }else if section == 1{
            return 1
        }else if section == 2{
            return 1
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let section = indexPath.section
        
        var cell = UITableViewCell()
        
        if section == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "oneLabelCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Закупка №2131\nИванова Светлана"
            (cell.viewWithTag(1) as! UILabel).font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            (cell.viewWithTag(1) as! UILabel).numberOfLines = 0
            (cell.viewWithTag(1) as! UILabel).textAlignment = .center
            
        }else if section == 2{
            
            if state == 1{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "footerCell", for: indexPath)
                
                guard let dobavitPhotoButton = cell.viewWithTag(1) as? UIButton,
                      let podrobneeButton = cell.viewWithTag(2) as? UIButton else {
                          return cell
                      }
                
                dobavitPhotoButton.backgroundColor = UIColor(named: "gray")
                dobavitPhotoButton.layer.cornerRadius = 8
                
                dobavitPhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                podrobneeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                
            }
            
        }
        
        cell.backgroundColor = UIColor(named: "whiteblack")
        cell.contentView.backgroundColor = UIColor(named: "whiteblack")
        
        return cell
    }
    
}
