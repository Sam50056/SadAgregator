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
    
    private var firstSectionItems = [FirstSectionItem]()
    
    private var vendFormDataManager = VendFormDataManager()
    
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
            return 1
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

            label.text = "22-155"
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
                
                //                textField.delegate = self
                
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
                
                var newFirstSectionItems = [FirstSectionItem]()
                
                if let phone = vendInfo["phone"].string{
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Телефон", label2Text: phone, type: "2"))
                }
                
                if let minOrderDef = vendInfo["min_order_def"].string{
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Минимальный заказ", label2Text: minOrderDef, type: "3"))
                }
                
                if let card4 = vendInfo["card4"].string{
                    newFirstSectionItems.append(FirstSectionItem(label1Text: "Номер карты", label2Text: card4, type: "4"))
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
