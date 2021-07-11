//
//  ProdsInPointTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.07.2021.
//

import UIKit
import SwiftUI
import SwiftyJSON
import RealmSwift

//MARK: - View Representable

struct ProdsInPointView : UIViewControllerRepresentable{
    
    var pointId : String?
    var helperId : String?
    var status : String?
    
    func makeUIViewController(context: Context) -> ProdsInPointTableViewController {
        
        let vc = ProdsInPointTableViewController()
        
        vc.pointId = pointId
        vc.helperId = helperId
        vc.status = status
        
        return vc
        
    }
    
    func updateUIViewController(_ uiViewController: ProdsInPointTableViewController, context: Context) {
        
    }
    
}

//MARK: - View Controller

class ProdsInPointTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var key = ""
    
    var pointId : String?
    var helperId : String?
    var status : String?
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var assemblyProdsInPointDataManager = AssemblyProdsInPointDataManager()
    
    private var purProds = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assemblyProdsInPointDataManager.delegate = self
        
        loadUserData()
        
        tableView.register(UINib(nibName: "TovarTableViewCell", bundle: nil), forCellReuseIdentifier: "tovar_cell")
        
        tableView.allowsSelection = false
        
        refresh()
        
    }
    
}

//MARK: - Functions

extension ProdsInPointTableViewController{
    
    func update(){
        
        assemblyProdsInPointDataManager.getAssemblyProdsInPointData(key: key, pointId: pointId ?? "", helperId: helperId ?? "", status: status ?? "", page: page)
        
    }
    
    func refresh (){
        
        page = 1
        rowForPaggingUpdate = 15
        
        update()
        
    }
    
    func showQRScannerVC(){
        
        let qrScannerVC = QRScannerController()
        
        let navVc = UINavigationController(rootViewController: qrScannerVC)
        
        navVc.modalPresentationStyle = .fullScreen
        
        present(navVc, animated: true, completion: nil)
        
    }
    
}

//MARK: - TableView

extension ProdsInPointTableViewController{
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purProds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !purProds.isEmpty else {return UITableViewCell()}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tovar_cell",for: indexPath) as! TovarTableViewCell
        
        cell.isZamena = false
        
        let purProd = purProds[indexPath.row]
        
        let tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue)
        
        cell.thisTovar = tovar
        
        cell.tovarImageTapped = {
            
            let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
            
            galleryVC.simplePreviewMode = true
            
            galleryVC.selectedImageIndex = 0
            
            galleryVC.images = [PostImage(image: tovar.img, imageId: "")]
            
            galleryVC.sizes = []
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self.presentHero(navVC, navigationAnimationType: .fade)
            
        }
        
        cell.qrCodeTapped = {
            
            if tovar.qr == "1"{
                
                let alertController = UIAlertController(title: "Перепривязать код?", message: nil, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in
                    self.showQRScannerVC()
                }))
                
                alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
            }else{
                
                self.showQRScannerVC()
                
            }
            
        }
        
        cell.magnifyingGlassTapped = {
            
            let tovarImageSearchVC = TovarImageSearchTableViewController()
            
            tovarImageSearchVC.imageHashText = tovar.hash
            
            //            print("HASH THAT WE'RE GIVING \(tovar.hash)")
            
            self.navigationController?.pushViewController(tovarImageSearchVC, animated: true)
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard !purProds.isEmpty else {return 420}
        
        let purProd = purProds[indexPath.row]
        
        let tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue)
        
        return K.makeHeightForTovarCell(thisTovar: tovar, isZamena: false)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == 8{
            
            if indexPath.row == rowForPaggingUpdate{
                
                page += 1
                
                rowForPaggingUpdate += 16
                
                update()
                
                print("Done a request for page: \(page)")
                
            }
            
        }
        
    }
    
}

//MARK: - AssemblyProdsInPointDataManager

extension ProdsInPointTableViewController : AssemblyProdsInPointDataManagerDelegate{
    
    func didGetAssemblyProdsInPointData(data: JSON) {
        
        DispatchQueue.main.async {
            
            if data["result"].intValue == 1{
                
                self.purProds.append(contentsOf: data["assembly_prods"].arrayValue)
                
                if self.page == 1 && self.purProds.isEmpty{
                    
                    let alertController = UIAlertController(title: "У пользователя не добавлены товары", message: nil, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                self.tableView.reloadData()
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingAssemblyProdsInPointDataWithError(error: String) {
        print("Error with AssemblyProdsInPointDataManager : \(error)")
    }
    
}

//MARK: - Data Manipulation Methods

extension ProdsInPointTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}
