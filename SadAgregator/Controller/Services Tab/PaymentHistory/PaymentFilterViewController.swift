//
//  PaymentFilterViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.03.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON

protocol PaymentFilterViewControllerDelegate {
    func didFilterStuff(source : Int? , opType : Int? , sumMin : Int? , sumMax : Int? , startDate : String? , endDate : String? , query : String)
}

class PaymentFilterViewController: UIViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var delegate : PaymentFilterViewControllerDelegate?
    
    var thisClientId : String?
    
    var maxSumFromApi : String?{
        didSet{
            
            guard let safeSum = maxSumFromApi else {return}
            
            upPrice = Int(safeSum)!
            
        }
    }
    var minDateFromApi : String?{
        didSet{
            minDate = minDateFromApi
        }
    }
    
    var opType : Int?
    var source : Int?
    var commentQuery : String?
    var lowPrice : Int? = 0
    var upPrice : Int?
    var maxPrice : Int?{
        didSet{
            guard let maxPrice = maxPrice else {return}
            
            lowPrice = Int(Double(maxPrice) * 0.2)
            upPrice = Int(Double(maxPrice) * 0.8)
            
        }
    }
    var minDate : String?
    var maxDate : String?
    var commentTextField : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key = "part_2_test"
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Фильтр"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(closeBarButtonTapped(_:)))
        
        enableHero()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableHero()
    }
    
}

//MARK: - Actions

extension PaymentFilterViewController{
    
    @IBAction func closeBarButtonTapped(_ sender : UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Functions

extension PaymentFilterViewController{
    
    func formatDate(_ date : Date , withDot : Bool = false) -> String{
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = withDot ? "dd.MM.yy" : "ddMMyy"
        
        //let date: NSDate? = dateFormatterGet.date(from: "2016-02-29 12:24:26") as NSDate?
        let formattedDate = dateFormatterGet.string(from: date)
        
        return formattedDate
        
    }
    
    func formatDate(_ date : String?) -> String?{
        
        guard date != nil else {return nil}
        
        var date = date!
        
        let firstIndex = date.index(date.startIndex, offsetBy: 2)
        let secondIndex = date.index(date.startIndex, offsetBy: 5)
        
        date.insert(".", at: firstIndex)
        date.insert(".", at: secondIndex)
        
        return date
        
    }
    
}

//MARK: - CollectionView

extension PaymentFilterViewController : UICollectionViewDelegate , UICollectionViewDataSource{
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            if sectionIndex == 0 || sectionIndex == 2 || sectionIndex == 4 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
                return section
                
            }else if sectionIndex == 6{
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .absolute(40))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
                
                return section
                
                
            }else if sectionIndex == 7{
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                                       heightDimension: .estimated(40))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 10, bottom: 0, trailing: 10)
                
                return section
               
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                                   heightDimension: .estimated(30))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.interGroupSpacing = 24
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 || section == 2 || section == 4 || section == 6 || section == 7{
            return 1
        }else{
            return 2
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        let section = indexPath.section
        
        if section == 0{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            setUpHeaderCell(with: "Тип операции", for: cell)
            
            
        }else if section == 1{
            
            switch indexPath.row {
            case 0:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Списание"
                
                cell.contentView.layer.cornerRadius = 8
                
                cell.contentView.backgroundColor = opType != indexPath.row ? UIColor(named: "gray") : .systemBlue
                label.textColor = opType != indexPath.row ? UIColor(named: "blackwhite") : .white
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "Пополнение"
                
                cell.contentView.layer.cornerRadius = 8
                
                cell.contentView.backgroundColor = opType != indexPath.row ? UIColor(named: "gray") : .systemBlue
                label.textColor = opType != indexPath.row ? UIColor(named: "blackwhite") : .white
                
            default:
                return cell
            }
            
        }else if section == 2{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            setUpHeaderCell(with: "Цена", for: cell)
            
            
        }else if section == 3{
            
            switch indexPath.row {
            case 0:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "от \(lowPrice ?? 0)"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "до \(upPrice ?? maxPrice ?? 0)"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            default:
                return cell
            }
            
        }else if section == 4{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            setUpHeaderCell(with: "Дата", for: cell)
            
        }else if section == 5{
            
            switch indexPath.row {
            case 0:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "с \(formatDate(minDate) ?? "")"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "по \(formatDate(maxDate) ?? formatDate(Date(), withDot: true))"
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            default:
                return cell
            }
            
        }else if section == 6{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textFIeldCell", for: indexPath)
            
            guard let bgView = cell.viewWithTag(1) , let textField = cell.viewWithTag(2) as? UITextField else {return cell}
            
            textField.placeholder = "Комментарий"
            
            if let commentQuery = commentQuery {
                textField.text = commentQuery
            }
            
            commentTextField = textField
            
            bgView.layer.cornerRadius = 6
           
        }else if section == 7{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
            
            label.text = "Показать операции"
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 17)
            
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.backgroundColor = .systemBlue
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 1{
            opType = indexPath.row
            collectionView.reloadItems(at: [IndexPath(row: 0, section: 1),IndexPath(row: 1, section: 1)])
        }else if section == 3{
            source = indexPath.row
            collectionView.reloadItems(at: [IndexPath(row: 0, section: 3),IndexPath(row: 1, section: 3)])
        }else if section == 8{
            
            if indexPath.row == 0{
                
                let datePickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerViewController
                
                datePickerVC.modalPresentationStyle = .custom
                datePickerVC.transitioningDelegate = self
                
                datePickerVC.dateSelected = { [self] date in
                    
                    let dateString = formatDate(date)
                    
                    minDate = dateString
                    
                    collectionView.reloadItems(at: [indexPath])
                    
                }
                
                self.present(datePickerVC, animated: true, completion: nil)
                
            }else{
                
                let datePickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerViewController
                
                datePickerVC.modalPresentationStyle = .custom
                datePickerVC.transitioningDelegate = self
                
                datePickerVC.dateSelected = { [self] date in
                    
                    let dateString = formatDate(date)
                    
                    maxDate = dateString
                    
                    collectionView.reloadItems(at: [indexPath])
                    
                }
                
                self.present(datePickerVC, animated: true, completion: nil)
                
            }
            
        }else if section == 10{
            
            if thisClientId != nil {
                ClientsFilterPayHistByClientCountDataManager(delegate: self).getClientsFilterPayHistByClientCountData(key: key, clientId: thisClientId!, source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: lowPrice == nil ? "" : String(lowPrice!), sumMax: upPrice == nil ? "" : String(upPrice!), startDate: minDate ?? "", endDate: maxDate ?? formatDate(Date()), query: commentTextField?.text ?? "")
            }else{
                ClientsFilterPayHistoryCountDataManager(delegate: self).getClientsFilterPayHistoryCountData(key: key, source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: lowPrice == nil ? "" : String(lowPrice!), sumMax: upPrice == nil ? "" : String(upPrice!), startDate: minDate ?? "", endDate: maxDate ?? formatDate(Date()), query: commentTextField?.text ?? "")
            }
            
        }
        
        print("Index path row : \(indexPath.row) , section : \(indexPath.section)")
        
    }
    
    //MARK: - Cells Setup
    
    func setUpHeaderCell(with header : String, for cell : UICollectionViewCell){
        
        guard let label = cell.viewWithTag(1) as? UILabel else {return}
        
        label.text = header
        
    }
    
    func setUpSingleLabelCell(with text : String, for cell : UICollectionViewCell){
        
        guard let label = cell.viewWithTag(1) as? UILabel else {return}
        
        label.text = text
        
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.backgroundColor = UIColor(named: "gray")
        
    }
    
    //MARK: - RangeSlider
    
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        let values = "(\(rangeSlider.lowerValue) \(rangeSlider.upperValue))"
        print("Range slider value changed: \(values)")
        
        guard let maxPrice = maxPrice else {return}
        
        let sliderLowValue = rangeSlider.lowerValue
        let sliderUpperValue = rangeSlider.upperValue
        
        let lowKoeficent = sliderLowValue / rangeSlider.maximumValue
        let upKoeficent = sliderUpperValue / rangeSlider.maximumValue
        
        let lowValue = Int(CGFloat(maxPrice) * lowKoeficent)
        let upValue = Int(CGFloat(maxPrice) * upKoeficent)
        
        self.lowPrice = lowValue
        self.upPrice = upValue
        
        collectionView.reloadItems(at: [IndexPath(row: 0, section: 5),IndexPath(row: 1, section: 5)])
        
    }
    
}

