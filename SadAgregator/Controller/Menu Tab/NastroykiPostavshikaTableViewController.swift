//
//  NastroykiPostavshikaTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.06.2021.
//

import UIKit
import SwiftUI
import SwiftyJSON

//MARK: - ViewController Representable

struct NastroykiPostavshikaView : UIViewControllerRepresentable{
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    func makeUIViewController(context: Context) -> NastroykiPostavshikaTableViewController {
        
        let nastroykiPosrednikaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NastroykiPostavshikaVC") as! NastroykiPostavshikaTableViewController
        
        nastroykiPosrednikaVC.key = menuViewModel.getUserDataObject()?.key
        
        return nastroykiPosrednikaVC
        
    }
    
    func updateUIViewController(_ uiViewController: NastroykiPostavshikaTableViewController, context: Context) {
        
    }
    
}

//MARK: - ViewController

class NastroykiPostavshikaTableViewController: UITableViewController {
    
    var key : String?
    
    private var capt : String?
    
    private var firstSectionItems = [FirstSectionItem]()
    
    private var sposobOtpravkiSectionItems = [SposobiOtpravkiSectionForPosrednikItem]()
    
    private var lastSectionItems = [FirstSectionItem]()
    
    private var vendStatus : String?
    private var agrMembLevel : String?
    
    private var vendFormDataManager = VendFormDataManager()
    private lazy var vendUpdateInfoDataManager = VendUpdateInfoDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vendFormDataManager.delegate = self
        
        tableView.separatorStyle = .none
        
