//
//  NastroykiPosrednikaTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.06.2021.
//

import UIKit
import SwiftUI

//MARK: - ViewController Representable

struct NastroykiPosrednikaView : UIViewControllerRepresentable{
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    func makeUIViewController(context: Context) -> NastroykiPosrednikaTableViewController {
        
        let nastroykiPosrednikaVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NastroykiPosrednikaVC") as! NastroykiPosrednikaTableViewController
        
        nastroykiPosrednikaVC.key = menuViewModel.getUserDataObject()?.key
        
        return nastroykiPosrednikaVC
        
    }
    
    func updateUIViewController(_ uiViewController: NastroykiPosrednikaTableViewController, context: Context) {
        
    }
    
}

//MARK: - ViewController

class NastroykiPosrednikaTableViewController: UITableViewController {
    
    var key : String?
    
    private var isPosrednikTab = true
    
    private var firstSectionItems = [FirstSectionItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        firstSectionItems = [
            FirstSectionItem(label1Text: "Код партнера", label2Text: "37982723"),
            FirstSectionItem(label1Text: "Телефон", label2Text: "3423423423" , imageName: "pencil"),
            FirstSectionItem(label1Text: "Реквизиты для оплаты", label2Text: "*2343", imageName: "pencil"),
            FirstSectionItem(label1Text: "Дополнительная информация", label2Text: "" , isDopInfo: true)
        ]
        
    }
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isPosrednikTab{
            return 9
        }else{
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isPosrednikTab{
            
            switch section {
            
            case 0: return firstSectionItems.count + 1
                
            case 1: return 1
                
            case 2: return 1
                
            case 3: return 1
                
            case 4: return 2
                
            case 5: return 1
                
            case 6: return 1
                
            case 7: return 1
                
            case 8: return 1
                
            default: return 0
                
            }
            
        }else {
            
            switch section {
            
            case 0: return 1 + 1
                
            case 1: return 6
                
            case 2: return 2
                
            default: return 0
                
                
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let section = indexPath.section
        
        var cell = UITableViewCell()
        
        if section == 0{
            
            if index == 0 {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "segmentedControlCell", for: indexPath)
                
                guard let segmentedControl = cell.viewWithTag(1) as? UISegmentedControl else {return cell}
                
                segmentedControl.setTitle("Орг СП", forSegmentAt: 0)
                segmentedControl.setTitle("Посредник", forSegmentAt: 1)
                
            }else{
                
                guard !firstSectionItems.isEmpty else {return cell}
                
                let item = firstSectionItems[index - 1]
                
                if item.isDopInfo {
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "labelTextFieldCell", for: indexPath)
                    
                    guard let _ = cell.viewWithTag(1) as? UILabel ,
                          let textField = cell.viewWithTag(2) as? UITextField else {return cell}
                    
                    textField.placeholder = "Некоторая информация"
                    
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
                
            }
            
        }else if section == 1{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Комиссия"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
        }else if section == 2{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли диапазонов комиссий"
            
            
        }else if section == 3{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Проверка на брак"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = true
            
        }else if section == 4{
            
            if index == 0{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelSwitchCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Активность услуги"
                
            }else {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel ,
                      let label2 = cell.viewWithTag(2) as? UILabel ,
                      let imageView = cell.viewWithTag(3) as? UIImageView else {return cell}
             
                label1.text = "Стоимость за 1 ед."
                label2.text = "30 руб"
                
                label2.textColor = .systemGray
                
                imageView.image = UIImage(systemName: "pencil")
                
            }
            
        }else if section == 5{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Способы отправки"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
        }else if section == 6{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли способов отправки"
            
        }else if section == 7{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Помощники"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
        }else if section == 8{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли помощников"
            
        }
        
        return cell
        
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        switch section {
//        case 1:
//            return "Комиссия"
//        case 2:
//            return "Проверка на брак"
//        case 3:
//            return "Способы отправки"
//        case 4:
//            return "Помощники"
//        default:
//            return nil
//        }
//
//    }
//
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK: - Structs

extension NastroykiPosrednikaTableViewController {
    
    private struct FirstSectionItem{
        
        var label1Text : String
        var label2Text : String
        
        var imageName = "info.circle"
        
        var isDopInfo : Bool = false
        
    }
    
}
