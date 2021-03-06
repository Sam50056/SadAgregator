//
//  ClientTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.03.2021.
//

import UIKit

class ClientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "ClientTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: - TableView

extension ClientTableViewCell : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.row == 0{
            
            cell.textLabel?.text = "Samvel Erznkyan"
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ClientTableViewCellTableViewCell
            
            (cell as! ClientTableViewCellTableViewCell).firstLabel.text = "Баланс"
            (cell as! ClientTableViewCellTableViewCell).secondLabel.text = "-400 руб."
            (cell as! ClientTableViewCellTableViewCell).secondLabel.textColor = .red
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 30
        }else{
            return 20
        }
    }
    
}
