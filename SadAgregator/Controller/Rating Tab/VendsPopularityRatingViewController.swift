//
//  VendsPopularityRatingViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.01.2021.
//

import UIKit
import RealmSwift

class VendsPopularityRatingViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    var refreshControl = UIRefreshControl()
    
    let realm = try! Realm()
    
    var key : String?
    
    var isLogged : Bool = false
    
    var hintCellShouldBeShown = true
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        tableView.separatorStyle = .none
        
        searchView.layer.cornerRadius = 10
        
    }
    
    //MARK: - Refresh func
    
    @objc func refresh(_ sender: AnyObject) {
        
        
    }
    
}

//MARK: - TableView Stuff

extension VendsPopularityRatingViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return hintCellShouldBeShown ? 1 : 0
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
        
        setUpHintCell(cell: cell)
        
        return cell
        
    }
    
    @IBAction func removeHintCell(_ sender : Any) {
        
        hintCellShouldBeShown = false
        
        tableView.reloadSections([0], with: .automatic)
        
    }
    
    //MARK: - Cells SetUp
    
    func setUpHintCell(cell : UITableViewCell){
        
        if let closeButton = cell.viewWithTag(3) as? UIButton {
            closeButton.addTarget(self, action: #selector(removeHintCell(_: )), for: .touchUpInside)
        }
        
    }
    
}

