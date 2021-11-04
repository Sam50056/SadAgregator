//
//  SimpleDataTableTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.11.2021.
//

import UIKit

class SimpleDataTableViewController: UITableViewController {
    
    var array = [String]()
    
    var navBarTitle : String?
    
    var shouldShowNavBarButtons = false
    
    var tableViewItemSelected : ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = navBarTitle
        
        if shouldShowNavBarButtons{
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(otmenaTapped))
            
        }
        
    }
    
    //MARK: - Functions
    
    @objc func otmenaTapped(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        let cell = UITableViewCell()
        
        cell.textLabel?.text = array[index]
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableViewItemSelected?(indexPath.row)
        
    }
    
}
