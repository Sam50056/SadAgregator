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
    
    private var sposobOtpravkiSectionForPosrednikItems = [SposobiOtpravkiSectionForPosrednikItem]()
    
    private var secondSectionItemsForOrg = [SecondSectionForOrgItem]()
    
    private var thirdSectionItemsForPosrednik = [ThirdSectionForPosrednikItem]()
    
    private var zonesForOrg = [PurchaseZone]()
    private var zonesForPosrednik = [PurchaseZone]()
    
    private var helpersForPosrednik = [Helper]()
    
    private var level : String?
    
    private var brokersFormDataManager = BrokersFormDataManager()
    
    private lazy var brokersUpdateInfoDataManager = BrokersUpdateInfoDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        brokersFormDataManager.delegate = self
        
        update()
        
    }
    
    //MARK: - Functions
    
    func update(){
        
        if let key = key{
            brokersFormDataManager.getBrokersFormData(key: key)
        }
        
    }
    
    //MARK: - Actions
    
    @IBAction func ratingCellButtonTapped(_ sender : Any){
        
        guard let level = level , !level.isEmpty else {
            return
        }
        
        var alertTitle = ""
        var status = ""
        
        if level == "0"{
            alertTitle = "?????????????????? ???????????? ???? ?????????????????????? ?? ???????????? ???????????????????????"
        }else if level == "1"{
            alertTitle = "???????????????? ???????????? ?? ???????????????????"
        }else if level == "2"{
            alertTitle = "???????????? ???????? ???????????????? ???? ???????????????? ???????????????????????"
        }
        
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "????", style: .default, handler: { [self] _ in
            
            if level == "0"{
                status = "1"
            }else if level == "1"{
                status = "0"
            }else if level == "2"{
                status = "0"
            }
            
            BrokersBrokerStatusDataManager().getBrokersBrokerStatusData(key: key!, status: status) { data, error in
                
                DispatchQueue.main.async {
                    
                    if error != nil , data == nil {
                        print("Erorr with BrokersBrokerStatusDataManager : \(error!)")
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
    
    @IBAction func switchValueChanged(_ sender : UISwitch){
        
        guard let switchId = sender.restorationIdentifier , let key = key else {return}
        
        let typeLastIndex = switchId.firstIndex(of: "|")
        let type = String(switchId[switchId.startIndex..<typeLastIndex!])
        let index = String(switchId[typeLastIndex!..<switchId.endIndex]).replacingOccurrences(of: "|", with: "")
        
        print("Type : \(type) and Index : \(index)")
        
        let newValue = (sender.isOn ? "1" : "0")
        
        brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key, type: type, value: newValue) { [self] data, error in
            
            if error != nil , data == nil {
                print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                return
            }
            
            if data!["result"].intValue == 1{
                
                thirdSectionItemsForPosrednik[Int(index)!].value = newValue
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }else {
                
                if let message = data!["msg"].string{
                    
                    showSimpleAlertWithOkButton(title: "????????????", message: message)
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func dobavitNacenkuPressedInOrg(_ sender : Any){
        
        let createDiapazonVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateDiapazonVC") as! CreateDiapazonViewController
        
        createDiapazonVC.createdDiapazon = { [self] in
            update()
        }
        
        navigationController?.pushViewController(createDiapazonVC, animated: true)
        
    }
    
    @IBAction func dobavitSposobOtpravkiPressedInPosrednik(_ sener : Any){
        
        BrokersGetDeliveryTypeDataManager().getBrokersGetDeliveryTypeData(key: key!) { data, error in
            
            DispatchQueue.main.async { [self] in
                
                if error != nil , data == nil {
                    print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    guard let deliveryList = data!["delivery_list"].array else {return}
                    
                    let sheetAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    for deliveryItem in deliveryList{
                        
                        let deliveryName = deliveryItem["name"].stringValue
                        let deliveryId = deliveryItem["id"].stringValue
                        
                        sheetAlertController.addAction(UIAlertAction(title: deliveryName, style: .default, handler: { _ in
                            
                            let priceAlertController = UIAlertController(title: "???????? ???????????????? ?????? \"\(deliveryName)\"", message: nil, preferredStyle: .alert)
                            
                            priceAlertController.addTextField { priceTextField in
                                priceTextField.keyboardType = .numberPad
                            }
                            
                            priceAlertController.addAction(UIAlertAction(title: "????????????????", style: .default, handler: { _ in
                                
                                guard let price = priceAlertController.textFields?[0].text else {return}
                                
                                BrokersAddSendTypeDataManager().getBrokersAddSendTypeData(key: key!, sendType: deliveryId, price: price) { data, error in
                                    
                                    if error != nil , data == nil {
                                        print("Erorr with BrokersAddSendTypeDataManager : \(error!)")
                                        return
                                    }
                                    
                                    if data!["result"].intValue == 1{
                                        
                                        let ruleId = data!["rule_id"].stringValue
                                        
                                        DispatchQueue.main.async {
                                            
                                            sposobOtpravkiSectionForPosrednikItems.append(SposobiOtpravkiSectionForPosrednikItem(ruleId: ruleId, name: deliveryName, typeId: deliveryId, price: price))
                                            
                                            self.tableView.reloadData()
                                            
                                        }
                                        
                                    } else {
                                        
                                        if let message = data!["msg"].string{
                                            
                                            DispatchQueue.main.async {
                                                self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }))
                            
                            priceAlertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                            
                            DispatchQueue.main.async {
                                self.present(priceAlertController, animated: true, completion: nil)
                            }
                            
                        }))
                        
                    }
                    
                    sheetAlertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                    
                    DispatchQueue.main.async {
                        self.present(sheetAlertController, animated: true, completion: nil)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func dobavitKomissiaPressedInPosrednik(_ sender : Any){
        
        let createDiapazonVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateDiapazonVC") as! CreateDiapazonViewController
        
        createDiapazonVC.createdDiapazon = { [self] in
            update()
        }
        
        createDiapazonVC.isPosrednik = true
        
        navigationController?.pushViewController(createDiapazonVC, animated: true)
        
    }
    
    @IBAction func dobavitPomoshnikaPressedInPosrednik(_ sender : Any){
        
        let alertController = UIAlertController(title: "?????????????? ?????? ??????????????????", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        
        alertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "????????????", style: .default, handler: { [self] _ in
            
            guard let code = alertController.textFields?[0].text else {return}
            
            BrokersBrokerHelperCheckDataManager().getBrokersBrokerHelperCheckData(key: key!, code: code) { data, error in
                
                if error != nil , data == nil {
                    print("Erorr with BrokersBrokerHelperCheckDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    DispatchQueue.main.async {
                        
                        let name = data!["name"].stringValue
                        let error = data!["err_msg"].stringValue
                        
                        if !name.isEmpty , error.isEmpty{
                            
                            let nameAlertController = UIAlertController(title: "???????????????? ?????????????????? \"\(name)\"", message: nil, preferredStyle: .alert)
                            
                            nameAlertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                            
                            nameAlertController.addAction(UIAlertAction(title: "????", style: .default, handler: { _ in
                                
                                BrokersAddBrokerHelperDataManager().getBrokersAddBrokerHelperData(key: key!, code: code) { data, error in
                                    
                                    if data!["result"].intValue == 1{
                                        
                                        DispatchQueue.main.async {
                                            
                                            helpersForPosrednik.append(Helper(id: data!["rec_id"].stringValue, name: name, code: code))
                                            
                                            tableView.reloadSections([9], with: .automatic)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }))
                            
                            present(nameAlertController, animated: true, completion: nil)
                            
                        }else{
                            DispatchQueue.main.async {
                                self.showSimpleAlertWithOkButton(title: "????????????", message: error)
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func removeSposobOtpravkiPressed(_ sender : UIButtonWithInfo){
        
        guard let index = Int(sender.info) else {return}
        
        let sposob = sposobOtpravkiSectionForPosrednikItems[index]
        
        BrokersDelSendTypeDataManager().getBrokersDelSendTypeData(key: key!, ruleId: sposob.ruleId) { data, error in
            
            if error != nil , data == nil {
                print("Erorr with BrokersDelSendTypeDataManager : \(error!)")
                return
            }
            
            if data!["result"].intValue == 1{
                
                DispatchQueue.main.async {
                    
                    self.sposobOtpravkiSectionForPosrednikItems.remove(at: index)
                    
                    self.tableView.reloadSections([7], with: .automatic)
                    
                }
                
            }else {
                
                if let message = data!["msg"].string{
                    
                    DispatchQueue.main.async {
                        self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func removePomoshnik(_ sender : UIButtonWithInfo){
        
        let info = sender.info
        
        let dividerIndex = info.firstIndex(of: "|")
        let helperId = String(info[info.startIndex..<dividerIndex!])
        let index = Int(String(info[dividerIndex!..<info.endIndex]).replacingOccurrences(of: "|", with: ""))!
        
        guard !helperId.isEmpty else {return}
        
        BrokersDelBrokerHelperDataManager().getBrokersDelBrokerHelperData(key: key!, id: helperId) { data, error in
            
            if error != nil , data == nil {
                print("Erorr with BrokersDelBrokerHelperDataManager : \(error!)")
                return
            }
            
            if data!["result"].intValue == 1{
                
                DispatchQueue.main.async { [self] in
                    
                    helpersForPosrednik.remove(at: index)
                    
                    tableView.reloadSections([9], with: .automatic)
                    
                }
                
            }
            
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
            return 11
        }else{
            return 6
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard !firstSectionItemsForOrg.isEmpty || !firstSectionItemsForPosrednik.isEmpty else {return 0}
        
        if isPosrednikTab{
            
            switch section {
            
            case 0: return 1
                
            case 1: return level == nil ? 0 : 1
                
            case 2: return firstSectionItemsForPosrednik.count
                
            case 3: return 1
                
            case 4: return zonesForPosrednik.isEmpty ? 1 : zonesForPosrednik.count
                
            case 5: return thirdSectionItemsForPosrednik.isEmpty ? 0 : 1
                
            case 6: return thirdSectionItemsForPosrednik.count
                
            case 7: return 1
                
            case 8: return sposobOtpravkiSectionForPosrednikItems.isEmpty ? 1 : sposobOtpravkiSectionForPosrednikItems.count
                
            case 9: return 1
                
            case 10: return helpersForPosrednik.isEmpty ? 1 : helpersForPosrednik.count
                
            default: return 0
                
            }
            
        }else {
            
            switch section {
            
            case 0: return 1
                
            case 1: return firstSectionItemsForOrg.count
                
            case 2: return 1
                
            case 3: return secondSectionItemsForOrg.count
                
            case 4: return 1
                
            case 5: return zonesForOrg.count
                
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
        }else{
            orgCellTapped(indexPath: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        let index = indexPath.row
        
        let defaultHeight : CGFloat = 50
        
        if isPosrednikTab{
            
            switch section {
            case 0: return 70
            case 1: return 65
            case 2:
                
                if firstSectionItemsForPosrednik[index].isDopInfo{
                    return 95
                }
                
            case 4:
                
                if !zonesForPosrednik.isEmpty{
                    return 85
                }
                
            default:
                return defaultHeight
            }
            
        }else{
            
            switch section {
            case 0: return 70
            case 3:
                
                if secondSectionItemsForOrg[index].label2Text == ""{
                    return 95
                }
            case 5:
                
                if !zonesForOrg.isEmpty{
                    
                    let zone = zonesForOrg[indexPath.row]
                    
                    if zone.marge.contains("%") , zone.fix != "0"{
                        return 150
                    }else if !zone.marge.contains("%"){
                        return 80
                    }else{
                        return 115
                    }
                    
                }
                
            default:
                return defaultHeight
            }
            
        }
        
        return defaultHeight
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !isPosrednikTab , indexPath.section == 5{
            
            let editAction = UIContextualAction(style: .normal, title: nil) { [self] action, view, completion in
                
                let createDiapazonVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateDiapazonVC") as! CreateDiapazonViewController
                
                createDiapazonVC.createdDiapazon = { [self] in
                    update()
                }
                
                createDiapazonVC.thisZone = zonesForOrg[indexPath.row]
                
                navigationController?.pushViewController(createDiapazonVC, animated: true)
                
                completion(true)
                
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] action, view, completion in
                
                let zone = zonesForOrg[indexPath.row]
                
                PurchasesDelZonePriceDataManager().getPurchasesDelZonePriceData(key: key!, zoneId: zone.id) { data, error in
                    
                    if let error = error , data == nil {
                        print("Error with purchasesDelZonePriceDataManager : \(error)")
                        return
                    }
                    
                    guard let data = data else {return}
                    
                    if data["result"].intValue == 1{
                        
                        DispatchQueue.main.async { [self] in
                            
                            zonesForOrg.remove(at: indexPath.row)
                            
                            completion(true)
                            
                            tableView.reloadSections([5], with: .automatic)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            editAction.backgroundColor = .gray
            editAction.image = UIImage(systemName: "pencil")
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            
            return UISwipeActionsConfiguration(actions: [deleteAction,editAction])
            
        }else if isPosrednikTab , indexPath.section == 4{
            
            let editAction = UIContextualAction(style: .normal, title: nil) { [self] action, view, completion in
                
                let createDiapazonVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateDiapazonVC") as! CreateDiapazonViewController
                
                createDiapazonVC.createdDiapazon = { [self] in
                    update()
                }
                
                createDiapazonVC.isPosrednik = true
                
                createDiapazonVC.thisZone = zonesForPosrednik[indexPath.row]
                
                navigationController?.pushViewController(createDiapazonVC, animated: true)
                
                completion(true)
                
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [self] action, view, completion in
                
                let zone = zonesForPosrednik[indexPath.row]
                
                BrokersDelZonePriceDataManager().getBrokersDelZonePriceData(key: key!, zoneId: zone.id) { data, error in
                    
                    if let error = error , data == nil {
                        print("Error with BrokersDelZonePriceDataManager : \(error)")
                        return
                    }
                    
                    guard let data = data else {return}
                    
                    if data["result"].intValue == 1{
                        
                        DispatchQueue.main.async { [self] in
                            
                            zonesForPosrednik.remove(at: indexPath.row)
                            
                            completion(true)
                            
                            tableView.reloadSections([3], with: .automatic)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            editAction.backgroundColor = .gray
            editAction.image = UIImage(systemName: "pencil")
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            
            return UISwipeActionsConfiguration(actions: [deleteAction,editAction])
            
        }
        
        return nil
        
    }
    
    //MARK:- Cells SetUp
    
    func makeForPosrednik(indexPath : IndexPath) -> UITableViewCell{
        
        var cell = UITableViewCell()
        
        let index = indexPath.row
        let section = indexPath.section
        
        if section == 0{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "segmentedControlCell", for: indexPath)
            
            guard let segmentedControl = cell.viewWithTag(1) as? UISegmentedControl else {return cell}
            
            segmentedControl.setTitle("?????? ????", forSegmentAt: 0)
            segmentedControl.setTitle("??????????????????", forSegmentAt: 1)
            
            segmentedControl.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
            
        }else if section == 1{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel ,
                  let buttonView = cell.viewWithTag(2),
                  let buttonLabel = cell.viewWithTag(3) as? UILabel ,
                  let button = cell.viewWithTag(4) as? UIButton
            else {return cell}
            
            label.text = "?? ???????????????? ??????????????????????"
            
            buttonView.layer.cornerRadius = 8
            buttonView.backgroundColor = UIColor(named: "gray")
            
            if level == "0"{
                buttonLabel.text = "???? ????????????????????????"
            }else if level == "1"{
                buttonLabel.text = "???? ??????????????????"
            }else if level == "2"{
                buttonLabel.text = "????????????????????????"
            }
            
            button.addTarget(self, action: #selector(ratingCellButtonTapped(_:)), for: .touchUpInside)
            
        }else if section == 2{
            
            guard !firstSectionItemsForPosrednik.isEmpty else {return cell}
            
            let item = firstSectionItemsForPosrednik[index]
            
            if item.isDopInfo {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelTextViewCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel ,
                      let textView = cell.viewWithTag(2) as? UITextView else {return cell}
                
                label.text = item.label1Text
                
                textView.text = item.label2Text
                
                textView.restorationIdentifier = "\(item.type)|\(index)*"
                
                textView.delegate = self
                
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
            
        }else if section == 3{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "????????????????"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("????????????????", for: .normal)
            
            (cell.viewWithTag(2) as! UIButton).removeTarget(self, action: nil, for: .touchUpInside)
            
            (cell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(dobavitKomissiaPressedInPosrednik(_:)), for: .touchUpInside)
            
        }else if section == 4{
            
            if zonesForPosrednik.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "???? ???? ?????????????????? ???????????????????? ????????????????"
                
                return cell
                
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "diapazonCell", for: indexPath)
            
            if let firstTitleLabel = cell.viewWithTag(1) as? UILabel,
               let firstValueLabel = cell.viewWithTag(2) as? UILabel ,
               let secondTitleLabel = cell.viewWithTag(3) as? UILabel,
               let secondValueLabel = cell.viewWithTag(4) as? UILabel,
               let nacenkaLabel = cell.viewWithTag(5) as? UILabel,
               let okruglenieLabel = cell.viewWithTag(6) as? UILabel ,
               let fixNadbavkaTextLabel = cell.viewWithTag(7) as? UILabel,
               let fixNadbavkaLabel = cell.viewWithTag(8) as? UILabel ,
               let okruglenieTextLabel = cell.viewWithTag(9) as? UILabel{
                
                let zone = zonesForPosrednik[index]
                
                if zone.to == "0" || zone.from == "0" || zone.to == "" || zone.from == ""{
                    
                    if zone.to == "0" || zone.to == ""{
                        firstTitleLabel.text = "????"
                        firstValueLabel.text = zone.from + " ??????."
                    }else if zone.from == "0" || zone.from == ""{
                        firstTitleLabel.text = "????"
                        firstValueLabel.text = zone.to + " ??????."
                    }
                    
                    secondTitleLabel.text = ""
                    secondValueLabel.text = ""
                    
                }else{
                    
                    firstTitleLabel.text = "????"
                    firstValueLabel.text = zone.from + " ??????."
                    secondTitleLabel.text = "????"
                    secondValueLabel.text = zone.to + " ??????."
                    
                }
                
                nacenkaLabel.text = zone.marge + "%" //We put always percent sign because in "????????????????" , nacenka is always in percents
                
                okruglenieLabel.text = ""
                okruglenieTextLabel.isHidden = true
                
                fixNadbavkaTextLabel.isHidden = true
                fixNadbavkaLabel.text = ""
                fixNadbavkaLabel.isHidden = true
                
            }
            
        }else if section == 5{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "???????????????? ???? ????????"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = true
            
        }else if section == 6{
            
            let item = thirdSectionItemsForPosrednik[index]
            
            if item.hasSwitch {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelSwitchCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel ,
                      let `switch` = cell.viewWithTag(2) as? UISwitch else {return cell}
                
                `switch`.isOn = item.value == "1" ? true : false
                
                `switch`.restorationIdentifier = "\(item.type)|\(index)"
                
                `switch`.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
                
                label.text = item.label1Text
                
            }else {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel ,
                      let label2 = cell.viewWithTag(2) as? UILabel ,
                      let imageView = cell.viewWithTag(3) as? UIImageView else {return cell}
                
                label1.text = item.label1Text
                label2.text = item.value
                
                label2.textColor = .systemGray
                
                imageView.image = UIImage(systemName: "pencil")
                
            }
            
        }else if section == 7{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "?????????????? ????????????????"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("????????????????", for: .normal)
            
            (cell.viewWithTag(2) as! UIButton).removeTarget(self, action: nil, for: .touchUpInside)
            
            (cell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(dobavitSposobOtpravkiPressedInPosrednik(_:)), for: .touchUpInside)
            
        }else if section == 8{
            
            if sposobOtpravkiSectionForPosrednikItems.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "???? ???? ?????????????????? ???????????????? ????????????????"
                
                return cell
            }
            
            let sposob = sposobOtpravkiSectionForPosrednikItems[index]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelTwoButtonCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let label2 = cell.viewWithTag(2) as? UILabel ,
                  let _ = cell.viewWithTag(3) as? UIImageView,
                  let _ = cell.viewWithTag(4) as? UIImageView,
                  let removeButton = cell.viewWithTag(5) as? UIButtonWithInfo else {return cell}
            
            label1.text = sposob.name
            label2.text = sposob.price + " ??????."
            
            label2.textColor = .systemGray
            
            removeButton.info = "\(index)"
            
            removeButton.addTarget(self, action: #selector(removeSposobOtpravkiPressed(_:)), for: .touchUpInside)
            
        }else if section == 9{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "??????????????????"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("????????????????", for: .normal)
            
            (cell.viewWithTag(2) as! UIButton).removeTarget(self, action: nil, for: .touchUpInside)
            
            (cell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(dobavitPomoshnikaPressedInPosrednik(_:)), for: .touchUpInside)
            
        }else if section == 10{
            
            if helpersForPosrednik.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "???? ???? ?????????????????? ????????????????????"
                
                return cell
                
            }
            
            let helper = helpersForPosrednik[index]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let label2 = cell.viewWithTag(2) as? UILabel ,
                  let imageView = cell.viewWithTag(3) as? UIImageView,
                  let button = cell.viewWithTag(4) as? UIButtonWithInfo
            else {return cell}
            
            label1.text = helper.name
            
            label2.text = helper.code
            
            label2.textColor = .systemGray
            
            imageView.image = UIImage(systemName: "multiply")
            
            button.removeTarget(self, action: nil, for: .touchUpInside)
            
            button.info = "\(helper.id)|\(index)"
            
            button.addTarget(self, action: #selector(removePomoshnik(_:)), for: .touchUpInside)
            
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
            
            segmentedControl.setTitle("?????? ????", forSegmentAt: 0)
            segmentedControl.setTitle("??????????????????", forSegmentAt: 1)
            
            segmentedControl.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
            
        }else if section == 1{
            
            guard !firstSectionItemsForOrg.isEmpty else {return cell}
            
            let item = firstSectionItemsForOrg[index]
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel ,
                  let label2 = cell.viewWithTag(2) as? UILabel ,
                  let imageView = cell.viewWithTag(3) as? UIImageView,
                  let _ = cell.viewWithTag(4) as? UIButton
            else {return cell}
            
            label1.text = item.label1Text
            
            label2.text = item.label2Text
            
            label2.textColor = .systemGray
            
            imageView.image = UIImage(systemName: item.imageName)
            
        }else if section == 2{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "?????????????????? ??????????????"
            
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
                
                if item.label1Text == "???????????????????????????? ????????????????????"{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "labelTextViewCell", for: indexPath)
                    
                    guard let label = cell.viewWithTag(1) as? UILabel ,
                          let textView = cell.viewWithTag(2) as? UITextView else {return cell}
                    
                    label.text = item.label1Text
                    
                    textView.text = item.value
                    
                    textView.restorationIdentifier = "\(item.type)|\(index)"
                    
                    textView.delegate = self
                    
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
                
            }
            
        }else if section == 4{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            (cell.viewWithTag(1) as! UILabel).text = "??????????????"
            
            (cell.viewWithTag(2) as! UIButton).isHidden = false
            
            (cell.viewWithTag(2) as! UIButton).setTitle("???????????????? ??????????????", for: .normal)
            
            (cell.viewWithTag(2) as! UIButton).removeTarget(self, action: nil, for: .touchUpInside)
            
            (cell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(dobavitNacenkuPressedInOrg(_:)), for: .touchUpInside)
            
        }else if section == 5{
            
            if zonesForOrg.isEmpty{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "centredLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "???? ???? ?????????????????? ??????????????"
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "diapazonCell", for: indexPath)
                
                if let firstTitleLabel = cell.viewWithTag(1) as? UILabel,
                   let firstValueLabel = cell.viewWithTag(2) as? UILabel ,
                   let secondTitleLabel = cell.viewWithTag(3) as? UILabel,
                   let secondValueLabel = cell.viewWithTag(4) as? UILabel,
                   let nacenkaLabel = cell.viewWithTag(5) as? UILabel,
                   let okruglenieLabel = cell.viewWithTag(6) as? UILabel ,
                   let fixNadbavkaTextLabel = cell.viewWithTag(7) as? UILabel,
                   let fixNadbavkaLabel = cell.viewWithTag(8) as? UILabel,
                   let okruglenieTextLabel = cell.viewWithTag(9) as? UILabel{
                    
                    let zone = zonesForOrg[indexPath.row]
                    
                    if zone.to == "0" || zone.from == "0" || zone.to == "" || zone.from == ""{
                        
                        if zone.to == "0" || zone.to == ""{
                            firstTitleLabel.text = "????"
                            firstValueLabel.text = zone.from + " ??????."
                        }else if zone.from == "0" || zone.from == ""{
                            firstTitleLabel.text = "????"
                            firstValueLabel.text = zone.to + " ??????."
                        }
                        
                        secondTitleLabel.text = ""
                        secondValueLabel.text = ""
                        
                    }else{
                        
                        firstTitleLabel.text = "????"
                        firstValueLabel.text = zone.from + " ??????."
                        secondTitleLabel.text = "????"
                        secondValueLabel.text = zone.to + " ??????."
                        
                    }
                    
                    nacenkaLabel.text = zone.marge + (zone.marge.contains("%") ? "" : " ??????.")
                    
                    okruglenieLabel.text = zone.trunc
                    okruglenieTextLabel.isHidden = false
                    
                    if zone.marge.contains("%"){
                        fixNadbavkaTextLabel.isHidden = false
                        fixNadbavkaLabel.isHidden = false
                        fixNadbavkaLabel.text = zone.fix
                        okruglenieLabel.isHidden = false
                        okruglenieTextLabel.isHidden = false
                    }else{
                        fixNadbavkaTextLabel.isHidden = true
                        fixNadbavkaLabel.text = ""
                        fixNadbavkaLabel.isHidden = true
                        okruglenieLabel.isHidden = true
                        okruglenieTextLabel.isHidden = true
                    }
                    
                    
                }
                
            }
            
        }
        
        return cell
        
    }
    
    func posrednikCellTapped(indexPath : IndexPath){
        
        let section = indexPath.section
        let index = indexPath.row
        
        if section == 2{
            
            let item = firstSectionItemsForPosrednik[index]
            
            if item.imageName == "pencil"{
                
                let message = item.type == "03" ? "?????????????????? 4 ??????????" : nil // Type 03 is "?????????????????? ????????????"
                
                let alertController = UIAlertController(title: "?????????????????????????? \(item.label1Text.lowercased())", message: message, preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    textField.placeholder = item.label2Text
                }
                
                alertController.addAction(UIAlertAction(title: "????????????", style: .default, handler: { [self] _ in
                    
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
                                    DispatchQueue.main.async {
                                        self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                
                present(alertController, animated: true, completion: nil)
                
            }
            
        }else if section == 6{
            
            let item = thirdSectionItemsForPosrednik[index]
            
            if !item.hasSwitch{
                
                let alertController = UIAlertController(title: "?????????????????????????? \(item.label1Text.lowercased())", message: nil, preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    
                    textField.placeholder = item.value
                    
                    if item.type == "12"{
                        textField.keyboardType = .numberPad
                    }
                    
                }
                
                alertController.addAction(UIAlertAction(title: "????????????", style: .default, handler: { [self] _ in
                    
                    if let newValue = alertController.textFields?[0].text {
                        
                        brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key!, type: item.type, value: newValue) { data, error in
                            
                            if error != nil , data == nil {
                                print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                thirdSectionItemsForPosrednik[index].value = newValue
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                
                            }else {
                                
                                if let message = data!["msg"].string{
                                    DispatchQueue.main.async {
                                        self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                
                present(alertController, animated: true, completion: nil)
                
            }
            
        }else if section == 8{
            
            guard !sposobOtpravkiSectionForPosrednikItems.isEmpty else {return}
            
            let sposob = sposobOtpravkiSectionForPosrednikItems[index]
            
            let priceAlertController = UIAlertController(title: "???????? ???????????????? ?????? \"\(sposob.name)\"", message: nil, preferredStyle: .alert)
            
            priceAlertController.addTextField { priceTextField in
                priceTextField.placeholder = "?????????? ????????"
                priceTextField.keyboardType = .numberPad
            }
            
            priceAlertController.addAction(UIAlertAction(title: "????????????????", style: .default, handler: { [self] _ in
                
                guard let price = priceAlertController.textFields?[0].text else {return}
                
                BrokersUpdSendTypeDataManager().getBrokersUpdSendTypeData(key: key!, ruleId: sposob.ruleId, sendType: sposob.typeId, price: price) { [self] data, error in
                    
                    if error != nil , data == nil {
                        print("Erorr with BrokersUpdSendTypeDataManager : \(error!)")
                        return
                    }
                    
                    if data!["result"].intValue == 1{
                        
                        sposobOtpravkiSectionForPosrednikItems[index].price = price
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    } else {
                        
                        if let message = data!["msg"].string{
                            DispatchQueue.main.async{
                                self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                            }
                        }
                        
                    }
                    
                }
                
            }))
            
            priceAlertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
            
            present(priceAlertController, animated: true, completion: nil)
            
        }
        
    }
    
    func orgCellTapped(indexPath : IndexPath){
        
        let section = indexPath.section
        let index = indexPath.row
        
        if section == 1{
            
            let item = firstSectionItemsForOrg[index]
            
            if item.imageName == "pencil"{
                
                let alertController = UIAlertController(title: "?????????????????????????? \(item.label1Text.lowercased())", message: nil, preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    textField.placeholder = item.label2Text
                }
                
                alertController.addAction(UIAlertAction(title: "????????????", style: .default, handler: { [self] _ in
                    
                    if let newValue = alertController.textFields?[0].text {
                        
                        brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key!, type: item.type, value: newValue) { data, error in
                            
                            if error != nil , data == nil {
                                print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                firstSectionItemsForOrg[index].label2Text = newValue
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                
                            }else {
                                
                                if let message = data!["msg"].string{
                                    DispatchQueue.main.async{
                                        self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }))
                
                alertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                
                present(alertController, animated: true, completion: nil)
                
            }
            
        }else if section == 3{
            
            let item = secondSectionItemsForOrg[index]
            
            if item.imageName == "pencil"{
                
                if item.type == "10"{//??????????????????
                    
                    BrokersGetDeliveryTypeDataManager().getBrokersGetDeliveryTypeData(key: key!) { data, error in
                        
                        DispatchQueue.main.async { [self] in
                            
                            if error != nil , data == nil {
                                print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                                return
                            }
                            
                            if data!["result"].intValue == 1{
                                
                                guard let deliveryList = data!["delivery_list"].array else {return}
                                
                                let sheetAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                
                                for deliveryItem in deliveryList{
                                    
                                    sheetAlertController.addAction(UIAlertAction(title: deliveryItem["name"].stringValue, style: .default, handler: { _ in
                                        
                                        let newValue = deliveryItem["id"].stringValue
                                        
                                        self.brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: self.key!, type: item.type, value: newValue) { data, error in
                                            
                                            if error != nil , data == nil {
                                                print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                                                return
                                            }
                                            
                                            if data!["result"].intValue == 1{
                                                
                                                self.secondSectionItemsForOrg[index].label2Text = deliveryItem["name"].stringValue
                                                
                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                }
                                                
                                            }else {
                                                
                                                if let message = data!["msg"].string{
                                                    
                                                    DispatchQueue.main.async {
                                                        self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }))
                                    
                                }
                                
                                sheetAlertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                                
                                DispatchQueue.main.async {
                                    self.present(sheetAlertController, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }else{
                    
                    let alertController = UIAlertController(title: "?????????????????????????? \(item.label1Text.lowercased())", message: nil, preferredStyle: .alert)
                    
                    alertController.addTextField { textField in
                        textField.placeholder = item.label2Text
                    }
                    
                    alertController.addAction(UIAlertAction(title: "????????????", style: .default, handler: { [self] _ in
                        
                        if let newValue = alertController.textFields?[0].text {
                            
                            brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key!, type: item.type, value: newValue) { data, error in
                                
                                if error != nil , data == nil {
                                    print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                                    return
                                }
                                
                                if data!["result"].intValue == 1{
                                    
                                    secondSectionItemsForOrg[index].label2Text = newValue
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                    }
                                    
                                }else {
                                    
                                    if let message = data!["msg"].string{
                                        
                                        DispatchQueue.main.async {
                                            self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "????????????", style: .cancel, handler: nil))
                    
                    present(alertController, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
}

//MARK:- TextField Stuff

extension NastroykiPosrednikaTableViewController : UITextFieldDelegate , UITextViewDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let value = textField.text?.replacingOccurrences(of: "\n", with: "<br>") , let key = key , let fieldId = textField.restorationIdentifier {
            
            let typeLastIndex = fieldId.firstIndex(of: "|")
            let type = String(fieldId[fieldId.startIndex..<typeLastIndex!])
            let index = String(fieldId[typeLastIndex!..<fieldId.endIndex]).replacingOccurrences(of: "|", with: "").replacingOccurrences(of: "*", with: "")
            
            print("Type : \(type) and Index : \(index)")
            
            brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key, type: type, value: value) { [self] data, error in
                
                if error != nil , data == nil {
                    print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    if fieldId.contains("*"){
                        firstSectionItemsForPosrednik[Int(index)!].label2Text = value
                    }else{
                        secondSectionItemsForOrg[Int(index)!].value = value
                    }
                    
                }else {
                    
                    if let message = data!["msg"].string{
                        
                        DispatchQueue.main.async {
                            self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if let value = textView.text?.replacingOccurrences(of: "\n", with: "<br>") , let key = key , let fieldId = textView.restorationIdentifier {
            
            let typeLastIndex = fieldId.firstIndex(of: "|")
            let type = String(fieldId[fieldId.startIndex..<typeLastIndex!])
            let index = String(fieldId[typeLastIndex!..<fieldId.endIndex]).replacingOccurrences(of: "|", with: "").replacingOccurrences(of: "*", with: "")
            
            print("Type : \(type) and Index : \(index)")
            
            brokersUpdateInfoDataManager.getBrokersUpdateInfoData(key: key, type: type, value: value) { [self] data, error in
                
                if error != nil , data == nil {
                    print("Erorr with BrokersUpdateInfoDataManager : \(error!)")
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    if fieldId.contains("*"){
                        firstSectionItemsForPosrednik[Int(index)!].label2Text = value
                    }else{
                        secondSectionItemsForOrg[Int(index)!].value = value
                    }
                    
                }else {
                    
                    if let message = data!["msg"].string{
                        
                        DispatchQueue.main.async {
                            self.showSimpleAlertWithOkButton(title: "????????????", message: message)
                        }
                        
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
    
    private struct SposobiOtpravkiSectionForPosrednikItem{
        
        var ruleId : String
        var name : String
        
        var typeId : String
        
        var price : String
        
    }
    
    private struct Helper{
        
        var id : String
        
        var name : String
        var code : String
        
    }
    
    private struct SecondSectionForOrgItem{
        
        var label1Text : String
        var label2Text : String = ""
        
        var value : String
        
        var type : String
        
        var imageName = "info.circle"
        
    }
    
    private struct ThirdSectionForPosrednikItem{
        
        var label1Text : String
        
        var type : String
        var value : String
        
        var hasSwitch : Bool = false
        
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
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "?????? ????????????????", label2Text: partnerCode, type: "17"))
            }
            
            if let phone = brokerProfile["phone_broker"].string{
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "??????????????", label2Text: phone, imageName: "pencil", type: "02"))
            }
            
            if let rekviziti = brokerProfile["card4"].string{
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "?????????????????? ?????? ????????????", label2Text: rekviziti, imageName: "pencil", type: "03"))
            }
            
            if let dopInfo = brokerProfile["broker_terms"].string?.replacingOccurrences(of: "<br>", with: "\n"){
                newFirstSectionItemsForPosrednik.append(FirstSectionItem(label1Text: "???????????????????????????? ????????????????????", label2Text: dopInfo, type: "09", isDopInfo: true))
            }
            
            firstSectionItemsForPosrednik = newFirstSectionItemsForPosrednik
            
            var newThirdSectionItemsForPosrednik = [ThirdSectionForPosrednikItem]()
            
            if let defectCheck = brokerProfile["defect_check"].string{
                newThirdSectionItemsForPosrednik.append(ThirdSectionForPosrednikItem(label1Text: "???????????????????? ????????????", type: "11", value: defectCheck, hasSwitch: true))
            }
            
            if let defectPrice = brokerProfile["defect_price"].string{
                newThirdSectionItemsForPosrednik.append(ThirdSectionForPosrednikItem(label1Text: "?????????????????? ???? 1 ????.", type: "12", value: defectPrice))
            }
            
            thirdSectionItemsForPosrednik = newThirdSectionItemsForPosrednik
            
            var newSposobi = [SposobiOtpravkiSectionForPosrednikItem]()
            let rules = brokerProfile["send_rules"].arrayValue
            
            for rule in rules{
                newSposobi.append(SposobiOtpravkiSectionForPosrednikItem(ruleId: rule["rule_id"].stringValue, name: rule["type_name"].stringValue, typeId: rule["type_id"].stringValue, price: rule["price"].stringValue))
            }
            
            sposobOtpravkiSectionForPosrednikItems = newSposobi
            
            let jsonZonesForPosrednik = brokerProfile["zones_broker"].arrayValue
            var newZonesForPosrednik = [PurchaseZone]()
            for jsonZone in jsonZonesForPosrednik{
                
                let zone = PurchaseZone(id: jsonZone["zone_id"].stringValue, from: jsonZone["from"].stringValue, to: jsonZone["to"].stringValue, marge: jsonZone["marge"].stringValue, fix: jsonZone["fix"].stringValue, trunc: jsonZone["trunc"].stringValue)
                
                newZonesForPosrednik.append(zone)
                
            }
            zonesForPosrednik = newZonesForPosrednik
            
            var newHelpersForPosrednik = [Helper]()
            
            let jsonHelpers = brokerProfile["broker_helpers"].arrayValue
            
            for jsonHelper in jsonHelpers{
                
                newHelpersForPosrednik.append(Helper(id: jsonHelper["hid"].stringValue, name: jsonHelper["name"].stringValue, code: jsonHelper["code"].stringValue))
                
            }
            
            helpersForPosrednik = newHelpersForPosrednik
            
            level = brokerProfile["lvl"].string
            
            //ORG Stuff
            
            var newFirstSectionItemsForOrg = [FirstSectionItem]()
            
            if let orgPhone = brokerProfile["phone_org"].string{
                newFirstSectionItemsForOrg.append(FirstSectionItem(label1Text: "??????????????", label2Text: orgPhone, imageName: "pencil", type: "01"))
            }
            
            firstSectionItemsForOrg = newFirstSectionItemsForOrg
            
            var newSecondSectionItems = [SecondSectionForOrgItem]()
            
            if let deliveryType = brokerProfile["delivery_type"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "??????????????????", label2Text: deliveryType, value: "", type: "10", imageName: "pencil"))
            }
            
            if let pochIndex = brokerProfile["poch_index"].string {
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "????????????", value: pochIndex, type: "4"))
            }
            
            if let docNum = brokerProfile["doc_num"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "?????????? ?? ?????????? ????????????????", value: docNum, type: "5"))
            }
            
            if let fio = brokerProfile["fio"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "??????", value: fio, type: "6"))
            }
            
            if let tkAddress = brokerProfile["tk_address"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "?????????? ??????????????????", value: tkAddress, type: "7"))
            }
            
            if let dopInfo = brokerProfile["delivery_com"].string{
                newSecondSectionItems.append(SecondSectionForOrgItem(label1Text: "???????????????????????????? ????????????????????", value: dopInfo, type: "8"))
            }
            
            secondSectionItemsForOrg = newSecondSectionItems
            
            let jsonZonesForOrg = brokerProfile["zones_sp"].arrayValue
            var newZonesForOrg = [PurchaseZone]()
            for jsonZone in jsonZonesForOrg{
                
                let zone = PurchaseZone(id: jsonZone["zone_id"].stringValue, from: jsonZone["from"].stringValue, to: jsonZone["to"].stringValue, marge: jsonZone["marge"].stringValue, fix: jsonZone["fix"].stringValue, trunc: jsonZone["trunc"].stringValue)
                
                newZonesForOrg.append(zone)
                
            }
            zonesForOrg = newZonesForOrg
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingBrokersFormDataWithError(error: String) {
        print("Error with BrokersFormDataManager : \(error)")
    }
    
}
