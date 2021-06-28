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
    private var clientsChangeBalanceDataManager = ClientsChangeBalanceDataManager()
    
    private var clientData : JSON?
    
    private var infoItems = [InfoItem]()
    
    private var balance : Int?
    private var balanceLabel : UILabel?
    
    private var purs = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key = "part_2_test"
        
        clientDataManager.delegate = self
        updateClientInfoDataManager.delegate = self
        clientsChangeBalanceDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "PurchaseTableViewCell", bundle: nil), forCellReuseIdentifier: "purchaseCell")
        
        if let thisClientId = thisClientId{
            clientDataManager.getClientData(key: key, clientId: thisClientId)
        }
        
    }
    
}

//MARK: - Refresh

extension ClientViewController{
    
    func refreshClientData() {
        infoItems.removeAll()
        clientDataManager.getClientData(key: key, clientId: thisClientId!)
    }
    
}

//MARK: - Funtions

extension ClientViewController{
    
    func makeInfoItemsFrom(_ clientHeaderData : JSON){
        
        if let balance = clientHeaderData["balance"].string , balance != "" {
            infoItems.append(InfoItem(firstText: "Баланс", secondText: balance + " руб", isBalance: true))
            self.balance = Int(balance)!
        }
        
        if let phone = clientHeaderData["phone"].string {
            infoItems.append(InfoItem(firstText: "Телефон", secondText: phone))
        }
        
        if let vk = clientHeaderData["vk"].string {
            infoItems.append(InfoItem(firstText: "ВКонтакте", secondText: vk))
        }
        
        if let ok = clientHeaderData["ok"].string {
            infoItems.append(InfoItem(firstText: "Одноклассники", secondText: ok))
        }
        
        if let pochtaIndex = clientHeaderData["pochta_index"].string{
            infoItems.append(InfoItem(firstText: "Почтовый индекс", secondText: pochtaIndex))
        }
        
        if let fio = clientHeaderData["pochta_fio"].string{
            infoItems.append(InfoItem(firstText: "ФИО", secondText: fio))
        }
        
    }
    
    //MARK: - Actions
    
