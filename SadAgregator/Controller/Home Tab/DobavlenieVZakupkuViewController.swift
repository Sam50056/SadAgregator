//
//  DobavlenieVZakupkuViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 08.04.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON
import SDWebImage

class DobavlenieVZakupkuViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var thisImageId : String?
    
    var thisSize : String?
    
    private var osnovnoeCellItemsArray = [OsnovnoeCellItem]()
    private var dopolnitelnoCellItemsArray = [DopolnitelnoSwitchCellItem]()
    private var klientiCellItemsArray = [KlientiCellItem]()
    private var clients = [KlientiCellKlientItem]()
    
    private var selectedZakupka : Zakupka?
    
    private var purchasesItemInfoDataManager = PurchasesItemInfoDataManager()
    
    private var cenaProdazhi : Int?
    
    private var itemInfo : JSON?{
        didSet{
            
            guard let itemInfo = itemInfo else {return}
            
            var newArray = [OsnovnoeCellItem]()
            
            if let price = itemInfo["pur_price"].string{
                newArray.append(OsnovnoeCellItem(firstLabelText: "Закупка", secondLabelText: price + " руб.", hasImageView: true))
            }
            
            if let cenaProdazhi = itemInfo["sell_price"].string {
                newArray.append(OsnovnoeCellItem(firstLabelText: "Цена продажи", secondLabelText: String(cenaProdazhi) + " руб.", hasImageView: true,isCenaProdazhi: true))
            }
            
            if let size = thisSize {
                newArray.append(OsnovnoeCellItem(firstLabelText: "Размер", secondLabelText: size, hasImageView: false))
            }
            
            osnovnoeCellItemsArray = newArray
            
        }
    }
    
    private var bezZamenSwitch : Bool = false{
        didSet{
            
        }
    }
    private var oplachenoSwitch : Bool = false{
        didSet{
            
            if oplachenoSwitch {
                
                tableView.beginUpdates()
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Загрузить фото посылки", isComment: false, isSwitch: false, shouldLabelTextBeBlue: true), at: 3)
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Загрузить фото чека", isComment: false, isSwitch: false, shouldLabelTextBeBlue: true), at: 4)
                
                tableView.insertRows(at: [IndexPath(row: 3, section: 3),IndexPath(row: 4, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }else{
                
                tableView.beginUpdates()
                
                dopolnitelnoCellItemsArray.remove(at: 3)
                dopolnitelnoCellItemsArray.remove(at: 4)
                
                tableView.deleteRows(at: [IndexPath(row: 3, section: 3),IndexPath(row: 4, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }
            
        }
    }
    private var proverkaNaBrakSwitch : Bool = false{
        didSet{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserData()
        key = "part_2_test"
        
        purchasesItemInfoDataManager.delegate = self
        
        dopolnitelnoCellItemsArray = [
            DopolnitelnoSwitchCellItem(labelText: "Без замен", isSwitch: true),
            DopolnitelnoSwitchCellItem(labelText: "Оплачено", isSwitch: true),
            DopolnitelnoSwitchCellItem(labelText: "Проверка на брак", isSwitch: true),
            DopolnitelnoSwitchCellItem(labelText: "Комментарий", isComment: true, isSwitch: false, shouldLabelTextBeBlue: false),
            DopolnitelnoSwitchCellItem(labelText: "Свой комментарий", isComment: true, isSwitch: false, shouldLabelTextBeBlue: false)
        ]
        
        klientiCellItemsArray = [
            KlientiCellItem(labelText: "Выбрать клиента..."),
            KlientiCellItem(labelText: "Замена для..."),
            KlientiCellItem(labelText: "Выбрать закупку")
        ]
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let safeID = thisImageId{
            purchasesItemInfoDataManager.getPurchasesItemInfoData(key: key, imageId: safeID)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Добавление в закупку"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(otmenaTapped(_:)))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: nil)
        
    }
    
}

//MARK: - Actions

extension DobavlenieVZakupkuViewController {
    
    @IBAction func otmenaTapped(_ sender : Any){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bezZamenSwitchValueChanged(_ sender : UISwitch){
        bezZamenSwitch = sender.isOn
        //        print("BEZ ZAMEN : \(bezZamenSwitch)")
    }
    
    @IBAction func oplachenoSwitchValueChanged(_ sender : UISwitch){
        oplachenoSwitch = sender.isOn
        //        print("OPLACHENO : \(oplachenoSwitch)")
    }
    
    @IBAction func proverkaNaBrakSwitchValueChanged(_ sender : UISwitch){
        proverkaNaBrakSwitch = sender.isOn
        //        print("PROVERKA : \(proverkaNaBrakSwitch)")
    }
    
    @IBAction func closeClientInfoButtonPressed(_ sender : UIButtonWithInfo){
        
        guard let index = Int(sender.info) else {return}
        
        clients.remove(at: index)
        
        tableView.reloadData()
        
    }
    
}

//MARK: - TableView

extension DobavlenieVZakupkuViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            
            if itemInfo != nil {
                return 1 + osnovnoeCellItemsArray.count
            }else{
                return 0
            }
            
        case 2:
            
            return itemInfo != nil ? 2 : 0
            
        case 3:
            
            return dopolnitelnoCellItemsArray.count
            
        case 4:
            
            return klientiCellItemsArray.count + clients.count
            
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let index = indexPath.row
        
        var cell = UITableViewCell()
        
        switch section{
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "singleCentredLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Для себя"
            
            label.textColor = .systemBlue
            
        case 1:
            
            if index == 0 {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "osnovnoeFirstItemCell", for: indexPath)
                
                guard let captLabel = cell.viewWithTag(1) as? UILabel,
                      let priceLabel = cell.viewWithTag(2) as? UILabel,
                      let imageView = cell.viewWithTag(3) as? UIImageView,
                      let itemInfo = itemInfo
                else {return cell}
                
                captLabel.text = itemInfo["capt"].stringValue
                priceLabel.text = itemInfo["pur_price"].stringValue + " руб."
                
                if let imageURLString = itemInfo["img"].string ,
                   let imageURL = URL(string: imageURLString) {
                    
                    imageView.sd_setImage(with: imageURL, completed: nil)
                    imageView.layer.cornerRadius = 12
                    
                }
                
            }else{
                
                let item = osnovnoeCellItemsArray[index - 1]
                
                if item.isCenaProdazhi{
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "cenaProdazhiCell", for: indexPath)
                    
                    guard let firstLabel = cell.viewWithTag(1) as? UILabel ,
                          let secondLabel = cell.viewWithTag(2) as? UILabel,
                          let _ = cell.viewWithTag(3) as? UIImageView,
                          let _ = cell.viewWithTag(4) as? UIImageView
                    else {return cell}
                    
                    firstLabel.text = item.firstLabelText
                    secondLabel.text = item.secondLabelText
                    
                    secondLabel.textColor = item.shouldSecondLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                    
                }else{
                    
                    if item.hasImageView{
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelOneImageCell", for: indexPath)
                        
                        guard let firstLabel = cell.viewWithTag(1) as? UILabel ,
                              let secondLabel = cell.viewWithTag(2) as? UILabel,
                              let _ = cell.viewWithTag(3) as? UIImageView
                        else {return cell}
                        
                        firstLabel.text = item.firstLabelText
                        secondLabel.text = item.secondLabelText
                        
                        secondLabel.textColor = item.shouldSecondLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                        
                    }else{
                        
                        cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
                        
                        guard let firstLabel = cell.viewWithTag(1) as? UILabel ,
                              let secondLabel = cell.viewWithTag(2) as? UILabel
                        else {return cell}
                        
                        firstLabel.text = item.firstLabelText
                        secondLabel.text = item.secondLabelText
                        
                        secondLabel.textColor = item.shouldSecondLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                        
                    }
                    
                }
                
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel,
                  let label2 = cell.viewWithTag(2) as? UILabel
            else {return cell}
            
            label1.text = index == 0 ? "Итого товары" : "Итого с клиентов"
            
            label2.text = (index == 0 ? "500" : "750") + " руб."
            
            label1.textColor = UIColor(named: "blackwhite")
            label2.textColor = UIColor(named: "blackwhite")
            
            label1.font = UIFont.boldSystemFont(ofSize: label1.font.pointSize)
            label2.font = UIFont.boldSystemFont(ofSize: label2.font.pointSize)
            
        case 3:
            
            let item = dopolnitelnoCellItemsArray[index]
            
            if item.isSwitch{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelSwitchCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel,
                      let switchh = cell.viewWithTag(2) as? UISwitch
                else {return cell}
                
                label.text = item.labelText
                
                if item.labelText == "Без замен"{
                    
                    switchh.isOn = bezZamenSwitch
                    
                    switchh.addTarget(self, action: #selector(bezZamenSwitchValueChanged(_:)), for: .valueChanged)
                    
                }else if item.labelText == "Оплачено"{
                    
                    switchh.isOn = oplachenoSwitch
                    
                    switchh.addTarget(self, action: #selector(oplachenoSwitchValueChanged(_:)), for: .valueChanged)
                    
                }else if item.labelText == "Проверка на брак"{
                    
                    switchh.isOn = proverkaNaBrakSwitch
                    
                    switchh.addTarget(self, action: #selector(proverkaNaBrakSwitchValueChanged(_:)), for: .valueChanged)
                    
                }
                
            }else if item.isComment{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel,
                      let secondLabel = cell.viewWithTag(2) as? UILabel ,
                      let _ = cell.viewWithTag(3) as? UIImageView,
                      let textView = cell.viewWithTag(4) as? UITextView
                else {return cell}
                
                label.text = item.labelText
                
                secondLabel.text = "23/150"
                
                textView.text = ""
                
                textView.backgroundColor = .clear
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel,
                      let label2 = cell.viewWithTag(2) as? UILabel
                else {return cell}
                
                label1.text = item.labelText
                label2.text = ""
                
                label1.textColor = item.shouldLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                
            }
            
        case 4:
            
            if !clients.isEmpty && index + 1 <= clients.count{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel ,
                      let countLabel = cell.viewWithTag(2) as? UILabel ,
                      let stepper = cell.viewWithTag(3) as? UIStepper,
                      let imageView = cell.viewWithTag(4) as? UIImageView ,
                      let imageViewButton = cell.viewWithTag(5) as? UIButtonWithInfo
                else {return cell}
                
                label.text = clients[index].name
                countLabel.text = String(clients[index].count)
                
                imageViewButton.info = String(index)
                
                imageViewButton.addTarget(self, action: #selector(closeClientInfoButtonPressed(_:)), for: .touchUpInside)
                
                return cell
                
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
            
            let item = klientiCellItemsArray[index - clients.count]
            
            guard let label1 = cell.viewWithTag(1) as? UILabel,
                  let label2 = cell.viewWithTag(2) as? UILabel
            else {return cell}
            
            label1.text = item.labelText
            label2.text = ""
            
            if item.labelText == "Выбрать закупку" ,
               let selectedZakupka = selectedZakupka{
                
                label1.text = "Закупка: \(selectedZakupka.name)"
                
            }
            
            //If there's more or less than one client selected , "Замена для..." should be gray and not be selectable
            if item.labelText == "Замена для..." && clients.count != 1 {
                label1.textColor = .systemGray
            }else{
                label1.textColor = item.shouldLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
            }
            
        default:
            return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 1{
            return "Основное"
        }else if section == 2{
            return "Итог"
        }else if section == 3{
            return "Дополнительно"
        }else if section == 4{
            return "Клиенты"
        }else{
            return ""
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        let index = indexPath.row
        
        if section == 4{
            
            if index <= clients.count - 1{
                
            }else{
                
                if klientiCellItemsArray[index - clients.count].labelText == "Выбрать закупку"{
                    
                    let vibratZakupkuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VibratZakupkuVC") as! VibratZakupkuViewController
                    
                    vibratZakupkuVC.purSelected = { [self] id , name in
                        
                        selectedZakupka = Zakupka(name: name, id: id)
                        
                        tableView.reloadData()
                        
                        print("Selected pur ID : \(id)")
                        
                    }
                    
                    let navVC = UINavigationController(rootViewController: vibratZakupkuVC)
                    
                    present(navVC, animated: true, completion: nil)
                    
                }else if klientiCellItemsArray[index - clients.count].labelText == "Выбрать клиента..."{
                    
                    let vibratKlientaVC = VibratKlientaViewController()
                    
                    vibratKlientaVC.clientSelected = { [self] name , id in
                        
                        clients.append(KlientiCellKlientItem(name: name, id: id, count: 1))
                        
                        tableView.reloadSections([4], with: .automatic)
                        
                    }
                    
                    let navVC = UINavigationController(rootViewController: vibratKlientaVC)
                    
                    present(navVC, animated: true, completion: nil)
                    
                }else if klientiCellItemsArray[index - clients.count].labelText == "Замена для..." && clients.count == 1{
                    
                    let zamenaDlyaVC = ZamenaDlyaTableViewController()
                    
                    zamenaDlyaVC.thisClientId = clients[0].id
                    
                    let navVC = UINavigationController(rootViewController: zamenaDlyaVC)
                    
                    present(navVC, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
}

//MARK: - PurchasesItemInfoDataManagerDelegate

extension DobavlenieVZakupkuViewController : PurchasesItemInfoDataManagerDelegate{
    
    func didGetPurchasesItemInfoData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            itemInfo = data["item_info"]
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingPurchasesItemInfoDataWithError(error: String) {
        print("Error with PurchasesItemInfoDataManager : \(error)")
    }
    
}

//MARK: - Structs

extension DobavlenieVZakupkuViewController {
    
    private struct OsnovnoeCellItem {
        
        var firstLabelText : String
        var secondLabelText : String
        var hasImageView : Bool
        var shouldSecondLabelTextBeBlue : Bool = true
        var isCenaProdazhi : Bool = false
        
    }
    
    private struct DopolnitelnoSwitchCellItem {
        
        var labelText : String
        var isComment : Bool = false
        var isSwitch : Bool = true
        var shouldLabelTextBeBlue : Bool = false
        
    }
    
    private struct KlientiCellItem{
        
        var labelText : String
        var shouldLabelTextBeBlue : Bool = true
        
    }
    
    private struct KlientiCellKlientItem{
        
        var name : String
        var id : String
        var count : Int
        
    }
    
    private struct Zakupka{
        
        var name : String
        var id : String
        
    }
    
}

//MARK: - Data Manipulation Methods

extension DobavlenieVZakupkuViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}
