//
//  BalanceRequestTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.09.2021.
//

import UIKit

class BalanceRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var firstLabel : UILabel!
    
    @IBOutlet weak var rightView : UIView!
    @IBOutlet weak var rightViewImageView : UIImageView!
    
    @IBOutlet weak var leftButtonView : UIView!
    @IBOutlet weak var rightButtonView : UIView!
    
    @IBOutlet weak var leftButtonViewLabel : UILabel!
    @IBOutlet weak var rightButtonViewLabel : UILabel!
    
    var clientName : String? {
        didSet{
            tableView.reloadData()
        }
    }
    
    var summ : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var clientId : String?
    
    var dt : String?
    
    var leftButtonCallbak : (() -> Void)?
    var rightButtonCallback : (() -> Void)?
    var rightViewButtonCallback : (() -> Void)?
    var clientNameTapped : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.register(UINib(nibName: "BalanceRequestTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        leftButtonViewLabel.text = "Принять"
        rightButtonViewLabel.text = "Отклонить"
        
        leftButtonViewLabel.textColor = #colorLiteral(red: 0.2044417262, green: 0.7789897323, blue: 0.3482289314, alpha: 1)
        rightButtonViewLabel.textColor = #colorLiteral(red: 0.9992364049, green: 0.1742664576, blue: 0.3322370052, alpha: 1)
        
        leftButtonView.backgroundColor = #colorLiteral(red: 0.8614494205, green: 0.9998171926, blue: 0.8933524489, alpha: 1)
        rightButtonView.backgroundColor = #colorLiteral(red: 1, green: 0.8143821359, blue: 0.8493263125, alpha: 1)
        
        rightButtonView.layer.cornerRadius = 8
        leftButtonView.layer.cornerRadius = 8

        rightView.layer.cornerRadius = rightView.frame.width / 2
        rightViewImageView.tintColor = UIColor(named: "blackwhite")
        rightView.backgroundColor = #colorLiteral(red: 0.9529423118, green: 0.9491030574, blue: 0.9701582789, alpha: 1)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Actions
    
    @IBAction func leftButtonPressed(_ sender : Any?){
        leftButtonCallbak?()
    }
    
    @IBAction func rightButtonPressed(_ sender : Any?){
        rightButtonCallback?()
    }
    
    @IBAction func rightViewPressed(_ sender : Any?){
        rightViewButtonCallback?()
    }
    
    @IBAction func clientCellTapped(_ sender : Any?){
        clientNameTapped?()
    }
    
}

//MARK: - Table View

extension BalanceRequestTableViewCell : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        switch index{
        case 0:
            guard let name = clientName else {return UITableViewCell()}
            
            let cell = UITableViewCell()
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.textLabel?.text = name
            
            cell.textLabel?.textColor = .systemBlue
            
            let button = UIButton(frame: cell.contentView.frame)
            
            cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(button)
            
            NSLayoutConstraint.activate([button.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor), button.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),button.topAnchor.constraint(equalTo: cell.contentView.topAnchor),button.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)])
            
            button.addTarget(self, action: #selector(clientCellTapped(_:)), for: .touchUpInside)
            
            return cell
            
        case 1:
            
            guard let summ = summ else {return UITableViewCell()}
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
            
            (cell as! BalanceRequestTableViewCellTableViewCell).firstLabel.text = "Сумма: \(summ)"
            (cell as! BalanceRequestTableViewCellTableViewCell).secondLabel.text = ""
            
            (cell as! BalanceRequestTableViewCellTableViewCell).firstLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            
            if summ.first == "-"{
                (cell as! BalanceRequestTableViewCellTableViewCell).firstLabel.textColor = .systemRed
            }else{
                (cell as! BalanceRequestTableViewCellTableViewCell).firstLabel.textColor = .systemGreen
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1{
            return 30
        }else {
            return 20
        }
        
    }
    
}
