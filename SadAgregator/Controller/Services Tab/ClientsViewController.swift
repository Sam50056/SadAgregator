//
//  ClientsViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.03.2021.
//

import UIKit

class ClientsViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Быстрый поиск по именам"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Set up table view
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Клиенты"
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: nil) , UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: nil)]
        
    }
    
}

//MARK: - SearchBar

extension ClientsViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
}

//MARK: - TableView

extension ClientsViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let section = indexPath.section
        
        switch section{
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalStatisticsCell", for: indexPath)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "statCell", for: indexPath)
            
            if let firstLabel = cell.viewWithTag(1) as? UILabel ,
               let secondLabel = cell.viewWithTag(2) as? UILabel{
                
                firstLabel.text = "Клиенты"
                
                secondLabel.text = "3"
            }
            
        default:
            return cell
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

