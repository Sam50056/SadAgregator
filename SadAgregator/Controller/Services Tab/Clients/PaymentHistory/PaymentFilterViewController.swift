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
    
    var minDateFromApi : String?{
        didSet{
            oldMinDate = minDateFromApi
            minDate = minDateFromApi
        }
    }
    
    var clientsGetPaymentsFilterDataManager = ClientsGetPaymentsFilterDataManager()
    
    var opType : Int? {//Тип операции
        didSet{
            guard collectionView != nil else {return}
            collectionView.reloadData()
        }
    }
    var source : Int? //Источник операции
    var commentQuery : String?
    var lowPrice : Int? {
        didSet{
            guard collectionView != nil else {return}
            collectionView.reloadData()
        }
    }
    var upPrice : Int? {//Max price set
        didSet{
            guard collectionView != nil else {return}
            collectionView.reloadData()
        }
    }
    var maxPrice : Int? //Max price from api in paymentsHist..VC
    var minDate : String?{
        didSet{
            guard collectionView != nil else {return}
            collectionView.reloadData()
        }
    }
    var maxDate : String?{
        didSet{
            guard collectionView != nil else {return}
            collectionView.reloadData()
        }
    }
    
    var oldOpType : Int?
    var oldLowPrice : Int?
    var oldUpPrice : Int?
    var oldMinDate : String?
    var oldMaxDate : String?
    
    
    private var resultsCount : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        key = getKey()!
        
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fillTheFields()
        
        //        if opType != nil || commentQuery != nil || lowPrice != nil || upPrice != nil || minDate != nil || maxDate != nil {
        //            checkForResults()
        //        }
        
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
    
    @objc func textFieldEditingChanged(_ sender : UITextField){
        
        if sender.tag == 2{
            
            lowPrice = Int(sender.text ?? "")
            
        }else if sender.tag == 4 {
            
            upPrice = Int(sender.text ?? "")
            
        }
        
        checkForResults()
        
    }
    
    @objc func commentTextFieldEditingChanged(_ sender : UITextField){
        
        commentQuery = sender.text ?? ""
        
        checkForResults()
        
    }
    
    @IBAction func pokazatOperaciiButtonPressed(_ sender : UIButton){
        
        guard let _ = resultsCount else {return}
        
        //        let commentText = (collectionView.cellForItem(at: IndexPath(row: 0, section: 6))?.viewWithTag(2) as! UITextField).text ?? ""
        
        delegate?.didFilterStuff(source: source, opType: opType , sumMin: lowPrice, sumMax: upPrice, startDate: minDate, endDate: maxDate ?? formatDate(Date()), query: commentQuery ?? "")
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - Functions

extension PaymentFilterViewController{
    
    func checkForResults(){
        
        //        let commentText = (collectionView.cellForItem(at: IndexPath(row: 0, section: 6))?.viewWithTag(2) as? UITextField)?.text ?? ""
        
        if thisClientId != nil {
            ClientsFilterPayHistByClientCountDataManager(delegate: self).getClientsFilterPayHistByClientCountData(key: key, clientId: thisClientId!, source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: lowPrice == nil ? "" : String(lowPrice!), sumMax: upPrice == nil ? "" : String(upPrice!), startDate: minDate ?? "", endDate: maxDate ?? formatDate(Date()), query: commentQuery ?? "")
        }else{
            ClientsFilterPayHistoryCountDataManager(delegate: self).getClientsFilterPayHistoryCountData(key: key, source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: lowPrice == nil ? "" : String(lowPrice!), sumMax: upPrice == nil ? "" : String(upPrice!), startDate: minDate ?? "", endDate: maxDate ?? formatDate(Date()), query: commentQuery ?? "")
        }
        
    }
    
    func fillTheFields(){
        
        clientsGetPaymentsFilterDataManager.getClientsGetPaymentsFilterData(key: key, client: thisClientId ?? "") { data, error in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.oldOpType = self?.opType ?? 0// Op type doesn't come from this api that's why we just save it from paymentHist VC
                
                if let error = error {
                    print("Error with ClientsGetPaymentsFilterDataManager : \(error)")
                    self?.checkForResults()
                    return
                }
                
                if data!["result"].intValue == 1{
                    
                    let filter = data!["filter"]
                    
                    self?.upPrice = Int(filter["max_sum"].stringValue)
                    self?.lowPrice = Int(filter["min_sum"].stringValue)
                    
                    self?.oldUpPrice = self?.upPrice
                    self?.oldLowPrice = self?.lowPrice
                    self?.oldMaxDate = self?.maxDate
                    self?.minDate = self?.minDate
                    
                    self?.minDate = filter["min_dt"].stringValue != "" ? filter["min_dt"].stringValue : nil
                    
                    self?.collectionView.reloadData()
                    self?.checkForResults()
                    
                }
                
            }
            
        }
        
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
            
            if sectionIndex == 0 || sectionIndex == 2 || sectionIndex == 3 || sectionIndex == 4 {
                
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
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .estimated(55))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
                
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
        
        if section == 0 || section == 2 || section == 3 || section == 4 || section == 6 || section == 7{
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
            
            setUpHeaderCell(with: "Сумма", for: cell)
            
            
        }else if section == 3{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pricesCell", for: indexPath)
            
            if let minView = cell.viewWithTag(1),
               let maxView = cell.viewWithTag(3),
               let minTextField = cell.viewWithTag(2) as? UITextField,
               let maxTextField = cell.viewWithTag(4) as? UITextField{
                
                minView.layer.cornerRadius = 10
                maxView.layer.cornerRadius = 10
                
                minTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingDidEnd)
                maxTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingDidEnd)
                
                minTextField.text = lowPrice == nil ? "0" : String(lowPrice!)
                maxTextField.text = upPrice == nil ? maxPrice == nil ? "" : String(maxPrice!) : String(upPrice!)
                
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
                
                label.textColor = UIColor(named: "blackwhite")
                
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.backgroundColor = UIColor(named: "gray")
                
            case 1:
                
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "singleLabelCell", for: indexPath)
                
                guard let label = cell.viewWithTag(1) as? UILabel else {return cell}
                
                label.text = "по \(formatDate(maxDate) ?? formatDate(Date(), withDot: true))"
                
                label.textColor = UIColor(named: "blackwhite")
                
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
            
            textField.addTarget(self, action: #selector(commentTextFieldEditingChanged(_:)), for: .editingChanged)
            
            bgView.layer.cornerRadius = 6
            
        }else if section == 7{
            
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pokazatOperaciiButtonCell", for: indexPath)
            
            guard let button = cell.viewWithTag(1) as? UIButton else {return cell}
            
            button.setTitle("Показать операции" + (resultsCount == nil ? "" : " (\(resultsCount!))"), for: .normal)
            
            button.layer.cornerRadius = 8
            
            button.addTarget(self, action: #selector(pokazatOperaciiButtonPressed(_:)), for: .touchUpInside)
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        
        if section == 1{
            opType = indexPath.row
            collectionView.reloadItems(at: [IndexPath(row: 0, section: 1),IndexPath(row: 1, section: 1)])
        }else if section == 5{
            
            if indexPath.row == 0{
                
                let datePickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerViewController
                
                datePickerVC.modalPresentationStyle = .custom
                datePickerVC.transitioningDelegate = self
                
                datePickerVC.dateSelected = { [self] date in
                    
                    let dateString = formatDate(date)
                    
                    minDate = dateString
                    
                    collectionView.reloadItems(at: [indexPath])
                    
                    checkForResults()
                    
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
                    
                    checkForResults()
                    
                }
                
                self.present(datePickerVC, animated: true, completion: nil)
                
            }
            
        }
        
        checkForResults()
        
        print("Index path row : \(indexPath.row) , section : \(indexPath.section)")
        
    }
    
    //MARK: - Cells Setup
    
    func setUpHeaderCell(with header : String, for cell : UICollectionViewCell){
        
        guard let label = cell.viewWithTag(1) as? UILabel,
              let button = cell.viewWithTag(2) as? UIButton
        else {return}
        
        label.text = header
        
        if header == "Тип операции"{
            
            button.isHidden = opType == oldOpType
            
        }else if header == "Сумма"{
            
            if lowPrice != oldLowPrice || upPrice != oldUpPrice{
                button.isHidden = false
            }else{
                button.isHidden = true
            }
            
        }else if header == "Дата"{
            
            if minDate != oldMinDate || maxDate != oldMaxDate{
                button.isHidden = false
            }else{
                button.isHidden = true
            }
            
        }
        
        button.addAction(UIAction(handler: { [weak self] _ in
            
            if header == "Тип операции"{
                
                self?.opType = self?.oldOpType
                
            }else if header == "Сумма"{
                
                self?.lowPrice = self?.oldLowPrice
                self?.upPrice = self?.oldUpPrice
                
            }else if header == "Дата"{
                
                self?.minDate = self?.oldMinDate
                self?.maxDate = self?.oldMaxDate
                
            }
            
            self?.checkForResults()
            self?.collectionView.reloadData()
            
        }), for: .touchUpInside)
        
    }
    
    func setUpSingleLabelCell(with text : String, for cell : UICollectionViewCell){
        
        guard let label = cell.viewWithTag(1) as? UILabel else {return}
        
        label.text = text
        
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.backgroundColor = UIColor(named: "gray")
        
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
                
                if data["payments_count"].stringValue != "" {
                    
                    resultsCount = Int(data["payments_count"].stringValue)
                    
                }else{
                    resultsCount = 0
                }
                
            }
            
            collectionView.reloadSections([7])
            
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
                
                if data["payments_count"].stringValue != ""{
                    
                    resultsCount = Int(data["payments_count"].stringValue)
                    
                }else{
                    resultsCount = 0
                }
                
            }
            
            collectionView.reloadSections([7])
            
        }
        
    }
    
    func didFailGettingClientsFilterPayHistByClientCountDataWithError(error: String) {
        print("Error with ClientsFilterPayHistByClientCountDataManager : \(error)")
    }
    
}
