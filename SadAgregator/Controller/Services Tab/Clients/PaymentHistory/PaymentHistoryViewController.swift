//
//  PaymentHistoryViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import UIKit
import SwiftyJSON
import RealmSwift

class PaymentHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var thisClientId : String?
    
    private var clientsPaymentsDataManager = ClientsPaymentsDataManager()
    private var paggingPaymentsByClientDataManager = PaggingPaymentsByClientDataManager()
    private var clientsPagingPaymentsDataManager = ClientsPagingPaymentsDataManager()
    private var clientsFilterPayListDataManager = ClientsFilterPayListDataManager()
    private var clientsFilterPayHistByClientDataManager = ClientsFilterPayHistByClientDataManager()
    private lazy var newPhotoPlaceDataManager = NewPhotoPlaceDataManager()
    private lazy var photoSavedDataManager = PhotoSavedDataManager()
    
    private var checkImageUrl : URL?
    private var checkImageId : String?
    
    private var boxView = UIView()
    private var blurEffectView = UIVisualEffectView()
    
    private var payId : String?
    
    private var payments = [JSON]()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    var maxSumFromApi : String?
    var minDateFromApi : String?
    
    private var isFiltering = false
    private var opType : Int?
    private var source : Int?
    private var minPrice : Int?
    private var maxPrice : Int?
    private var minDate : String?
    private var maxDate : String?
    private var comment : String?
    
    private var refreshTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
        clientsPaymentsDataManager.delegate = self
        paggingPaymentsByClientDataManager.delegate = self
        clientsPagingPaymentsDataManager.delegate = self
        clientsFilterPayListDataManager.delegate = self
        clientsFilterPayHistByClientDataManager.delegate = self
        newPhotoPlaceDataManager.delegate = self
        
        navigationItem.title = "История платежей"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "paymentCell")
        tableView.allowsSelection = false
        
        //Set up search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Быстрый поиск по комментариям"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let thisClientId = thisClientId {
            paggingPaymentsByClientDataManager.getPaggingPaymentsByClientData(key: key, clientId: thisClientId)
        }else{
            clientsPaymentsDataManager.getClientsPaymentsData(key: key)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterBarButtonTapped(_:)))
        
    }
    
}

//MARK: - Actions

extension PaymentHistoryViewController{
    
    @IBAction func filterBarButtonTapped(_ sender : UIBarButtonItem){
        
        let filterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentFilterVC") as! PaymentFilterViewController
        
        filterVC.minDateFromApi = minDateFromApi
        
        filterVC.delegate = self
        
        filterVC.thisClientId = thisClientId
        
        filterVC.opType = opType ?? 0
        filterVC.source = source
        
        filterVC.commentQuery = comment
        
        let maxSumFormApiInt = Int(maxSumFromApi ?? "")
        
        filterVC.lowPrice = minPrice
        filterVC.upPrice = maxPrice
        
        filterVC.maxPrice = maxSumFormApiInt
        
        filterVC.minDate = minDate ?? minDateFromApi
        filterVC.maxDate = maxDate
        
        let navVC = UINavigationController(rootViewController: filterVC)
        
        presentHero(navVC, navigationAnimationType: .selectBy(presenting: .pull(direction: .down), dismissing: .pull(direction: .up)))
        
    }
    
}

//MARK: - Functions

extension PaymentHistoryViewController {
    
    func showBoxView(with text : String) {
        
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        let width = text.width(withConstrainedHeight: UIScreen.main.bounds.width - 16, font: UIFont.systemFont(ofSize: 17)) + 60
        
        // You only need to adjust this frame to move it anywhere you want
        boxView = UIView(frame: CGRect(x: view.frame.midX - (width/2), y: view.frame.midY - 25, width: width, height: 50))
        boxView.backgroundColor = UIColor(named: "gray")
        boxView.alpha = 0.95
        boxView.layer.cornerRadius = 10
        
        boxView.center = view.center
        
        //Here the spinnier is initialized
        let activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.startAnimating()
        
        let textLabel = UILabel(frame: CGRect(x: 45, y: 0, width: 200, height: 50))
        textLabel.textColor = UIColor.gray
        textLabel.text = text
        
        boxView.addSubview(activityView)
        boxView.addSubview(textLabel)
        
        view.addSubview(boxView)
        
        view.isUserInteractionEnabled = false
        
    }
    