    @IBAction func editButtonTappedForPhone(_ sender : Any){
        
        let alertController = UIAlertController(title: "Введите номер телефона", message: nil, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ок", style: .default) { [self] (_) in
            
            guard let value = alertController.textFields?[0].text else {return}
            
            updateClientInfoDataManager.getUpdateClientInfoData(key: key, clientId: thisClientId!, fieldId: "2", value: value)
            
        }
        
        alertController.addTextField { (textField) in
            
            textField.placeholder = "Номер телефона"
            textField.keyboardType = .phonePad
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func editButtonTappedForVK(_ sender : Any){
        
        let alertController = UIAlertController(title: "Введите ссылку на аккаунт ВК", message: nil, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ок", style: .default) { [self] (_) in
            
            guard let value = alertController.textFields?[0].text else {return}
            
            if let _ = URL(string: value) , value.contains("vk.com"){
                updateClientInfoDataManager.getUpdateClientInfoData(key: key, clientId: thisClientId!, fieldId: "3", value: value)
            }else{
                showSimpleAlertWithOkButton(title: "Некорректная ссылка", message: "Повторите попытку")
            }
            
        }
        
        alertController.addTextField { (textField) in
            
            textField.placeholder = "Ссылка"
            textField.keyboardType = .URL
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func editButtonTappedForOK(_ sender : Any){
        
        let alertController = UIAlertController(title: "Введите ссылку на аккаунт ОК", message: nil, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ок", style: .default) { [self] (_) in
            
            guard let value = alertController.textFields?[0].text else {return}
            
            if let _ = URL(string: value) , value.contains("ok.ru"){
                updateClientInfoDataManager.getUpdateClientInfoData(key: key, clientId: thisClientId!, fieldId: "4", value: value)
            }else{
                showSimpleAlertWithOkButton(title: "Некорректная ссылка", message: "Повторите попытку")
            }
            
        }
        
        alertController.addTextField { (textField) in
            
            textField.placeholder = "Ссылка"
            textField.keyboardType = .URL
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func editButtonTappedPochtaIndex(_ sender : Any){
        
        let alertController = UIAlertController(title: "Введите почтовый индекс", message: nil, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ок", style: .default) { [self] (_) in
            
            guard let value = alertController.textFields?[0].text else {return}
            
            updateClientInfoDataManager.getUpdateClientInfoData(key: key, clientId: thisClientId!, fieldId: "6", value: value)
            
        }
        
        alertController.addTextField { (textField) in
            
            textField.placeholder = ""
            textField.keyboardType = .numberPad
            textField.restorationIdentifier = "pochtaIndex"
            textField.delegate = self
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func editButtonTappedFIO(_ sender : Any){
        
        let alertController = UIAlertController(title: "Введите ФИО", message: nil, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ок", style: .default) { [self] (_) in
            
            guard let value = alertController.textFields?[0].text else {return}
            
            updateClientInfoDataManager.getUpdateClientInfoData(key: key, clientId: thisClientId!, fieldId: "7", value: value)
            
        }
        
        alertController.addTextField { (textField) in
            
            textField.placeholder = ""
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
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
            return 1
        case 4:
            return purs.isEmpty ? 1 : purs.count
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
               let secondLabel = cell.viewWithTag(2) as? UILabel,
               let editButton = cell.viewWithTag(3) as? UIButton{
                
                firstLabel.text = item.firstText
                
                secondLabel.text = item.secondText
                
                if item.firstText == "Телефон"{
                    editButton.addTarget(self, action: #selector(editButtonTappedForPhone(_:)), for: .touchUpInside)
                }else if item.firstText == "ВКонтакте"{
                    editButton.addTarget(self, action: #selector(editButtonTappedForVK(_:)), for: .touchUpInside)
                }else if item.firstText == "Одноклассники"{
                    editButton.addTarget(self, action: #selector(editButtonTappedForOK(_:)), for: .touchUpInside)
                }
                
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
            
            if let commentTextField = cell.viewWithTag(1) as? UITextField{
                
                commentTextField.delegate = self
                
                commentTextField.text = clientData?["client_header"]["comment"].string?.replacingOccurrences(of: "<br>", with: "\n") ?? ""
                
            }
            
        case 3:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
        case 4:
            
            if purs.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
                
                (cell.viewWithTag(1) as! UILabel).text = "Клиент не участвовал в закупках"
                
                return cell
                
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as! PurchaseTableViewCell
            
            let jsonPur = purs[indexPath.row]
            
            let id = jsonPur["id"].stringValue
            let capt = jsonPur["capt"].stringValue
            let date = jsonPur["dt"].stringValue
            let status = jsonPur["status"].stringValue
            
            var moneyArray = [PurchaseTableViewCell.TableViewItem]()
            
            if let moneyJsonArray = jsonPur["money"].array , !moneyJsonArray.isEmpty{
                moneyArray = moneyJsonArray.map({ jsonMoneyItem in
                    PurchaseTableViewCell.TableViewItem(firstText: jsonMoneyItem["capt"].stringValue, secondText: "\(jsonMoneyItem["value"].stringValue) \(jsonMoneyItem["dop"].stringValue)")
                })
            }
            
            let purItem = PurchaseTableViewCellItem(id: id, capt: capt, date: date, status: status , money: moneyArray)
            
            (cell  as! PurchaseTableViewCell).thisItem = purItem
        
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
            
            let item = infoItems[indexPath.row]
            
            if item.isBalance{
                
                let paymentsHistoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentHistoryVC") as! PaymentHistoryViewController
                
                paymentsHistoryVC.thisClientId = thisClientId
                
                navigationController?.pushViewController(paymentsHistoryVC, animated: true)
                
            }else if item.firstText == "Телефон"{
                
                if item.secondText.replacingOccurrences(of: " ", with: "") == "" {
                    
                    editButtonTappedForPhone(self)
                    
                }else{
                    
                    if let url = URL(string: "tel://\(item.secondText)") {
                        
                        UIApplication.shared.open(url ,  options: [:], completionHandler: nil)
                        
                    }
                    
                }
                
            }else if item.firstText == "ВКонтакте" {
                
                if item.secondText == "" {
                    
                    editButtonTappedForVK(self)
                    
                }else{
                    
                    let urlString = item.secondText
                    
                    if let url = URL(string: urlString){
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    }
                    
                }
                
            }else if item.firstText == "Одноклассники"{
                
                if item.secondText == "" {
                    
                    editButtonTappedForOK(self)
                    
                }else{
                    
                    let urlString = item.secondText
                    
                    if let url = URL(string: urlString){
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                    }
                    
                }
                
            }else if item.firstText == "Почтовый индекс"{
                
                editButtonTappedPochtaIndex(self)
                
            }else if item.firstText == "ФИО"{
                
                editButtonTappedFIO(self)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 , !purs.isEmpty{
            
            let pur = purs[indexPath.row]
            
            let moneyArray = pur["money"].arrayValue
            
            return CGFloat(66 + (moneyArray.count * 23)) //130//88 //- 20
        }
        return K.simpleHeaderCellHeight
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard !purs.isEmpty , indexPath.section == 4 else {return nil}
        
        let pur = purs[indexPath.row]
        
        guard pur["can_del"].intValue != 0 else {return nil}
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] action, view, completion in
            
            let alertController = UIAlertController(title: "Удалить клиента из закупки?", message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                
                ClientsDelClientFromPurDataManager().getClientsDelClientFromPurData(key: key, clientId: thisClientId!, purId: pur["id"].stringValue) { data, error in
                    
                    if let error = error , data == nil {
                        print("Error with purchasesDelZonePriceDataManager : \(error)")
                        return
                    }
                    
                    guard let data = data else {return}
                    
                    if data["result"].intValue == 1{
                        
                        DispatchQueue.main.async { [self] in
                            
                            purs.remove(at: indexPath.row)
                            
                            completion(true)
                            
                            tableView.reloadSections([4], with: .automatic)
                            
                        }
                        
                    }
                    
                }
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
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
            
            textField.placeholder = "Комментарий (необязат. поле)"
            
        }
        
        let action = UIAlertAction(title: "Ок", style: .default) { [self] (_) in
            
            if let summ = alertController.textFields?.first?.text ,
               var intSumm = Int(summ){
                
                let secondAlertController = UIAlertController(title: isPlus ? "Начисление" : "Списание", message: "\(isPlus ? "Начислить" : "Списать") \(intSumm) руб?", preferredStyle: .alert)
                
                let secondAlertAction = UIAlertAction(title: "Да", style: .default) { (_) in
                    
                    //If "-" was selected , it's not plus , so we make the value negative
                    if !isPlus{
                        intSumm = -intSumm
                    }
                    
                    var comment = alertController.textFields![1].text ?? ""
                    
                    //Taking only first 200 characters from comment if it has more than 200 symbols
                    if comment.count > 200 {
                        comment = String(comment.prefix(200))
                    }
                    
                    clientsChangeBalanceDataManager.getClientsChangeBalanceData(key: key, clientId: thisClientId!, summ: intSumm, comment: comment)
                    
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
        
        guard textField.restorationIdentifier != "pochtaIndex" , textField.text != nil , textField.text?.replacingOccurrences(of: " ", with: "") != "" else {return}
        
        updateClientInfoDataManager.getUpdateClientInfoData(key: key, clientId: thisClientId!, fieldId: "5", value: textField.text!.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "\n", with: "<br>"))
        
    }
    
    //This is for pochta index field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.restorationIdentifier == "pochtaIndex" ,
              let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return true
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 6
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
                
                purs = data["purs"].arrayValue
                
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
        
        DispatchQueue.main.async {[self] in
            
            
            if data["result"].intValue == 1{
                
                refreshClientData()
                
                print("Successfully sent : UpdateClientInfoDataManager request")
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingUpdateClientInfoDataWithError(error: String) {
        print("Error with UpdateClientInfoDataManager : \(error)")
    }
    
}

//MARK: - ClientsChangeBalanceDataManagerDelegate

extension ClientViewController : ClientsChangeBalanceDataManagerDelegate{
    
    func didGetClientsChangeBalanceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                print("ChangeBalanceData request sent")
                
                refreshClientData()
                
            }else{
                print("ChangeBalanceData NOT request sent")
            }
            
        }
        
    }
    
    func didFailGettingClientsChangeBalanceDataWithError(error: String) {
        print("Error with ClientsChangeBalanceDataManager : \(error)")
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
