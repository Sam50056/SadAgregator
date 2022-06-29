//
//  AssemblyCommentsViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.07.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class AssemblyCommentsViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var thisTovarId : String?
    
    private var purchasesGetItemCommentsDataManager = PurchasesGetItemCommentsDataManager()
    private lazy var purchasesAddItemCommentDataManager = PurchasesAddItemCommentDataManager()
    
    var pageData : JSON?
    
    var isEditingComFromOrg = false
    var isEditingComForIsp = false
    var isEditingComFromIsp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadUserData()
        
        purchasesGetItemCommentsDataManager.delegate = self
        
        refresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Комментарии"
        
    }
    
}

//MARK: - Functions

extension AssemblyCommentsViewController {
    
    func refresh(){
        
        guard let thisTovarId = thisTovarId else {
            return
        }
        
        pageData = nil
        
        bringTextViewsDown()
        
        purchasesGetItemCommentsDataManager.getPurchasesGetItemCommentsData(key: key, id: thisTovarId)
        
    }
    
    func bringTextViewsDown() {
        
        isEditingComFromOrg = false
        isEditingComForIsp = false
        isEditingComFromIsp = false
        
    }
    
}

//MARK: - UITextView

extension AssemblyCommentsViewController : UITextViewDelegate{
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let thisTovarId = thisTovarId else {return}
        
        let id = textView.restorationIdentifier ?? ""
        
        bringTextViewsDown()
        
        if id == "1"{
            
            purchasesAddItemCommentDataManager.getPurchasesAddItemCommentData(key: key, purItemId: thisTovarId, comType: "1", comment: textView.text.replacingOccurrences(of: "\n", with: "<br>"))
            
        }else if id == "2"{
            
            purchasesAddItemCommentDataManager.getPurchasesAddItemCommentData(key: key, purItemId: thisTovarId, comType: "0", comment: textView.text.replacingOccurrences(of: "\n", with: "<br>"))
            
        }else if id == "3"{
            
            purchasesAddItemCommentDataManager.getPurchasesAddItemCommentData(key: key, purItemId: thisTovarId, comType: "", comment: textView.text.replacingOccurrences(of: "\n", with: "<br>"))
            
        }
        
        refresh()
        
    }
    
}

//MARK: - PurchasesGetItemCommentsDataManagerDelegate

extension AssemblyCommentsViewController : PurchasesGetItemCommentsDataManagerDelegate{
    
    func didGetPurchasesGetItemCommentsData(data: JSON) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.pageData = data
            
            if data["result"].intValue == 1{
                
                self?.tableView.reloadData()
                
            }else{
                
                self?.showSimpleAlertWithOkButton(title: "Ошибка", message: data["msg"].string)
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesGetItemCommentsDataWithError(error: String) {
        print("Error with PurchasesGetItemCommentsDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension AssemblyCommentsViewController {
    
    func loadUserData (){
        
        let userDataObjects = realm.objects(UserData.self)
        
        key = userDataObjects.first!.key
        
    }
    
}


//MARK: - UITableView

extension AssemblyCommentsViewController : UITableViewDataSource , UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        guard let pageData = pageData else {return UITableViewCell()}
        
        if section == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel ,
                  let button = cell.viewWithTag(2) as? UIButton
            else {return cell}
            
            label.text = "Комментарий от организатора"
            button.isHidden = pageData["priv_com_ch"].intValue == 0
            button.setTitle(isEditingComFromOrg ? "Готово" : "Изменить", for: .normal)
            button.addAction(UIAction(handler: { [weak self] _ in
                self?.isEditingComFromOrg.toggle()
                self?.tableView.reloadData()
            }), for: .touchUpInside)
            
            return cell
            
        }else if section == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath)
            
            guard let textView = cell.viewWithTag(1) as? UITextView else {return cell}
            
            textView.restorationIdentifier = "1"
            
            textView.text = pageData["priv_com"].stringValue != "" ? pageData["priv_com"].stringValue.replacingOccurrences(of: "<br>", with: "\n") : (isEditingComFromOrg ? "" : "Нет комментария")
            
            textView.isEditable = isEditingComFromOrg
            
            textView.delegate = self
            
            return cell
            
        }else if section == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel ,
                  let button = cell.viewWithTag(2) as? UIButton
            else {return cell}
            
            label.text = "Комментарий для исполнителя"
            button.isHidden = pageData["handle_com_ch"].intValue == 0
            
            button.setTitle(isEditingComForIsp ? "Готово" : "Изменить", for: .normal)
            button.addAction(UIAction(handler: { [weak self] _ in
                self?.isEditingComForIsp.toggle()
                self?.tableView.reloadData()
            }), for: .touchUpInside)
            
            return cell
            
        }else if section == 3{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath)
            
            guard let textView = cell.viewWithTag(1) as? UITextView else {return cell}
            
            textView.restorationIdentifier = "2"
            
            textView.text = pageData["handle_com"].stringValue != "" ? pageData["handle_com"].stringValue.replacingOccurrences(of: "<br>", with: "\n") : ( isEditingComForIsp ? "" : "Нет комментария")
            
            textView.isEditable = isEditingComForIsp
            
            textView.delegate = self
            
            return cell
            
        }else if section == 4{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
            
            guard let label = cell.viewWithTag(1) as? UILabel ,
                  let button = cell.viewWithTag(2) as? UIButton
            else {return cell}
            
            label.text = "Комментарий от исполнителя"
            button.isHidden = pageData["by_handle_com_ch"].intValue == 0
            
            button.setTitle(isEditingComFromIsp ? "Готово" : "Изменить", for: .normal)
            button.addAction(UIAction(handler: { [weak self] _ in
                self?.isEditingComFromIsp.toggle()
                self?.tableView.reloadData()
            }), for: .touchUpInside)
            
            return cell
            
        }else if section == 5{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath)
            
            guard let textView = cell.viewWithTag(1) as? UITextView else {return cell}
            
            textView.restorationIdentifier = "3"
            
            textView.text = pageData["by_handle_com"].stringValue != "" ? pageData["by_handle_com"].stringValue.replacingOccurrences(of: "<br>", with: "\n") : (isEditingComFromIsp ? "" : "Нет комментария")
            
            textView.isEditable = isEditingComFromIsp
            
            textView.delegate = self
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        
        if section % 2 != 0 {
            return 150
        }else{
            return K.simpleHeaderCellHeight
        }
        
    }
    
}