    func removeBoxView(){
        
        boxView.removeFromSuperview()
        blurEffectView.removeFromSuperview()
        view.isUserInteractionEnabled = true
        
    }
    
    func checkSent() {
        
        guard let checkImageId = checkImageId else {return}
        
        ClientsUpdatePayImageDataManager().getClientsUpdatePayImageData(key: key, payHistId: payId ?? "", imgId: checkImageId) { data, error in
            
        }
        
    }
    
    func showOneTovarItem(id : String){
        
        let oneTovarItemVC = OneTovarViewController()
        
        oneTovarItemVC.itemId = id
        
        navigationController?.pushViewController(oneTovarItemVC, animated: true)
        
    }
    
}

//MARK: - SearchBar

extension PaymentHistoryViewController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else {return}
        
        refreshTimer.invalidate()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [self] (timer) in
            
            comment = text
            
            page = 1
            rowForPaggingUpdate = 15
            
            payments.removeAll()
            
            tableView.reloadData()
            
            if let thisClientId = thisClientId {
                
                clientsFilterPayHistByClientDataManager.getClientsFilterPayHistByClientData(key : key , clientId: thisClientId , page : page , source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: minPrice == nil ? "" : String(minPrice!), sumMax: maxPrice ==  nil ? "" : String(maxPrice!) , startDate: minDate ?? "", endDate: maxDate ?? Date().formatDate(), query: comment ?? "")
                
            }else{
                
                clientsFilterPayListDataManager.getClientsFilterPayListData(key : key , page : page , source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: minPrice == nil ? "" : String(minPrice!), sumMax: maxPrice ==  nil ? "" : String(maxPrice!) , startDate: minDate ?? "", endDate: maxDate ?? Date().formatDate(), query: comment ?? "")
                
            }
            
        })
        
        
        
    }
    
}

//MARK: - Data Manipulation Methods

extension PaymentHistoryViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}

//MARK: - ClientsPaymentsDataManagerDelegate

extension PaymentHistoryViewController : ClientsPaymentsDataManagerDelegate{
    
    func didGetClientsPaymentsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                maxSumFromApi = data["filter"]["max_sum"].string
                minDateFromApi = data["filter"]["min_dt"].string
                
                payments = data["payments"].arrayValue
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientsPaymentsDataWithError(error: String) {
        print("Error with ClientsPaymentsDataManager : \(error)")
    }
    
}

//MARK: - PaggingPaymentsByClientDataManagerDelegate

extension PaymentHistoryViewController : PaggingPaymentsByClientDataManagerDelegate{
    
    func didGetPaggingPaymentsByClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                payments += data["payments"].arrayValue
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingPaggingPaymentsByClientDataWithError(error: String) {
        print("Error with PaggingPaymentsByClientDataManager : \(error)")
    }
    
}

//MARK: - ClientsPagingPaymentsDataManagerDelegate

extension PaymentHistoryViewController : ClientsPagingPaymentsDataManagerDelegate{
    
    func didGetClientsPagingPaymentsData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                payments += data["payments"].arrayValue
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientsPagingPaymentsDataWithError(error: String) {
        print("Error with ClientsPagingPaymentsDataManager : \(error)")
    }
    
}

//MARK: - TableView

