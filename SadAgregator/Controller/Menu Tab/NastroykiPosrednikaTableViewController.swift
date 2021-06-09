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
    
    private var isPosrednikTab = false
    
    private var firstSectionItemsForPosrednik = [FirstSectionItem]()
    private var firstSectionItemsForOrg = [FirstSectionItem]()
    
    private var secondSectionItemsForOrg = [SecondSectionForOrgItem]()
    
    private var brokersFormDataManager = BrokersFormDataManager()
    
    private lazy var brokersUpdateInfoDataManager = BrokersUpdateInfoDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        brokersFormDataManager.delegate = self
        
        if let key = key{
            brokersFormDataManager.getBrokersFormData(key: key)
        }
        
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
            return 6
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
                
            case 2: return 1
                
            case 3: return secondSectionItemsForOrg.count
                
            case 4: return 1
                
            case 5: return 1
                
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
        
        if isPosrednikTab{
            posrednikCellTapped(indexPath: indexPath)
        }
        
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
                
                guard let label = cell.viewWithTag(1) as? UILabel ,
                      let textField = cell.viewWithTag(2) as? UITextField else {return cell}
                
                label.text = item.label1Text
                
                textField.placeholder = "Некоторая информация"
                
                textField.text = item.label2Text
                
                textField.delegate = nil
                
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
            
        }else if section == 2{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Получение посылок"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = true
            
        }else if section == 3{
            
            let item = secondSectionItemsForOrg[index]
            
            if item.label2Text != ""{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel ,
                      let label2 = cell.viewWithTag(2) as? UILabel ,
                      let imageView = cell.viewWithTag(3) as? UIImageView else {return cell}
                
                label1.text = item.label1Text
                
                label2.text = item.label2Text
                
                label2.textColor = .systemGray
                
                imageView.image = UIImage(systemName: item.imageName)
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelTextFieldCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel ,
                      let textField = cell.viewWithTag(2) as? UITextField else {return cell}
                
                label.text = item.label1Text
                
                textField.placeholder = item.label1Text
                
                textField.text = item.value
                
                textField.restorationIdentifier = "\(item.type)|\(index)"
                
                textField.delegate = self
                
            }
            
        }else if section == 4{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "Наценки"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("Добавить наценку", for: .normal)
            
        }else if section == 5{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Вы не добавляли наценки"
            
        }
        
        return cell
        
    }
    
    func posrednikCellTapped(indexPath : IndexPath){
        
        let section = indexPath.section
        let index = indexPath.row
        
        if section == 1{
            
            let item = firstSectionItemsForPosrednik[index]
            
            if item.imageName == "pencil"{
                
                let alertController = UIAlertController(title: "Редактировать \(item.label1Text.lowercased())", message: nil, preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    textField.placeholder = item.label2Text
                }
                
                alertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [self] _ in
                    
                    if let newValue = alertController.textFields?[0].text {
                        
                        brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key!, type: item.type, value: newValue) { data, error in
                            
                            if error != nil , data == nil {
                                print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                firstSectionItemsForPosrednik[index].label2Text = newValue
                                
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

//MARK:- TextField Stuff

extension NastroykiPosrednikaTableViewController : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let value = textField.text , let key = key , let fieldId = textField.restorationIdentifier {
            
            let typeLastIndex = fieldId.firstIndex(of: "|")
            let type = String(fieldId[fieldId.startIndex..<typeLastIndex!])
            let index = String(fieldId[typeLastIndex!..<fieldId.endIndex]).replacingOccurrences(of: "|", with: "")
            
            print("Type : \(type) and Index : \(index)")
            
            brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key, type: type, value: value) { [self] data, error in
                
                if error != nil , data == nil {
                    print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    secondSectionItemsForOrg[Int(index)!].value = value
                    
                }else {
                    
                    if let message = data!["msg"].string{
                        
                        showSimpleAlertWithOkButton(title: "Ошибка", message: message)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

//MARK: - Structs

extension NastroykiPosrednikaTableViewController {
    
    private struct FirstSectionItem{
        
        var label1Text : String
        var label2Text : String
        
        var imageName = "info.circle"
        
        var type : String
        
        var isDopInfo : Bool = false
        
    }
    
    private struct SecondSectionForOrgItem{
        
        var label1Text : String
        var label2Text : String = ""
        
        var value : String
        
        var type : String
        
        var imageName = "info.circle"
        
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
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Код партнера", label2Text: partnerCode, type: "17"))
            }
            
            if let phone = brokerProfile["phone_broker"].string{
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Телефон", label2Text: phone, imageName: "pencil", type: "02"))
            }
            
            if let rekviziti = brokerProfile["card4"].string{
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Реквизиты для оплаты", label2Text: rekviziti, imageName: "pencil", type: "03"))
            }
            
            if let dopInfo = brokerProfile["broker_terms"].string{
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "Дополнительная информация", label2Text: dopInfo, type: "09", isDopInfo: true))
            }
            
            firstSectionItemsForPosrednik = newFirstSectionItemsForPosrednik
            
            //ORG Stuff
            
            var newFirstSectionItemsForOrg = [FirstSectionItem]()
            
            if let orgPhone = brokerProfile["phone_org"].string{
                newFirstSectionItemsForOrg.append(FirstSectionItem(label1Text: "Телефон", label2Text: orgPhone, type: "01"))
            }
            
            firstSectionItemsForOrg = newFirstSectionItemsForOrg
            
            var newSecondSectionItems = [SecondSectionForOrgItem]()
            
            if let deliveryType = brokerProfile["delivery_type"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "Пересылка", label2Text: deliveryType, value: "", type: "10", imageName: "pencil"))
            }
            
            if let pochIndex = brokerProfile["poch_index"].string {
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "Индекс", value: pochIndex, type: "4"))
            }
            
            if let docNum = brokerProfile["doc_num"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "Серия и номер паспорта", value: docNum, type: "5"))
            }
            
            if let fio = brokerProfile["fio"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "ФИО", value: fio, type: "6"))
            }
            
            if let tkAddress = brokerProfile["tk_address"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "Адрес терминала", value: tkAddress, type: "7"))
            }
            
            if let dopInfo = brokerProfile["delivery_com"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "Дополнительная информация", value: dopInfo, type: "8"))
            }
            
            secondSectionItemsForOrg = newSecondSectionItems
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingBrokersFormDataWithError(error: String) {
        print("Error with BrokersFormDataManager : \(error)")
    }
    
}
