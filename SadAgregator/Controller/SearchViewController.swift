//
//  SearchViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.11.2020.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView.layer.cornerRadius = 10
        
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.text = searchText
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
}

//MARK: - UITableView Stuff

extension SearchViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}
