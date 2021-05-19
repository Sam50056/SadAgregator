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
    var sizes : [String] = []
    
    private var osnovnoeCellItemsArray = [OsnovnoeCellItem]()
    private var dopolnitelnoCellItemsArray = [DopolnitelnoSwitchCellItem]()
    private var klientiCellItemsArray = [KlientiCellItem]()
    private var clients = [KlientiCellKlientItem]()
    
    private var selectedZakupka : Zakupka?
    
    private var purchasesItemInfoDataManager = PurchasesItemInfoDataManager()
    
    private var cenaProdazhi : Int?
    private var cenaZakupki : Int?
    
    private var itogoTovari : Int?{
        return tovarsCount * (cenaZakupki ?? 0)
    }
    private var itogoSKlientov : Int?{
        return tovarsCount * (cenaProdazhi ?? 0)
    }
    
    private var tovarsCount : Int{
        
        var count = 0
        
        for client in clients{
            
            count += client.count
            
        }
        
        return count
        
    }
    
    private var itemInfo : JSON?{
        didSet{
            
            guard let itemInfo = itemInfo else {return}
            
            cenaProdazhi = Int(itemInfo["sell_price"].stringValue)
            cenaZakupki = Int(itemInfo["pur_price"].stringValue)
            
            makeOsnovnoeCellItemsArray()
            
            if let zakupka = itemInfo["def_pur"]["name"].string{
                selectedZakupka = Zakupka(name: zakupka, id:  itemInfo["def_pur"]["id"].stringValue)
            }
            
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
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Загрузить фото посылки", isComment: false, isSwitch: false, shouldLabelTextBeBlue: true), at: 2)
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Загрузить фото чека", isComment: false, isSwitch: false, shouldLabelTextBeBlue: true), at: 3)
                
                tableView.insertRows(at: [IndexPath(row: 2, section: 3),IndexPath(row: 3, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }else{
                
                tableView.beginUpdates()
                
                dopolnitelnoCellItemsArray.remove(at: 3)
                dopolnitelnoCellItemsArray.remove(at: 2)
                
                tableView.deleteRows(at: [IndexPath(row: 2, section: 3),IndexPath(row: 3, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }
            
        }
    }
    private var proverkaNaBrakSwitch : Bool = false{
        didSet{
            
        }
    }
    
    private var comment : String?
    private var myComment : String?
    
    private var commentTextView : UITextView?
    private var myCommentTextView : UITextView?
    private var commentSymbolsCount = 0
    private var myCommentSymbolsCount = 0
    private var commentCountLabel : UILabel?
    private var myCommentCountLabel : UILabel?
    
    private var replaceTovarId : String?
    
    
    lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    lazy var photoSavedDataManager = PhotoSavedDataManager()
    
    private var checkImageId : String? //Id чека
    private var parselImageId : String? //Id посылки
    private var isSendingCheck : Bool = true
    private var checkImageURL : URL?{
        didSet{
            
            if checkImageURL != nil {
                
                guard oplachenoSwitch else {return}
                
                tableView.beginUpdates()
                
                dopolnitelnoCellItemsArray.remove(at: 3)
                
                tableView.deleteRows(at: [IndexPath(row: 3, section: 3)], with: .automatic)
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Фото чека", isComment: false, isSwitch: false, isPhotoCell: true, shouldLabelTextBeBlue: false), at: 3)
                
                tableView.insertRows(at: [IndexPath(row: 3, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }else{
                
                guard oplachenoSwitch else {return}
                
                tableView.beginUpdates()
                
                dopolnitelnoCellItemsArray.remove(at: 3)
                
                tableView.deleteRows(at: [IndexPath(row: 3, section: 3)], with: .automatic)
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Загрузить фото чека", isComment: false, isSwitch: false, shouldLabelTextBeBlue: true), at: 3)
                
                tableView.insertRows(at: [IndexPath(row: 3, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }
            
        }
    }
    private var parselImageURL : URL?{
        didSet{
            
            if parselImageURL != nil {
                
                guard oplachenoSwitch else {return}
                
                tableView.beginUpdates()
                
                dopolnitelnoCellItemsArray.remove(at: 2)
                
                tableView.deleteRows(at: [IndexPath(row: 2, section: 3)], with: .automatic)
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Фото посылки", isComment: false, isSwitch: false, isPhotoCell: true, shouldLabelTextBeBlue: false), at: 2)
                
                tableView.insertRows(at: [IndexPath(row: 2, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }else {
                
                guard oplachenoSwitch else {return}
                
                tableView.beginUpdates()
                
                dopolnitelnoCellItemsArray.remove(at: 2)
                
                tableView.deleteRows(at: [IndexPath(row: 2, section: 3)], with: .automatic)
                
                dopolnitelnoCellItemsArray.insert(DopolnitelnoSwitchCellItem(labelText: "Загрузить фото посылки", isComment: false, isSwitch: false, shouldLabelTextBeBlue: true), at: 2)
                
                tableView.insertRows(at: [IndexPath(row: 2, section: 3)], with: .automatic)
                
                tableView.endUpdates()
                
            }
            
        }
    }
    
    private var hasSentCheckPhoto = false
    private var hasSentParselPhoto = false
    
    var dobavlenoVZakupku : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserData()
        key = "part_2_test"
        
        purchasesItemInfoDataManager.delegate = self
        newPhotoPlaceDataManager.delegate = self
        
        dopolnitelnoCellItemsArray = [
            DopolnitelnoSwitchCellItem(labelText: "Без замен", isSwitch: true),
            DopolnitelnoSwitchCellItem(labelText: "Оплачено", isSwitch: true),
            DopolnitelnoSwitchCellItem(labelText: "Проверка на брак", isSwitch: true),
            DopolnitelnoSwitchCellItem(labelText: "Комментарий", isComment: true, isSwitch: false, shouldLabelTextBeBlue: false),
            DopolnitelnoSwitchCellItem(labelText: "Свой комментарий", isComment: true, isSwitch: false, shouldLabelTextBeBlue: false)
        ]
        
        sizes.append("Другой размер")
        
        makeKlientiCellItemsArray()
        
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(gotovoTapped(_:)))
        
    }
    
}

//MARK: - Functions

extension DobavlenieVZakupkuViewController {
    
    func makeOsnovnoeCellItemsArray() {
        
        guard let _ = itemInfo else {return}
        
        var newArray = [OsnovnoeCellItem]()
        
        if let price = cenaZakupki{
            newArray.append(OsnovnoeCellItem(firstLabelText: "Закупка", secondLabelText: String(price) + " руб.", hasImageView: true))
        }
        
        if let cenaProdazhi = cenaProdazhi {
            newArray.append(OsnovnoeCellItem(firstLabelText: "Цена продажи", secondLabelText: String(cenaProdazhi) + " руб.", hasImageView: true,isCenaProdazhi: true))
        }
        
        newArray.append(OsnovnoeCellItem(firstLabelText: "Размер", secondLabelText: thisSize ?? "Нет размера", hasImageView: false))
        
        osnovnoeCellItemsArray = newArray
        
        tableView.reloadData()
        
    }
    
    func makeKlientiCellItemsArray() {
        
        klientiCellItemsArray = [
            KlientiCellItem(labelText: "Выбрать клиента..."),
            KlientiCellItem(labelText: replaceTovarId == nil ? "Замена для..." : "Замена выбрана"),
            KlientiCellItem(labelText: selectedZakupka == nil ? "Выбрать закупку" : "Закупка: \(selectedZakupka!.name)")
        ]
        
    }
    
    func sendPhotosToServer(forCheck : Bool){
        
        isSendingCheck = forCheck
        newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
        
    }
    
}

//MARK: - Actions

extension DobavlenieVZakupkuViewController {
    
    @IBAction func otmenaTapped(_ sender : Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gotovoTapped(_ sender : Any?){
        
        guard !clients.isEmpty else {
            showSimpleAlertWithOkButton(title: "Ошибка", message: "Нет добавленных клиентов")
            return
        }
        
        guard let thisImageId = thisImageId else {return}
        
        if checkImageURL != nil && !hasSentCheckPhoto{
            sendPhotosToServer(forCheck: true)
            return
        }
        
        if parselImageURL != nil && !hasSentParselPhoto{
            sendPhotosToServer(forCheck: false)
            return
        }
        
        //Making client string from clients array
        var clientsString = ""
        for i in 0..<clients.count{
            
            let client = clients[i]
            
            if i == clients.count - 1{
                clientsString.append("|\(client.id)-\(client.count)|")
            }else{
                clientsString.append("|\(client.id)-\(client.count)")
            }
        }
        
        PurchasesAddItemDataManager(delegate: self).getPurchasesAddItemData(key: key, imgId: thisImageId, zakupkaId: selectedZakupka?.id ?? "" , size: thisSize ?? "", purPrice: cenaZakupki == nil ? "" : String(cenaZakupki!), sellPrice: cenaProdazhi == nil ? "" : String(cenaProdazhi!), withoutReplace: bezZamenSwitch ? "1" : "0", paid: oplachenoSwitch ? "1" : "0", checkDefect: proverkaNaBrakSwitch ? "1" : "0", checkImgId: checkImageId ?? "", parselImgId: parselImageId ?? "", clients: clientsString, replaceTovarId: replaceTovarId ?? "")
        
    }
    
    func dlyaSebyaPressed() {
        
        guard let thisImageId = thisImageId else {return}
        
        PurchasesAddItemForYourselfDataManager(delegate: self).getPurchasesAddItemForYourselfData(key: key , imgId: thisImageId)
        
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
    
    @IBAction func removeZamenaPressed(_ sender :Any){
        
        replaceTovarId = nil
        makeKlientiCellItemsArray()
        tableView.reloadData()
        
    }
    
    @IBAction func gearButtonPressed(_ sender : Any){
        
        let cenovieDiapazoniVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CenovieDiapazoniVC") as! CenovieDiapazoniViewController
        
        cenovieDiapazoniVC.doneChanges = { [self] in
            
            PurchasesSellPriceRecalcDataManager(delegate: self).getPurchasesSellPriceRecalcData(key: key, buyPrice: String(cenaZakupki ?? 0), imgId: thisImageId!)
            
        }
        
        navigationController?.pushViewController(cenovieDiapazoniVC, animated: true)
        
    }
    
    @IBAction func removeCheckImage(_ sender : Any){
        checkImageURL = nil
    }
    
    @IBAction func removeParselImage(_ sender : Any){
        parselImageURL = nil
    }
    
}

//MARK: - TextView

extension DobavlenieVZakupkuViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == commentTextView{
            commentCountLabel?.text = "\(textView.text.count)/150"
            commentSymbolsCount = textView.text.count
            comment = textView.text
        }else{
            myCommentCountLabel?.text = "\(textView.text.count)/150"
            myCommentSymbolsCount = textView.text.count
            myComment = textView.text
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 150
    }
}

//MARK: - UIStepper

extension DobavlenieVZakupkuViewController {
    
    @IBAction func clientStepperValueChanged(_ sender : UIStepperWithInfo){
        
        //        print("New Value = \(sender.value)")
        
        guard let index = Int(sender.info) else {return}
        
        clients[index].count = Int(sender.value)
        
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
                          let _ = cell.viewWithTag(4) as? UIImageView,
                          let gearButton = cell.viewWithTag(5) as? UIButton
                    else {return cell}
                    
                    firstLabel.text = item.firstLabelText
                    secondLabel.text = item.secondLabelText
                    
                    secondLabel.textColor = item.shouldSecondLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                    
                    gearButton.addTarget(self, action: #selector(gearButtonPressed(_:)), for: .touchUpInside)
                    
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
                        firstLabel.textColor = UIColor(named: "blackwhite")
                        
                        firstLabel.font = UIFont.systemFont(ofSize: 17)
                        secondLabel.font = UIFont.systemFont(ofSize: 17)
                        
                    }
                    
                }
                
            }
            
        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel,
                  let label2 = cell.viewWithTag(2) as? UILabel
            else {return cell}
            
            label1.text = index == 0 ? "Итого товары" : "Итого с клиентов"
            
            label2.text = (index == 0 ? "\(itogoTovari ?? 0)" : "\(itogoSKlientov ?? 0)") + " руб."
            
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
                
                textView.delegate = self
                
                textView.text = ""
                
                if item.labelText == "Комментарий"{
                    secondLabel.text = "\(commentSymbolsCount)/150"
                    commentCountLabel = secondLabel
                    commentTextView = textView
                    textView.text = comment
                }else{
                    secondLabel.text = "\(myCommentSymbolsCount)/150"
                    myCommentCountLabel = secondLabel
                    myCommentTextView = textView
                    textView.text = myComment
                }
                
                textView.backgroundColor = .clear
                
            }else if item.isPhotoCell{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "imageLabelButtonCell", for: indexPath)
                
                guard let imageView = cell.viewWithTag(1) as? UIImageView ,
                   let label = cell.viewWithTag(2) as? UILabel,
                   let button = cell.viewWithTag(4) as? UIButton else {return cell}
                
                label.text = item.labelText
                imageView.layer.cornerRadius = 6
                
                button.removeTarget(self, action: nil, for: .touchUpInside)
                
                if item.labelText == "Фото чека"{
                    
                    let checkImage = UIImage(data: try! Data(contentsOf: checkImageURL!))
                    
                    imageView.image = checkImage
                    
                    button.addTarget(self, action: #selector(removeCheckImage(_:)), for: .touchUpInside)
                    
                }else if item.labelText == "Фото посылки" {
                    
                    let parselImage = UIImage(data: try! Data(contentsOf: parselImageURL!))
                    
                    imageView.image = parselImage
                    
                    button.addTarget(self, action: #selector(removeParselImage(_:)), for: .touchUpInside)
                    
                }
                
            }else{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel,
                      let label2 = cell.viewWithTag(2) as? UILabel
                else {return cell}
                
                label1.text = item.labelText
                label2.text = ""
                
                label1.textColor = item.shouldLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                
                label1.font = UIFont.systemFont(ofSize: 17)
                label2.font = UIFont.systemFont(ofSize: 17)
                
            }
            
        case 4:
            
            if !clients.isEmpty && index + 1 <= clients.count{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel ,
                      let countLabel = cell.viewWithTag(2) as? UILabel ,
                      let stepper = cell.viewWithTag(3) as? UIStepperWithInfo,
                      let _ = cell.viewWithTag(4) as? UIImageView ,
                      let imageViewButton = cell.viewWithTag(5) as? UIButtonWithInfo
                else {return cell}
                
                label.text = clients[index].name
                countLabel.text = String(clients[index].count)
                
                imageViewButton.info = String(index)
                
                imageViewButton.addTarget(self, action: #selector(closeClientInfoButtonPressed(_:)), for: .touchUpInside)
                
                stepper.value = Double(clients[index].count)
                
                stepper.stepValue = 1
                
                stepper.minimumValue = 1
                
                stepper.maximumValue = .infinity
                
                stepper.info = "\(index)"
                
                stepper.addTarget(self, action: #selector(clientStepperValueChanged(_:)), for: .valueChanged)
                
                return cell
                
            }
            
            let item = klientiCellItemsArray[index - clients.count]
            
            if item.labelText == "Замена для..." || item.labelText == "Замена выбрана"{
                
                cell = tableView.dequeueReusableCell(withIdentifier: "labelOneButtonCell", for: indexPath)
                
                guard let label1 = cell.viewWithTag(1) as? UILabel,
                      let imageView = cell.viewWithTag(2) as? UIImageView,
                      let button = cell.viewWithTag(3) as? UIButtonWithInfo
                else {return cell}
                
                label1.text = item.labelText
                
                if replaceTovarId == nil {
                    imageView.isHidden = true
                    button.isHidden = true
                }else{
                    imageView.isHidden = false
                    button.isHidden = false
                }
                
                button.addTarget(self, action: #selector(removeZamenaPressed(_:)), for: .touchUpInside)
                
                //If there's more or less than one client selected , "Замена для..." should be gray and not be selectable
                if clients.count != 1 {
                    label1.textColor = .systemGray
                }else{
                    label1.textColor = item.shouldLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
                }
                
                label1.font = UIFont.systemFont(ofSize: 17)
                
                return cell
                
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: "twoLabelCell", for: indexPath)
            
            guard let label1 = cell.viewWithTag(1) as? UILabel,
                  let label2 = cell.viewWithTag(2) as? UILabel
            else {return cell}
            
            label1.text = item.labelText
            label2.text = ""
            
            label1.font = UIFont.systemFont(ofSize: 17)
            label2.font = UIFont.systemFont(ofSize: 17)
            
            label1.textColor = item.shouldLabelTextBeBlue ? .systemBlue : UIColor(named: "blackwhite")
            
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
        
        if section == 0{
            
            dlyaSebyaPressed()
            
        }else if section == 1, index != 0{
            
            if osnovnoeCellItemsArray[index - 1].firstLabelText == "Закупка"{
                
                let alertController = UIAlertController(title: "Изменить закупочную цену?", message: nil, preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "Да", style: .default) { [self] _ in
                    
                    let secondAlertController = UIAlertController(title: "Цена закупки", message: nil, preferredStyle: .alert)
                    
                    secondAlertController.addTextField { field in
                        
                        field.placeholder = "500 руб."
                        
                        field.keyboardType = .numberPad
                        
                    }
                    
                    secondAlertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { _ in
                        
                        if let newCena = Int(secondAlertController.textFields![0].text ?? ""){
                            
                            PurchasesSellPriceRecalcDataManager(delegate: self).getPurchasesSellPriceRecalcData(key: key, buyPrice: String(newCena), imgId: thisImageId!)
                            
                            cenaZakupki = newCena
                            
                            makeOsnovnoeCellItemsArray()
                            
                        }
                        
                    }))
                    
                    present(secondAlertController, animated: true, completion: nil)
                    
                }
                
                let noAction = UIAlertAction(title: "Нет", style: .cancel) { _ in
                    alertController.dismiss(animated: true, completion: nil)
                }
                
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                
                present(alertController, animated: true, completion: nil)
                
            }else if osnovnoeCellItemsArray[index - 1].firstLabelText == "Размер" && !sizes.isEmpty{
                
                let alertControlelr = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                for size in sizes {
                    
                    let action = UIAlertAction(title: size, style: .default) { [self] _ in
                        
                        if size == "Другой размер"{
                            
                            let sizeAlertController = UIAlertController(title: "Введите размер", message: nil, preferredStyle: .alert)
                            
                            sizeAlertController.addTextField { textField in
                                textField.placeholder = "Размер"
                            }
                            
                            sizeAlertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { _ in
                                guard let newSize = sizeAlertController.textFields?[0].text else {return}
                                sizes.insert(newSize, at: sizes.count - 1)
                                thisSize = newSize
                                makeOsnovnoeCellItemsArray()
                            }))
                            
                            sizeAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
                                sizeAlertController.dismiss(animated: true, completion: nil)
                            }))
                            
                            present(sizeAlertController, animated: true, completion: nil)
                            
                        }else{
                            thisSize = size
                            makeOsnovnoeCellItemsArray()
                        }
                    }
                    
                    alertControlelr.addAction(action)
                    
                }
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _IOFBF in
                    alertControlelr.dismiss(animated: true, completion: nil)
                }
                
                alertControlelr.addAction(cancelAction)
                
                present(alertControlelr, animated: true, completion: nil)
                
            }
            
        }else if section == 3{
            
            if dopolnitelnoCellItemsArray[index].labelText == "Загрузить фото посылки"{
                
                parselImageId = nil
                //                parselImageURL = nil
                
                isSendingCheck = false
                
                showImagePickerController(sourceType: .photoLibrary)
                
            }else if dopolnitelnoCellItemsArray[index].labelText == "Загрузить фото чека"{
                
                checkImageId = nil
                //                checkImageURL = nil
                
                isSendingCheck = true
                
                showImagePickerController(sourceType: .photoLibrary)
                
            }
            
        }else if section == 4{
            
            if index <= clients.count - 1{
                
            }else{
                
                if klientiCellItemsArray[index - clients.count].labelText == "Выбрать закупку"{
                    
                    let vibratZakupkuVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VibratZakupkuVC") as! VibratZakupkuViewController
                    
                    vibratZakupkuVC.purSelected = { [self] id , name in
                        
                        selectedZakupka = Zakupka(name: name, id: id)
                        
                        makeKlientiCellItemsArray()
                        
                        tableView.reloadData()
                        
                        print("Selected pur ID : \(id)")
                        
                    }
                    
                    let navVC = UINavigationController(rootViewController: vibratZakupkuVC)
                    
                    present(navVC, animated: true, completion: nil)
                    
                }else if klientiCellItemsArray[index - clients.count].labelText == "Выбрать клиента..."{
                    
                    let vibratKlientaVC = VibratKlientaViewController()
                    
                    vibratKlientaVC.selectedClientsIds = clients.map({ item in
                        return item.id
                    })
                    
                    vibratKlientaVC.clientSelected = { [self] name , id in
                        
                        clients.append(KlientiCellKlientItem(name: name, id: id, count: 1))
                        
                        tableView.reloadData()
                        
                    }
                    
                    let navVC = UINavigationController(rootViewController: vibratKlientaVC)
                    
                    present(navVC, animated: true, completion: nil)
                    
                }else if klientiCellItemsArray[index - clients.count].labelText == "Замена для..." && clients.count == 1{
                    
                    let zamenaDlyaVC = ZamenaDlyaTableViewController()
                    
                    zamenaDlyaVC.thisClientId = clients[0].id
                    
                    zamenaDlyaVC.tovarSelected = { [self] pid in
                        print("Selected tovar pid : \(pid)")
                        replaceTovarId = pid
                        makeKlientiCellItemsArray()
                        tableView.reloadData()
                    }
                    
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

//MARK: - PurchasesSellPriceRecalcDataManagerDelegate

extension DobavlenieVZakupkuViewController : PurchasesSellPriceRecalcDataManagerDelegate{
    
    func didGetPurchasesSellPriceRecalcData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                cenaProdazhi = data["sell_price"].intValue
                
                makeOsnovnoeCellItemsArray()
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesSellPriceRecalcDataWithError(error: String) {
        print("Error with PurchasesSellPriceRecalcDataManager : \(error)")
    }
    
}

//MARK: - PurchasesAddItemDataManager

extension DobavlenieVZakupkuViewController : PurchasesAddItemDataManagerDelegate{
    
    func didGetPurchasesAddItemData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                dismiss(animated: true, completion: nil)
                
                dobavlenoVZakupku?()
                
            }else{
                
                showSimpleAlertWithOkButton(title: "Ошибка", message: data["msg"].string)
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesAddItemDataWithError(error: String) {
        print("Error with PurchasesAddItemDataManager : \(error)")
    }
    
}

//MARK: - PurchasesAddItemForYourselfDataManagerDelegate

extension DobavlenieVZakupkuViewController : PurchasesAddItemForYourselfDataManagerDelegate{
    
    func didGetPurchasesAddItemForYourselfData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                dismiss(animated: true, completion: nil)
                
                dobavlenoVZakupku?()
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesAddItemForYourselfDataWithError(error: String) {
        print("Error with PurchasesAddItemForYourselfDataManager : \(error)")
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
        var isPhotoCell : Bool = false
        var shouldLabelTextBeBlue : Bool = false
        
    }
    
    private struct KlientiCellItem{
        
        var labelText : String
        var shouldLabelTextBeBlue : Bool = true
        
    }
    
    struct KlientiCellKlientItem{
        
        var name : String
        var id : String
        var count : Int
        
    }
    
    private struct Zakupka{
        
        var name : String
        var id : String
        
    }
    
}

//MARK: - UIImagePickerControllerDelegate

extension DobavlenieVZakupkuViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let safeUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            
            //            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
            isSendingCheck ? (checkImageURL = safeUrl) : (parselImageURL = safeUrl)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


//MARK: - NewPhotoPlaceDataManagerDelegate

extension DobavlenieVZakupkuViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let url = "\(data["post_to"].stringValue)/store?file_name=\(data["file_name"].stringValue)"
            
            print("URL FOR SENDING THE FILE: \(url)")
            
            if isSendingCheck{
                guard let _ = checkImageURL else {return}
            }else{
                guard let _ = parselImageURL else {return}
            }
            
            sendFileToServer(from: isSendingCheck ? checkImageURL! : parselImageURL!, to: url)
            
            let imageId = data["image_id"].stringValue
            
            let imageLinkWithPortAndWithoutFile = "\(data["post_to"].stringValue)"
            let splitIndex = imageLinkWithPortAndWithoutFile.lastIndex(of: ":")!
            let imageLink = "\(String(imageLinkWithPortAndWithoutFile[imageLinkWithPortAndWithoutFile.startIndex ..< splitIndex]))\(data["file_name"].stringValue)"
            
            print("Image Link: \(imageLink)")
            
            isSendingCheck ? (checkImageId = imageId) : (parselImageId = imageId)
            
        }
        
    }
    
    func didFailGettingNewPhotoPlaceDataWithError(error: String) {
        print("Error with NewPhotoPlaceDataManager: \(error)")
    }
    
}

//MARK: - File Sending

extension DobavlenieVZakupkuViewController{
    
    func sendFileToServer(from fromUrl : URL, to toUrl : String){
        
        print("import result : \(fromUrl)")
        
        guard let toUrl = URL(string: toUrl) else {return}
        
        print("To URL: \(toUrl)")
        
        do{
            
            let data = try Data(contentsOf: fromUrl)
            
            let image = UIImage(data: data)!
            
            let imageData = image.jpegData(compressionQuality: 0.5)
            
            var request = URLRequest(url: toUrl)
            
            request.httpMethod = "POST"
            request.setValue("text/plane", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
            
            let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
                
                if error != nil {
                    print("Error sending file: \(error!.localizedDescription)")
                    return
                }
                
                guard let data = data else {return}
                
                let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
                
                print("Answer : \(json)")
                
                DispatchQueue.main.async { [self] in
                    
                    print("Got \(isSendingCheck ? "check sent" : "parsel sent") to server")
                    
                    photoSavedDataManager.getPhotoSavedData(key: key, photoId: (isSendingCheck ? checkImageId! : parselImageId!)) { data, error in
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        guard let data = data else {return}
                        
                        if data["result"].intValue == 1{
                            
                            print("\(isSendingCheck ? "Check" : "Parsel") image successfuly saved to server")
                            
                            DispatchQueue.main.async { [self] in
                                
                                if isSendingCheck {
                                    hasSentCheckPhoto = true
                                    gotovoTapped(nil)
                                }else{
                                    hasSentParselPhoto = true
                                    gotovoTapped(nil)
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
                
            }
            
            task.resume()
            
        }catch{
            print(error)
        }
        
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