extension PaymentHistoryViewController : UITableViewDataSource , UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !payments.isEmpty else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! PaymentTableViewCell
        
        let payment = payments[indexPath.row]
        
        cell.key = key
        
        cell.pid = payment["pid"].stringValue
        cell.dt =  payment["dt"].string
        cell.clientName = payment["client_name"].stringValue
        cell.clientId = payment["client_id"].stringValue
        cell.comment =  payment["comment"].stringValue
        cell.summ = payment["summ"].string
        
        cell.firstLabel.text = payment["pid"].stringValue
        
        cell.secondLabel.text = payment["dt"].stringValue
        
        cell.textField.text = payment["comment"].stringValue
        
        cell.rightRoundImageView.image = UIImage(systemName: "newspaper")
        cell.leftRoundImageView.image = UIImage(systemName: "cart")
        
        if payment["summ"].stringValue.first == "-"{
            cell.leftRoundView.isHidden = true
        }else{
            cell.rightRoundView.isHidden = false
        }
        
        if let piId = payment["pi_id"].string , !piId.isEmpty{
            
            if payment["summ"].stringValue.first == "-"{
                cell.rightRoundImageView.image = UIImage(systemName: "cart")
                cell.rightRoundView.isHidden = false
            }else{
                cell.leftRoundView.isHidden = false
            }
            
        }else{
            cell.leftRoundView.isHidden = true
            if payment["summ"].stringValue.first == "-"{
                cell.rightRoundView.isHidden = true
            }
        }
        
        //Checking for check images
        if let img = payment["img"].string , !img.isEmpty{
            cell.rightRoundView.alpha = 1
        }else if payment["summ"].stringValue.first != "-"{
            cell.rightRoundView.alpha = 0.5
        }else{
            cell.rightRoundView.alpha = 1
        }
        
        cell.leftViewButtonTapped = { [weak self] in
            
            guard let tovarId = payment["pi_id"].string , !tovarId.isEmpty else {return}
            
            self?.showOneTovarItem(id: tovarId)
            
        }
        
        cell.rightViewButtonTapped = { [weak self] in
            
            if payment["summ"].stringValue.first == "-"{
                //CART Button
                
                guard let tovarId = payment["pi_id"].string , !tovarId.isEmpty else {return}
                
                self?.showOneTovarItem(id: tovarId)
                
            }else{
                
                if let img = payment["img"].string , !img.isEmpty{
                    
                    self?.previewImage(img)
                    
                }else{
                    
                    let alertController = UIAlertController(title: "Прикрепить чек?", message: nil, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                        
                        self?.payId = payment["pid"].string
                        
                        self?.showImagePickerController(sourceType: .photoLibrary)
                        
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    self?.present(alertController, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
        cell.rightViewButtonLonlglyTapped = { [weak self] in
            
            guard payment["img"].stringValue != "" else {return}
            
            let alertController = UIAlertController(title: "Перепривязать чек?", message: nil, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                
                self?.payId = payment["pid"].string
                
                self?.showImagePickerController(sourceType: .photoLibrary)
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            self?.present(alertController, animated: true, completion: nil)
            
        }
        
        cell.clientSelected = { [self] clientId in
            print("CL")
            let clientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientVC") as! ClientViewController
            
            clientVC.thisClientId = clientId
            
            self.navigationController?.pushViewController(clientVC, animated: true)
            
        }
        
        //        cell.tableView.reloadData()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            if let thisClientId = thisClientId {
                
                if isFiltering{
                    
                    clientsFilterPayHistByClientDataManager.getClientsFilterPayHistByClientData(key : key , clientId: thisClientId , page : page , source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: minPrice == nil ? "" : String(minPrice!), sumMax: maxPrice ==  nil ? "" : String(maxPrice!) , startDate: minDate ?? "", endDate: maxDate ?? Date().formatDate(), query: comment ?? "")
                    
                }else{
                    
                    paggingPaymentsByClientDataManager.getPaggingPaymentsByClientData(key: key, clientId: thisClientId,page: page)
                    
                }
                
            }else{
                
                if isFiltering{
                    
                    clientsFilterPayListDataManager.getClientsFilterPayListData(key : key , page : page , source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: minPrice == nil ? "" : String(minPrice!), sumMax: maxPrice ==  nil ? "" : String(maxPrice!) , startDate: minDate ?? "", endDate: maxDate ?? Date().formatDate(), query: comment ?? "")
                    
                }else{
                    
                    clientsPagingPaymentsDataManager.getClientsPagingPaymentsData(key: key, page: page)
                    
                }
                
            }
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - PaymentFilterViewControllerDelegate

extension PaymentHistoryViewController : PaymentFilterViewControllerDelegate{
    
    func didFilterStuff(source: Int?, opType: Int?, sumMin: Int?, sumMax: Int?, startDate: String?, endDate: String?, query: String) {
        
        payments.removeAll()
        
        page = 1
        rowForPaggingUpdate = 15
        
        isFiltering = true
        
        if thisClientId != nil{
            clientsFilterPayHistByClientDataManager.getClientsFilterPayHistByClientData(key: key, clientId: thisClientId!, page : page , source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: sumMin == nil ? "" : String(sumMin!) , sumMax: sumMax == nil ? "" : String(sumMax!), startDate: startDate ?? "", endDate: endDate ?? Date().formatDate(), query: query)
        }else{
            clientsFilterPayListDataManager.getClientsFilterPayListData(key: key, page : page , source: source == nil ? "" : String(source!), opType: opType == nil ? "" : String(opType!), sumMin: sumMin == nil ? "" : String(sumMin!) , sumMax: sumMax == nil ? "" : String(sumMax!), startDate: startDate ?? "", endDate: endDate ?? Date().formatDate(), query: query)
        }
        
        self.opType = opType
        self.source = source
        self.comment = query
        self.minPrice = sumMin
        self.maxPrice = sumMax
        self.minDate = startDate
        self.maxDate = endDate
        
        self.searchController.searchBar.text = query
        
    }
    
}

//MARK: - ClientsFilterPayListDataManager

extension PaymentHistoryViewController : ClientsFilterPayListDataManagerDelegate{
    
    func didGetClientsFilterPayListData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                payments.append(contentsOf: data["payments"].arrayValue)
                
                tableView.reloadData()
                
            }
            
        }
        
    }
    
    func didFailGettingClientsFilterPayListDataWithError(error: String) {
        print("Error with ClientsFilterPayListDataManager : \(error)")
    }
    
}

//MARK: - ClientsFilterPayHistByClientDataManager

extension PaymentHistoryViewController : ClientsFilterPayHistByClientDataManagerDelegate{
    
    func didGetClientsFilterPayHistByClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                payments.append(contentsOf: data["payments"].arrayValue)
                
                tableView.reloadData()
                
            }
            
        }
    }
    
    func didFailGettingClientsFilterPayHistByClientDataWithError(error: String) {
        print("Error with ClientsFilterPayHistByClientDataManager : \(error)")
    }
    
}


