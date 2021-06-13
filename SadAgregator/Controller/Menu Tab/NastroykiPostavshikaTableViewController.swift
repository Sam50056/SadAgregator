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
    
    private var vendFormDataManager = VendFormDataManager()
    private lazy var vendUpdateInfoDataManager = VendUpdateInfoDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vendFormDataManager.delegate = self
        
        tableView.separatorStyle = .none
        
        update()
        
    }
    
    //MARK: - Update
    
    func update(){
        
        if let key = key{
            vendFormDataManager.getVendFormData(key: key)
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return capt == nil ? 0 : 1
        case 1:
            return firstSectionItems.count
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        case 5:
            return 2
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
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}

            label.text = capt!
            label.font = UIFont.boldSystemFont(ofSize: 23)
            
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
            
        }else if section == 3{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли способов отправки"
            
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
            
        }
        
    }
    
}

//MARK:- UITextField

extension NastroykiPostavshikaTableViewController : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let value = textField.text , let key = key , let fieldId = textField.restorationIdentifier {
            
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
                
                if let dopInfo = vendInfo["dop_info"].string{
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Дополнительная информация", label2Text: dopInfo.replacingOccurrences(of: "<br>", with: "\n"), type: "5", isDopInfo: true))
                }
                
                firstSectionItems = newFirstSectionItems
                
                tableView.reloadData()
                
            }else{
                
                
                
            }
            
        }
        
    }
    
    func didFailGettingVendFormDataWithError(error: String) {
        print("Error with VendFormDataManager : \(error)")
    }
    
}