        update()
        
    }
    
    //MARK: - Actions
    
    @IBAction func dobavitSposobOtpravkiPressedInPosrednik(_ sener : Any){
        
        VendGetDeliveryTypeDataManager().getVendGetDeliveryTypeData(key: key!) { data, error in
            
            DispatchQueue.main.async { [self] in
                
                if error != nil , data == nil {
                    print("Erorr with VendGetDeliveryTypeDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    guard let deliveryList = data!["delivery_list"].array else {return}
                    
                    let sheetAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    for deliveryItem in deliveryList{
                        
                        let deliveryName = deliveryItem["name"].stringValue
                        let deliveryId = deliveryItem["id"].stringValue
                        
                        sheetAlertController.addAction(UIAlertAction(title: deliveryName, style: .default, handler: { _ in
                            
                            let priceAlertController = UIAlertController(title: "Цена доставки для \"\(deliveryName)\"", message: nil, preferredStyle: .alert)
                            
                            priceAlertController.addTextField { priceTextField in
                                priceTextField.keyboardType = .numberPad
                            }
                            
                            priceAlertController.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { _ in
                                
                                guard let price = priceAlertController.textFields?[0].text else {return}
                                
                                VendAddSendRuleDataManager().getVendAddSendRuleData(key: key!, sendType: deliveryId, price: price) { data, error in
                                    
                                    if error != nil , data == nil {
                                        print("Erorr with VendAddSendRuleDataManager : \(error!)")
                                        return
                                    }
                                    
                                    if data!["result"].intValue == 1{
                                        
                                        let ruleId = data!["rule_id"].stringValue
                                        
                                        DispatchQueue.main.async {
                                            
                                            sposobOtpravkiSectionItems.append(SposobiOtpravkiSectionForPosrednikItem(ruleId: ruleId, name: deliveryName, typeId: deliveryId, price: price))
                                            
                                            self.tableView.reloadData()
                                            
                                        }
                                        
                                    } else {
                                        
                                        if let message = data!["msg"].string{
                                            
                                            DispatchQueue.main.async {
                                                self.showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }))
                            
                            priceAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                            
                            DispatchQueue.main.async {
                                self.present(priceAlertController, animated: true, completion: nil)
                            }
                            
                        }))
                        
                    }
                    
                    sheetAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    DispatchQueue.main.async {
                        self.present(sheetAlertController, animated: true, completion: nil)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func removeSposobOtpravkiPressed(_ sender : UIButtonWithInfo){
        
        guard let index = Int(sender.info) else {return}
        
        let sposob = sposobOtpravkiSectionItems[index]
        
        VendDelSendRuleDataManager().getVendDelSendRuleData(key: key!, ruleId: sposob.ruleId) { data, error in
            
            if error != nil , data == nil {
                print("Erorr with VendDelSendRuleDataManager : \(error!)")
                return
            }
            
            if data!["result"].intValue == 1{
                
                DispatchQueue.main.async {
                    
                    self.sposobOtpravkiSectionItems.remove(at: index)
                    
                    self.tableView.reloadSections([3], with: .automatic)
                    
                }
                
            } else {
                
                if let message = data!["msg"].string{
                    
                    DispatchQueue.main.async {
                        self.showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func ratingCellButtonTapped(_ sender : Any){
        
        guard let agrMembLevel = agrMembLevel , !agrMembLevel.isEmpty else {
            return
        }
        
        var alertTitle = ""
        
        let field = "6"
        var val = ""
        
        if agrMembLevel == "0"{
            alertTitle = "Отправить заявку на участие в прямом выкупе?"
        }else if agrMembLevel == "1"{
            alertTitle = "Отозвать заявку с модерации?"
        }else if agrMembLevel == "2"{
            alertTitle = "Отменить участие в системе быстрого выкупа?"
        }
        
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { [self] _ in
            
            if agrMembLevel == "0"{
                val = "1"
            }else if agrMembLevel == "1"{
                val = "0"
            }else if agrMembLevel == "2"{
                val = "0"
            }
            
            BrokersUpdateInfoDataManager().getBrokersUpdateInfoData(key: key!, type: field, value: val) { data, error in
                
                DispatchQueue.main.async {
                    
                    if error != nil , data == nil {
                        print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                        return
                    }
                    
                    if data!["result"].intValue == 1{
                        
                        update()
                        
                    }
                    
                }
                
            }
            
        }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func zeroSectionCellButtonTapped(_ sender : Any){
        
        guard let key = key , let vendStatus = vendStatus , vendStatus == "0" else {return}
        
        let alertController = UIAlertController(title: "Отправить запрос на проверку номера точки?", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
            
            BrokersUpdateInfoDataManager().getBrokersUpdateInfoData(key: key, type: "1", value: "1") { data, error in
                
                if error != nil , data == nil {
                    print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    DispatchQueue.main.async {
                        self.update()
                    }
                    
                }
                
            }
            
        }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - Update
    
    func update(){
        
        if let key = key{
            vendFormDataManager.getVendFormData(key: key)
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard !firstSectionItems.isEmpty else {return 0}
        
        switch section {
        case 0:
            return capt == nil ? 0 : 1
        case 1:
            return firstSectionItems.count
        case 2:
            return 1
        case 3:
            return sposobOtpravkiSectionItems.isEmpty ? 1 : sposobOtpravkiSectionItems.count
        case 4:
            return 1
        case 5:
            return agrMembLevel == nil ? 0 : 1
        case 6:
            return lastSectionItems.count
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        let section = indexPath.section
        let index = indexPath.row
        
        if section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "zeroSectionCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel,
                  let buttonView = cell.viewWithTag(2),
                  let buttonLabel = cell.viewWithTag(3) as? UILabel ,
                  let button = cell.viewWithTag(4) as? UIButton
            else {return cell}
            
            label.text = capt ?? ""
            label.font = UIFont.boldSystemFont(ofSize: 23)
            
            buttonView.isHidden = true
            
            guard let vendStatus = vendStatus , vendStatus != "" else { return cell }
            
            buttonView.isHidden = false
            
            buttonView.layer.cornerRadius = 8
            
            button.addTarget(self, action: #selector(zeroSectionCellButtonTapped(_:)), for: .touchUpInside)
            
            if vendStatus == "0"{
                buttonLabel.text = "Перепроверить"
                buttonView.backgroundColor = UIColor(named: "gray")
            }else{
                buttonLabel.text = "Перепроверяется"
                buttonView.backgroundColor = .systemYellow
            }
            
        }else if section == 1{
            
            guard !firstSectionItems.isEmpty else {return cell}
            
            let item = firstSectionItems[index]
            
            if item.isDopInfo {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelTextFieldCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel ,
                      let textField = cell.viewWithTag(2) as? UITextField else {return cell}
                
                label.text = item.label1Text
                
                textField.placeholder = "Некоторая информация"
                
                textField.text = item.label2Text
                
                textField.restorationIdentifier = "\(item.type)|\(index)*"
                
                textField.delegate = self
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel ,
                      let label2 = cell.viewWithTag(2) as? UILabel ,
                      let imageView = cell.viewWithTag(3) as? UIImageView else {return cell}
                
                label1.text = item.label1Text
                
                label2.text = item.label2Text
                
                label2.textColor = .systemGray
                
                imageView.image = UIImage(systemName: item.imageName)
                
            }
            
        }else if section == 2{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Способы отправки"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
            (cell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(dobavitSposobOtpravkiPressedInPosrednik(_:)), for: .touchUpInside)
            
        }else if section == 3{
            
            if sposobOtpravkiSectionItems.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Вы не добавляли способов отправки"
                
                return cell
                
            }
            
            let sposob = sposobOtpravkiSectionItems[index]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelTwoButtonCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let label2 = cell.viewWithTag(2) as? UILabel ,
                  let _ = cell.viewWithTag(3) as? UIImageView,
                  let _ = cell.viewWithTag(4) as? UIImageView,
                  let removeButton = cell.viewWithTag(5) as? UIButtonWithInfo else {return cell}
            
            label1.text = sposob.name
            label2.text = sposob.price + " руб."
            
            label2.textColor = .systemGray
            
            removeButton.info = "\(index)"
            
            removeButton.addTarget(self, action: #selector(removeSposobOtpravkiPressed(_:)), for: .touchUpInside)
            
        }else if section == 4{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Система прямого выкупа"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = true
            
            //            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
        }else if section == 5{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel ,
                  let buttonView = cell.viewWithTag(2),
                  let buttonLabel = cell.viewWithTag(3) as? UILabel ,
                  let button = cell.viewWithTag(4) as? UIButton
            else {return cell}
            
            label.text = "В рейтинге поставщиков"
            
            buttonView.layer.cornerRadius = 8
            buttonView.backgroundColor = UIColor(named: "gray")
            
            if agrMembLevel == "0"{
                buttonLabel.text = "Нет"
            }else if agrMembLevel == "1"{
                buttonLabel.text = "На модерации"
            }else if agrMembLevel == "2"{
                buttonLabel.text = "Да"
            }
            
            button.addTarget(self, action: #selector(ratingCellButtonTapped(_:)), for: .touchUpInside)
            
        }else if section == 6{
            
            guard !lastSectionItems.isEmpty else {return cell}
            
            let item = lastSectionItems[index]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let label2 = cell.viewWithTag(2) as? UILabel ,
                  let imageView = cell.viewWithTag(3) as? UIImageView else {return cell}
            
            label1.text = item.label1Text
            
            label2.text = item.label2Text
            
            label2.textColor = .systemGray
            
            imageView.image = UIImage(systemName: item.imageName)
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = indexPath.row
        let section = indexPath.section
        
        if section == 1{
            
            let item = firstSectionItems[index]
            
            if item.imageName == "pencil"{
                
                let alertController = UIAlertController(title: "Редактировать \(item.label1Text.lowercased())", message: nil, preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    
                    if item.type == "3"{
                        textField.keyboardType = .numberPad
                    }
                    
                    textField.placeholder = item.label2Text
                }
                
                alertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [self] _ in
                    
                    if let newValue = alertController.textFields?[0].text {
                        
                        vendUpdateInfoDataManager.getVendUpdateInfoData(key: key!, type: item.type, value: newValue) { [self] data, error in
                            
                            if error != nil , data == nil {
                                print("Erorr with VendUpdateInfoDataManager : \(error!)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                firstSectionItems[index].label2Text = newValue + (item.type == "3" ? " руб." : "")
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                
                            }else {
                                
                                if let message = data!["msg"].string{
                                    
                                    showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                present(alertController, animated: true, completion: nil)
                
            }
            
        }else if section == 3{
            
            guard !sposobOtpravkiSectionItems.isEmpty else {return}
            
            let sposob = sposobOtpravkiSectionItems[index]
            
            let priceAlertController = UIAlertController(title: "Цена доставки для \"\(sposob.name)\"", message: nil, preferredStyle: .alert)
            
            priceAlertController.addTextField { priceTextField in
                priceTextField.placeholder = "Новая цена"
                priceTextField.keyboardType = .numberPad
            }
            
            priceAlertController.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { [self] _ in
                
                guard let price = priceAlertController.textFields?[0].text else {return}
                
                VendUpdSendRuleDataManager().getVendUpdSendRuleData(key: key!, ruleId: sposob.ruleId, sendType: sposob.typeId, price: price) { [self] data, error in
                    
                    if error != nil , data == nil {
                        print("Erorr with VendUpdSendRuleDataManager : \(error!)")
                        return
                    }
                    
                    if data!["result"].intValue == 1{
                        
                        sposobOtpravkiSectionItems[index].price = price
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    } else {
                        
                        if let message = data!["msg"].string{
                            
                            showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                            
                        }
                        
                    }
                    
                }
                
            }))
            
            priceAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            present(priceAlertController, animated: true, completion: nil)
            
            
        }else if section == 6{
            
            guard !lastSectionItems.isEmpty else {return}
            
            let item = lastSectionItems[index]
            
            if item.imageName == "pencil"{
                
                let alertController = UIAlertController(title: "Редактировать \(item.label1Text.lowercased())", message: nil, preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    if item.type == "3"{
                        textField.keyboardType = .numberPad
                    }
                    textField.placeholder = item.label2Text
                }
                
                alertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [self] _ in
                    
                    if let newValue = alertController.textFields?[0].text {
                        
                        vendUpdateInfoDataManager.getVendUpdateInfoData(key: key!, type: item.type, value: newValue) { [self] data, error in
                            
                            if error != nil , data == nil {
                                print("Erorr with VendUpdateInfoDataManager : \(error!)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                lastSectionItems[index].label2Text = newValue + (item.type == "3" ? " руб." : "")
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                
                            }else {
                                
                                if let message = data!["msg"].string{
                                    
                                    showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                present(alertController, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}

//MARK:- UITextField

extension NastroykiPostavshikaTableViewController : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let value = textField.text?.replacingOccurrences(of: "\n", with: "<br>") , let key = key , let fieldId = textField.restorationIdentifier {
            
            let typeLastIndex = fieldId.firstIndex(of: "|")
            let type = String(fieldId[fieldId.startIndex..<typeLastIndex!])
            let index = String(fieldId[typeLastIndex!..<fieldId.endIndex]).replacingOccurrences(of: "|", with: "").replacingOccurrences(of: "*", with: "")
            
            print("Type : \(type) and Index : \(index)")
            
            vendUpdateInfoDataManager.getVendUpdateInfoData(key: key, type: type, value: value) { [self] data, error in
                
                if error != nil , data == nil {
                    print("Erorr with VendUpdateInfoDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    firstSectionItems[Int(index)!].label2Text = value
                    
                }else {
                    
                    if let message = data!["msg"].string{
                        
                        DispatchQueue.main.async {
                            self.showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

//MARK: - Structs

extension NastroykiPostavshikaTableViewController{
    
    private struct FirstSectionItem{
        
        var label1Text : String
        var label2Text : String
        
        var imageName = "info.circle"
        
        var type : String
        
        var isDopInfo : Bool = false
        
    }
    
    private struct SposobiOtpravkiSectionForPosrednikItem{
        
        var ruleId : String
        var name : String
        
        var typeId : String
        
        var price : String
        
    }
    
}

//MARK: - VendFormDataManager

extension NastroykiPostavshikaTableViewController : VendFormDataManagerDelegate{
    
    func didGetVendFormData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let vendInfo = data["vend_info"]
                
                capt = vendInfo["point_capt"].string
                
                var newFirstSectionItems = [FirstSectionItem]()
                
                if let phone = vendInfo["phone"].string{
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Телефон", label2Text: phone, type: "2"))
                }
                
                if let minOrderDef = vendInfo["min_order_def"].string{
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Минимальный заказ", label2Text: minOrderDef + " руб.", imageName : "pencil" , type: "3"))
                }
                
                if let card4 = vendInfo["card4"].string{
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Номер карты", label2Text: card4,imageName : "pencil" , type: "4"))
                }
                
                if let dopInfo = vendInfo["dop_info"].string?.replacingOccurrences(of: "<br>", with: "\n"){
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Дополнительная информация", label2Text: dopInfo.replacingOccurrences(of: "<br>", with: "\n"), type: "5", isDopInfo: true))
                }
                
                firstSectionItems = newFirstSectionItems
                
                var newSposobi = [SposobiOtpravkiSectionForPosrednikItem]()
                let rules = vendInfo["send_rules"].arrayValue
                
                for rule in rules{
                    newSposobi.append(SposobiOtpravkiSectionForPosrednikItem(ruleId: rule["rule_id"].stringValue, name: rule["type_name"].stringValue, typeId: rule["type_id"].stringValue, price: rule["price"].stringValue))
                }
                
                sposobOtpravkiSectionItems = newSposobi
                
                var newLastSectionItems = [FirstSectionItem]()
                
                if let minOrderAgr = vendInfo["min_order_agr"].string{
                    newLastSectionItems.append(FirstSectionItem(label1Text: "Минимальный заказ", label2Text: minOrderAgr + " руб.", imageName : "pencil" , type: "3"))
                }
                
                lastSectionItems = newLastSectionItems
                
                vendStatus = vendInfo["vend_status"].string
                
                agrMembLevel = vendInfo["agr_memb_lvl"].string
                
                tableView.reloadData()
                
            }else{
                
                
                
            }
            
        }
        
    }
    
    func didFailGettingVendFormDataWithError(error: String) {
        print("Error with VendFormDataManager : \(error)")
    }
    
}