//MARK: - Data Manipulation Methods

extension PaymentFilterViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - TransitioningDelegate

extension PaymentFilterViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//MARK: - ClientsFilterPayHistoryCountDataManager

extension PaymentFilterViewController : ClientsFilterPayHistoryCountDataManagerDelegate{
    
    func didGetClientsFilterPayHistoryCountData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                if data["payments_count"].stringValue == "" || data["payments_count"].stringValue == "0"{
                    
                    showSimpleAlertWithOkButton(title: "Нет результатов", message: "Нет результатов поиска с введёнными параметрами")
                    
                }else{
                    
                    delegate?.didFilterStuff(source: source, opType: opType , sumMin: lowPrice, sumMax: upPrice, startDate: minDate, endDate: maxDate ?? formatDate(Date()), query: commentTextField?.text ?? "")
                    
                    dismiss(animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingClientsFilterPayHistoryCountDataWithError(error: String) {
        print("Error with ClientsFilterPayHistoryCountDataManager : \(error)")
    }
    
}

//MARK: - ClientsFilterPayHistByClientCountDataManager

extension PaymentFilterViewController : ClientsFilterPayHistByClientCountDataManagerDelegate {
    
    func didGetClientsFilterPayHistByClientCountData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                if data["payments_count"].stringValue == "" || data["payments_count"].stringValue == "0"{
                    
                    showSimpleAlertWithOkButton(title: "Нет результатов", message: "Нет результатов поиска с введёнными параметрами")
                    
                }else{
                    
                    delegate?.didFilterStuff(source: source, opType: opType , sumMin: lowPrice, sumMax: upPrice, startDate: minDate, endDate: maxDate ?? formatDate(Date()), query: commentTextField?.text ?? "")
                    
                    dismiss(animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    func didFailGettingClientsFilterPayHistByClientCountDataWithError(error: String) {
        print("Error with ClientsFilterPayHistByClientCountDataManager : \(error)")
    }
    
}
