//
//  ClientViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.03.2021.
//

import UIKit
import SwiftyJSON

class ClientViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var hideLabel :  UILabel?
    private var hideLabelImageView : UIImageView?
    
    var key = ""
    
    private var isInfoShown = true
    
    var thisClientId : String?
    
    private var clientDataManager = ClientDataManager()
    
    private var updateClientInfoDataManager = UpdateClientInfoDataManager()
    
    private var clientData : JSON?
    
    private var infoItems = [InfoItem]()
    
    private var balance : Int?
    private var balanceLabel : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key = "part_2_test"
        
        clientDataManager.delegate = self
        updateClientInfoDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "PurchaseTableViewCell", bundle: nil), forCellReuseIdentifier: "purchaseCell")
        
        if let thisClientId = thisClientId{
            clientDataManager.getClientData(key: key, clientId: thisClientId)
        }
        
    }
    
}

//MARK: - Funtions

extension ClientViewController{
    
    func makeInfoItemsFrom(_ clientHeaderData : JSON){
        
        if let balance = clientHeaderData["balance"].string , balance != "" {
            infoItems.append(InfoItem(firstText: "Баланс", secondText: balance, isBalance: true))
            self.balance = Int(balance)!
        }
        
        if let phone = clientHeaderData["phone"].string , phone != "" {
            infoItems.append(InfoItem(firstText: "Телефон", secondText: phone))
        }
        
        if let vk = clientHeaderData["vk"].string , vk != "" {
            infoItems.append(InfoItem(firstText: "ВКонтакте", secondText: vk))
        }
        
        if let ok = clientHeaderData["ok"].string , ok != "" {
            infoItems.append(InfoItem(firstText: "Одноклассники", secondText: ok))
        }
        
    }
    
}

//MARK: - TableView Stuff

