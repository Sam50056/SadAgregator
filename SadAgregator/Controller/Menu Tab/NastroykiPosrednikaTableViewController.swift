//
//  NastroykiPosrednikaTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.06.2021.
//

import UIKit
import SwiftUI
import SwiftyJSON

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
    
    private var firstSectionItemsForPosrednik = [FirstSectionItem]()
    private var firstSectionItemsForOrg = [FirstSectionItem]()
    
    private var brokersFormDataManager = BrokersFormDataManager()
    
    private var dopInfoText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        brokersFormDataManager.delegate = self
        
        if let key = key{
            brokersFormDataManager.getBrokersFormData(key: key)
        }
        
        //        firstSectionItems = [
        //            FirstSectionItem(label1Text: "Код партнера", label2Text: "37982723"),
        //            FirstSectionItem(label1Text: "Телефон", label2Text: "3423423423" , imageName: "pencil"),
        //            FirstSectionItem(label1Text: "Реквизиты для оплаты", label2Text: "*2343", imageName: "pencil"),
        //            FirstSectionItem(label1Text: "Дополнительная информация", label2Text: "" , isDopInfo: true)
        //        ]
        
    }
    
    //MARK: - SegmentedControl
    
    @IBAction func indexChanged(_ sender : UISegmentedControl){
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            isPosrednikTab = false
        case 1:
            isPosrednikTab = true
        default:
            break
        }
        
        tableView.reloadData()
        
    }
    
    // MARK: - TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isPosrednikTab{
            return 10
        }else{
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isPosrednikTab{
            
            switch section {
            
            case 0: return 1
                
            case 1: return firstSectionItemsForPosrednik.count
                
            case 2: return 1
                
            case 3: return 1
                
            case 4: return 1
                
            case 5: return 2
                
            case 6: return 1
                
            case 7: return 1
                
            case 8: return 1
                
            case 9: return 1
                
            default: return 0
                
            }
            
        }else {
            
            switch section {
            
            case 0: return 1
                
            case 1: return firstSectionItemsForOrg.count
                
            case 2: return 6
                
            case 3: return 2
                
            default: return 0
                
                
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isPosrednikTab {
            return makeForPosrednik(indexPath: indexPath)
        }else{
            return makeForORG(indexPath: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK:- Cells SetUp
    
    func makeForPosrednik(indexPath : IndexPath) -> UITableViewCell{
        
        var cell = UITableViewCell()
        
        let index = indexPath.row
        let section = indexPath.section
        
        if section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "segmentedControlCell", for: indexPath)
            
            guard let segmentedControl = cell.viewWithTag(1) as? UISegmentedControl else {return cell}
            
            segmentedControl.setTitle("Орг СП", forSegmentAt: 0)
            segmentedControl.setTitle("Посредник", forSegmentAt: 1)
            
            segmentedControl.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
            
        }else if section == 1{
            
            guard !firstSectionItemsForPosrednik.isEmpty else {return cell}
            
            let item = firstSectionItemsForPosrednik[index]
            
            if item.isDopInfo {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelTextFieldCell", for: indexPath)
                
                guard let _ = cell.viewWithTag(1) as? UILabel ,
                      let textField = cell.viewWithTag(2) as? UITextField else {return cell}
                
                textField.placeholder = "Некоторая информация"
                
                textField.text = dopInfoText
                
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
            
            (cell.viewWithTag(1) as! UILabel).text = "Комиссия"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
        }else if section == 3{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли диапазонов комиссий"
            
        }else if section == 4{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Проверка на брак"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = true
            
        }else if section == 5{
            
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
            
        }else if section == 6{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Способы отправки"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
        }else if section == 7{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли способов отправки"
            
        }else if section == 8{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Помощники"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить", for: .normal)
            
        }else if section == 9{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли помощников"
            
        }
        
        return cell
        
    }
    
    func makeForORG(indexPath : IndexPath) -> UITableViewCell{
        
        var cell = UITableViewCell()
        
        let index = indexPath.row
        let section = indexPath.section
        
        if section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "segmentedControlCell", for: indexPath)
            
            guard let segmentedControl = cell.viewWithTag(1) as? UISegmentedControl else {return cell}
            
            segmentedControl.setTitle("Орг СП", forSegmentAt: 0)
            segmentedControl.setTitle("Посредник", forSegmentAt: 1)
            
            segmentedControl.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
            
        }else if section == 1{
            
            guard !firstSectionItemsForOrg.isEmpty else {return cell}
            
            let item = firstSectionItemsForOrg[index]
            
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

//MARK: - BrokersFormDataManagerDelegate

extension NastroykiPosrednikaTableViewController : BrokersFormDataManagerDelegate{
    
    func didGetBrokersFormData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            var newFirstSectionItemsForPosrednik = [FirstSectionItem]()
            
            let brokerProfile = data["broker_profile"]
            
            //Posrednik Stuff
            
            if let partnerCode = brokerProfile["partner_code"].string {
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Код партнера", label2Text: partnerCode))
            }
            
            if let phone = brokerProfile["phone_broker"].string{
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Телефон", label2Text: phone, imageName: "pencil"))
            }
            
            if let rekviziti = brokerProfile["card4"].string{
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Реквизиты для оплаты", label2Text: rekviziti, imageName: "pencil"))
            }
            
            newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Дополнительная информация", label2Text: "", isDopInfo: true))
            
            dopInfoText = brokerProfile["broker_terms"].stringValue
            
            firstSectionItemsForPosrednik = newFirstSectionItemsForPosrednik
            
            //ORG Stuff
            
            var newFirstSectionItemsForOrg = [FirstSectionItem]()
            
            if let orgPhone = brokerProfile["phone_org"].string{
                newFirstSectionItemsForOrg.append(FirstSectionItem(label1Text: "Телефон", label2Text: orgPhone))
            }
            
            firstSectionItemsForOrg = newFirstSectionItemsForOrg
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingBrokersFormDataWithError(error: String) {
        print("Error with BrokersFormDataManager : \(error)")
    }
    
}
