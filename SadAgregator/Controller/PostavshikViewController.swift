//
//  PostavshikViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.12.2020.
//

import UIKit
import SwiftyJSON
import Cosmos
import SDWebImage

class PostavshikViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let key = UserDefaults.standard.string(forKey: "key")!
    
    var thisVendorId : String?
    
    lazy var vendorCardDataManager = VendorCardDataManager()
    
    var vendorData : JSON?
    
    var vendorPhone : String? {
        return vendorData?["phone"].stringValue
    }
    
    var vendorPlace : String? {
        return vendorData?["place"].stringValue
    }
    
    var vendorPop : String? {
        return vendorData?["pop"].stringValue
    }
    
    var vendorRegDate : String? {
        return vendorData?["reg_dt"].stringValue
    }
    
    var vendorVkLink : String?{
        return vendorData?["vk_link"].stringValue
    }
    
    var infoCells : [InfoCellObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vendorCardDataManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        if let safeId = thisVendorId{
            vendorCardDataManager.getVendorCardData(key: key, vendorId: safeId)
        }
        
    }
    
}

//MARK: - VendorCardDataManagerDelegate Stuff

extension PostavshikViewController : VendorCardDataManagerDelegate{
    
    func getVendorCardData(data: JSON) {
        
        DispatchQueue.main.async {
            
            self.vendorData = data
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingVendorCardDataWithError(error: String) {
        print("Error with VendorCardDataManager: \(error)")
    }
    
}

//MARK: - UITableView Stuff

extension PostavshikViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + getRowsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        guard let vendorData = self.vendorData else {return cell}
        
        var maxIndexForInfoCells = getRowsCount()
        
        switch indexPath.row {
        
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "postavshikTopCell", for: indexPath)
            
            setUpPostavshikTopCell(cell: cell, data: vendorData)
            
        case 1...maxIndexForInfoCells:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
            
            let indexForInfoCell = indexPath.row - 1
            
            setUpInfoCell(cell: cell, data: vendorData, index: indexForInfoCell)
            
        default:
            print("IndexPath out of switch")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getRowsCount() -> Int{
        
        var count = 0
        
        guard let phone = vendorPhone , let pop = vendorPop, let place = vendorPlace , let regDate = vendorRegDate , let vkLink = vendorVkLink else {return count}
        
        if phone != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "phone.fill")!, leftLabelText: "Номер телефона", rightLabelText: phone, shouldRightLabelBeBlue: false))
            
        }
        
        if pop != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "person.2.fill")!, leftLabelText: "Охват", rightLabelText: pop, shouldRightLabelBeBlue: false))
            
        }
        
        if place != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "paperplane.fill")!, leftLabelText: "Контейнер", rightLabelText: place, shouldRightLabelBeBlue: true))
            
        }
        
        if regDate != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "phone")!, leftLabelText: "Дата регистрации VK", rightLabelText: regDate, shouldRightLabelBeBlue: false))
            
        }
        
        if vkLink != "" {
            count += 1
            
            infoCells.append(InfoCellObject(image: UIImage(systemName: "phone")!, leftLabelText: "Страница", rightLabelText: vkLink, shouldRightLabelBeBlue: true))
            
        }
        
        print("Rows count: \(count)")
        
        return count
    }
    
    //MARK: - Cells SetUp
    
    func setUpPostavshikTopCell(cell : UITableViewCell, data : JSON) {
        //   let revsCountLabel = cell.viewWithTag(4) as? UILabel
        if let imageView = cell.viewWithTag(1) as? UIImageView,
           let ratingView = cell.viewWithTag(3) as? CosmosView,
           let nameLabel = cell.viewWithTag(2) as? UILabel,
           let peoplesImageView = cell.viewWithTag(4) as? UIImageView,
           let peoplesLabel = cell.viewWithTag(5) as? UILabel,
           let revImageView = cell.viewWithTag(6) as? UIImageView,
           let revLabel = cell.viewWithTag(7) as? UILabel
        {
            
            //Set up the name
            nameLabel.text = data["name"].stringValue
            
            //Set up peoples label, imageView
            let peoples = data["peoples"].stringValue
            
            if peoples == "0"{
                peoplesLabel.text = ""
                peoplesImageView.isHidden = true
            }else{
                peoplesLabel.text = peoples
                peoplesImageView.isHidden = false
            }
            
            let revsArray = data["revs_info"]["revs"].arrayValue
            let rev = revsArray.count
            
            if rev == 0{
                revLabel.text = ""
                revImageView.isHidden = true
            }else{
                revLabel.text = String(rev)
                revImageView.isHidden = false
            }
            
            //Set up image view
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
            imageView.sd_setImage(with: URL(string: data["img"].stringValue))
            
            //Set up the rating
            
            let rating = Double(data["revs_info"]["rate"].stringValue)!
            
            if rating != 0 {
                ratingView.rating = rating
            }else{
                
                ratingView.isHidden = true
                
                let label = UILabel(frame: ratingView.frame)
                cell.addSubview(label)
                label.font = .systemFont(ofSize: 14)
                
                label.text = "Отзывов ещё нет"
                
            }
            
        }
        
    }
    
    func setUpInfoCell(cell : UITableViewCell, data : JSON, index : Int){
        
        if let imageView = cell.viewWithTag(1) as? UIImageView,
           let leftLabel = cell.viewWithTag(2) as? UILabel ,
           let rightLabel = cell.viewWithTag(3) as? UILabel{
            
            let thisInfoCellObject = infoCells[index]
            
            imageView.image = thisInfoCellObject.image
            
            leftLabel.text = thisInfoCellObject.leftLabelText
            
            rightLabel.text = thisInfoCellObject.rightLabelText
            
            thisInfoCellObject.shouldRightLabelBeBlue ? (rightLabel.textColor = .systemBlue) : (rightLabel.textColor = #colorLiteral(red: 0.3666185141, green: 0.3666757345, blue: 0.3666060269, alpha: 1))
            
        }
        
    }
    
}

//MARK: - InfoCellObject

struct InfoCellObject {
    
    let image : UIImage
    let leftLabelText : String
    let rightLabelText : String
    let shouldRightLabelBeBlue : Bool
    
}
