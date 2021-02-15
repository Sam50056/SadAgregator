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
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Категория"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: ""), style: .plain, target: self, action: #selector(filterButtonTapped))
        
    }
    
    @objc func filterButtonTapped(){
        
        print("FILTER")
        
    }
    
}
