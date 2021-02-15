//
//  CategoryViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.02.2021.
//

import UIKit

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "HELLO"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: ""), style: .plain, target: self, action: #selector(filterButtonTapped))
        
    }
    
    @objc func filterButtonTapped(){
        
        print("FILTER")
        
    }
    
}
