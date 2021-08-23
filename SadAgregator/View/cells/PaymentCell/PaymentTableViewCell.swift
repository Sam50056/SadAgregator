//
//  PaymentTableViewCell.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import UIKit
import SwiftyJSON

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstLabel : UILabel!
    @IBOutlet weak var secondLabel : UILabel!
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var textFieldBgView : UIView!
    @IBOutlet weak var textField : UITextField!
    
    @IBOutlet weak var leftRoundView : UIView!
    @IBOutlet weak var rightRoundView : UIView!
    
    @IBOutlet weak var leftRoundImageView : UIImageView!
    @IBOutlet weak var rightRoundImageView : UIImageView!
    
    @IBOutlet weak var rightRoundViewButton: UIButton!
    
    var key : String?
    
    var summ : String? {
        didSet{
            
            if summ != nil , summ != "" {
                
                var newItemsArray = [TableViewItem]()
                
                newItemsArray.append(TableViewItem(firstText: "Сумма", secondText: summ! + " руб"))
                
                tableViewItems = newItemsArray
                
                tableView.reloadData()
                
            }
            
        }
    }
    
    var clientName : String? {
        didSet{
            tableView.reloadData()
        }
    }
    
    var clientId : String?
    
    var comment : String? {
        didSet{
            tableView.reloadData()
        }
    }
    
    var pid : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var dt : String?{
        didSet{
            tableView.reloadData()
        }
    }
    
    var clientSelected : ((String) -> ())?
    
    var rightViewButtonTapped : (() -> ())?
    var rightViewButtonLonlglyTapped : (() -> ())?
    
    var leftViewButtonTapped : (() -> ())?
    
    private var tableViewItems = [TableViewItem]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "PaymentTableViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "itemCell")
        
        tableView.register(UINib(nibName: "PaymentTableViewCellEditTableViewCell", bundle: nil), forCellReuseIdentifier: "editCell")
        
        //Edit textField
        textField.delegate = self
        textField.placeholder = "Редактировать"
        textFieldBgView.layer.cornerRadius = 6
        textFieldBgView.backgroundColor = UIColor(named: "gray")
        
        secondLabel.font = UIFont.systemFont(ofSize: 15)
        secondLabel.textColor = .systemGray
        
        firstLabel.font = UIFont.systemFont(ofSize: 15)
        firstLabel.textColor = .systemBlue
        
        leftRoundView.layer.cornerRadius = leftRoundView.frame.width / 2
        rightRoundView.layer.cornerRadius = rightRoundView.frame.width / 2
        leftRoundView.backgroundColor = UIColor(named: "gray")
        rightRoundView.backgroundColor = UIColor(named: "gray")
        
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = false
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(rightButtonLonglyTapped))
          
        rightRoundViewButton.addGestureRecognizer(longGesture)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: - Actions

extension PaymentTableViewCell{
    
    @objc func clientCellTapped(_ sender : UIButton){
        
        guard let clientId = clientId else {return}
        
        clientSelected?(clientId)
        
    }
    
    @IBAction func rightViewButtonTapped(_ sender : UIButton){
        rightViewButtonTapped?()
    }
    
    @IBAction func leftViewButtonTapped(_ sender : UIButton){
        leftViewButtonTapped?()
    }
    
    @objc func rightButtonLonglyTapped(){
        rightViewButtonLonlglyTapped?()
    }
    
}

//MARK: - UITextField

extension PaymentTableViewCell : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let com = textField.text , let pid = pid, let key = key else {return}
        
        ClientsUpdatePaymentComDataManager(delegate: nil).getClientsUpdatePaymentComData(key: key, paymentId: pid, com: com)
        
    }
    
}

//MARK: - UITableView

extension PaymentTableViewCell : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return clientName == "" ? 0 : 1
        case 1:
            return tableViewItems.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        var cell = UITableViewCell()
        
        switch section {
        case 0:
            
            guard let name = clientName else {return cell}
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.textLabel?.text = name
            
            let button = UIButton(frame: cell.contentView.frame)
            
            cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(button)
            
            NSLayoutConstraint.activate([button.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor), button.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),button.topAnchor.constraint(equalTo: cell.contentView.topAnchor),button.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)])
            
            button.addTarget(self, action: #selector(clientCellTapped(_:)), for: .touchUpInside)
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
            
            let item = tableViewItems[indexPath.row]
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.text = item.secondText
            (cell as! PaymentTableViewCellTableViewCell).secondLabel.text = ""
            
            (cell as! PaymentTableViewCellTableViewCell).firstLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            
            if item.firstText == "Сумма"{
                if item.secondText.first == "-"{
                    (cell as! PaymentTableViewCellTableViewCell).firstLabel.textColor = .systemRed
                }else{
                    (cell as! PaymentTableViewCellTableViewCell).firstLabel.textColor = .systemGreen
                }
            }
        default:
            return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            return 30
        case 1:
            return 20
        default:
            return 0
        }
        
    }
    
}

//MARK: - TableViewItem Struct

extension PaymentTableViewCell {
    
    private struct TableViewItem {
        
        var firstText : String
        var secondText : String
        
    }
    
}
