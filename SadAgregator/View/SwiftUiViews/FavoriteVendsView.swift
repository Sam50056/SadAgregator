//
//  FavoriteVendsView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 24.12.2020.
//

import SwiftUI
import UIKit

struct FavoriteVendsView : UIViewControllerRepresentable{
    
    func makeUIViewController(context: Context) -> FavoriteVendsViewController {
        
        return FavoriteVendsViewController()
        
    }
    
    func updateUIViewController(_ uiViewController: FavoriteVendsViewController, context: Context) {
        
    }
    
}

class FavoriteVendsViewController : UITableViewController {
    
    override func viewDidLoad() {
        
        tableView.register(UINib(nibName: "VendTableViewCell", bundle: nil), forCellReuseIdentifier: "vendCell")
        
        tableView.separatorStyle = .none
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "vendCell", for: indexPath) as! VendTableViewCell
        
        cell.rating = "5"
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