extension ClientViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return isInfoShown ? infoItems.count : 0
        case 2:
            return clientData == nil ? 0 : 1
        case 3:
            return 0
        case 4:
            return 0
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let section = indexPath.section
        
        switch section{
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
            
            if let hideLabel = cell.viewWithTag(1) as? UILabel,
               let hideLabelImageView = cell.viewWithTag(2) as? UIImageView{
                
                hideLabel.text = isInfoShown ? "Скрыть" : "Показать"
                
                hideLabelImageView.image = isInfoShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
                
                self.hideLabel = hideLabel
                
                self.hideLabelImageView = hideLabelImageView
                
            }
            
        case 1:
            
            let item = infoItems[indexPath.row]
            
            //Balance cell is different from other info cells
            if item.isBalance{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "infoCellBalance", for: indexPath)
                
                if let firstLabel = cell.viewWithTag(1) as? UILabel ,
                   let secondLabel = cell.viewWithTag(2) as? UILabel,
                   let stepper = cell.viewWithTag(3) as? UIStepper{
                    
                    firstLabel.text = item.firstText
                    
                    secondLabel.text = item.secondText
                    
                    balanceLabel = secondLabel
                    
                    stepper.maximumValue = Double.infinity
                    stepper.minimumValue = -Double.infinity
                    
                    stepper.stepValue = 1
                    
                    stepper.value = 0
                    
                    stepper.addTarget(self, action: #selector(stepperPressed(_:)), for: .valueChanged)
                    
                }
                
                return cell
                
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            if let firstLabel = cell.viewWithTag(1) as? UILabel ,
               let secondLabel = cell.viewWithTag(2) as? UILabel{
                
                firstLabel.text = item.firstText
                
                secondLabel.text = item.secondText
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
            
            if let commentTextField = cell.viewWithTag(1) as? UITextField{
                
                commentTextField.delegate = self
                
            }
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
        case 4:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! PurchaseTableViewCell
            
        //            (cell  as! PurchaseTableViewCell).client = clients[indexPath.row]
        
        default:
            return cell
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 0{
            
            isInfoShown.toggle()
            
            tableView.reloadSections([1], with: .top)
            
            hideLabel?.text = isInfoShown ? "Скрыть" : "Показать"
            hideLabelImageView?.image = isInfoShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            
            UIView.animate(withDuration: 0.3){ [self] in
                view.layoutIfNeeded()
            }
            
        }else if section == 1{
            
            if infoItems[indexPath.row].isBalance{
                
                let paymentsHistoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentHistoryVC") as! PaymentHistoryViewController
                
                paymentsHistoryVC.thisClientId = thisClientId
                
                navigationController?.pushViewController(paymentsHistoryVC, animated: true)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4{
            return 85 - 20
        }
        return K.simpleHeaderCellHeight
    }
    
    //MARK: - Stepper
    
    @IBAction func stepperPressed(_ sender : UIStepper){
        
        if sender.value > 0 {
            
            showBalanceChangingAlert(isPlus: true)
            
        }else{
            
            showBalanceChangingAlert(isPlus: false)
            
        }
        
        balanceLabel?.text = "\(balance!)"
        
        sender.value = 0
        
    }
    
}

//MARK: - Alerts

extension ClientViewController{
    
    func showBalanceChangingAlert(isPlus : Bool){
        
        let alertController = UIAlertController(title: (isPlus ? "Начисление" : "Списание"), message: "Введите сумму \(isPlus ? "начисления" : "списания")", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            
            textField.placeholder = "Сумма (руб)"
            textField.keyboardType = .numberPad
            
        }
        
        alertController.addTextField { (textField) in
            
            textField.placeholder = "Комментарий"
            
        }
        
        let action = UIAlertAction(title: "Ок", style: .default) { [self] (_) in
            
            if let summ = alertController.textFields?.first?.text ,
               let intSumm = Int(summ){
                
                let secondAlertController = UIAlertController(title: isPlus ? "Начисление" : "Списание", message: "\(isPlus ? "Начислить" : "Списать") \(intSumm) руб?", preferredStyle: .alert)
                
                let secondAlertAction = UIAlertAction(title: "Да", style: .default) { (_) in
                    
                    
                    
                }
                
                let secondAlertCancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
                    secondAlertController.dismiss(animated: true, completion: nil)
                }
                
                secondAlertController.addAction(secondAlertAction)
                secondAlertController.addAction(secondAlertCancelAction)
                
                present(secondAlertController, animated: true, completion: nil)
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(action)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}

//MARK: - TextField

extension ClientViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard textField.text != nil , textField.text?.replacingOccurrences(of: " ", with: "") != "" else {return}
        
        updateClientInfoDataManager.getUpdateClientInfoData(key: key, clientId: thisClientId!, fieldId: "5", value: textField.text!.replacingOccurrences(of: "'", with: ""))
        
    }
    
}

//MARK: - ClientDataManagerDelegate

extension ClientViewController : ClientDataManagerDelegate{
    
    func didGetClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                clientData = data
                
                let clientHeaderData = data["client_header"]
                
                if let name = clientHeaderData["name"].string , name != ""{
                    navigationItem.title = name
                }
                
                makeInfoItemsFrom(clientHeaderData)
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientDataWithError(error: String) {
        print("Error with ClientDataManager : \(error)")
    }
    
}

//MARK: - UpdateClientInfoDataManagerDelegate

extension ClientViewController : UpdateClientInfoDataManagerDelegate{
    
    func didGetUpdateClientInfoData(data: JSON) {
        
        DispatchQueue.main.async {
            
            print("Successfully sent : UpdateClientInfoDataManager request")
            
        }
        
    }
    
    func didFailGettingUpdateClientInfoDataWithError(error: String) {
        print("Error with UpdateClientInfoDataManager : \(error)")
    }
    
}

//MARK: - Statistics Item struct

extension ClientViewController{
    
    private struct InfoItem {
        
        let firstText : String
        let secondText : String
        var isBalance : Bool = false
        
    }
    
}
