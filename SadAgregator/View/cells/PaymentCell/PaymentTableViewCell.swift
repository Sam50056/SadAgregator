//
//  PaymentTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView : UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "PaymentTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        tableView.register(UINib(nibName: "PaymentTableViewCellEditTableViewCell", bundle: nil), forCellReuseIdentifier: "editCell")
        
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: - UITableView

extension PaymentTableViewCell : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        var cell = UITableViewCell()
        
        switch section {
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! PaymentTableViewCellTableViewCell
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.font = UIFont.systemFont(ofSize: 15)
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.textColor = .systemBlue
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.text = "7129"
            
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.font = UIFont.systemFont(ofSize: 15)
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.textColor = .systemGray
            
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.text = "01.09.2020"
            
        case 1:
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.textLabel?.text = "Самвел Ерзнкян"
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.text = "Сумма"
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.text = "-4380 руб."
            
        case 3:
            
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.text = "Снятие за костюм"
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath)
            
            (cell as! PaymentTableViewCellEditTableViewCell).textField.placeholder = "Редактировать"
            
            (cell as! PaymentTableViewCellEditTableViewCell).bgView.layer.cornerRadius = 6
            
            (cell as! PaymentTableViewCellEditTableViewCell).bgView.backgroundColor = UIColor(named: "gray")
            
        default:
            return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            return 20
        case 1:
            return 30
        case 2:
            return 20
        case 3:
            return 30
        case 4:
            return 50
        default:
            return 0
        }
        
    }
    
}