//MARK: - UIImagePickerControllerDelegate

extension PaymentHistoryViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerController(sourceType : UIImagePickerController.SourceType) {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = sourceType
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let safeUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            
            checkImageUrl = safeUrl
            showBoxView(with: "Загрузка фото чека")
            newPhotoPlaceDataManager.getNewPhotoPlaceData(key: key)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


//MARK: - NewPhotoPlaceDataManagerDelegate

extension PaymentHistoryViewController : NewPhotoPlaceDataManagerDelegate{
    
    func didGetNewPhotoPlaceData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                let url = "\(data["post_to"].stringValue)/store?file_name=\(data["file_name"].stringValue)"
                
                print("URL FOR SENDING THE FILE: \(url)")
                
                guard let checkImageUrl = checkImageUrl else {return}
                
                sendFileToServer(from: checkImageUrl, to: url)
                
                let imageId = data["image_id"].stringValue
                
                let imageLinkWithPortAndWithoutFile = "\(data["post_to"].stringValue)"
                let splitIndex = imageLinkWithPortAndWithoutFile.lastIndex(of: ":")!
                let imageLink = "\(String(imageLinkWithPortAndWithoutFile[imageLinkWithPortAndWithoutFile.startIndex ..< splitIndex]))\(data["file_name"].stringValue)"
                
                print("Image Link: \(imageLink)")
                
                checkImageId = imageId
                
            }else{
                
                removeBoxView()
                
            }
            
        }
        
    }
    
    func didFailGettingNewPhotoPlaceDataWithError(error: String) {
        print("Error with NewPhotoPlaceDataManager: \(error)")
    }
    
}

//MARK: - File Sending

extension PaymentHistoryViewController{
    
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
                    
                    print("Got check sent to server")
                    
                    photoSavedDataManager.getPhotoSavedData(key: key, photoId: checkImageId!) { data, error in
                        
                        if let error = error{
                            print("Error with PhotoSavedDataManager : \(error)")
                            return
                        }
                        
                        guard let data = data else {return}
                        
                        if data["result"].intValue == 1{
                            
                            print("Check image successfuly saved to server")
                            
                            DispatchQueue.main.async { [weak self] in
                                
                                self?.removeBoxView()
                                
                                self?.checkSent()
                                
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
