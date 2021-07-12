//
//  ZamenaDlyaTableViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.04.2021.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ZamenaDlyaTableViewController: UITableViewController {
    
    private let realm = try! Realm()
    
    private var key = ""
    
    var thisClientId : String?
    var zakupkaId : String?
    
    private var purchasesProdsByClientDataManager = PurchasesProdsByClientDataManager()
    
    private var page = 1
    private var rowForPaggingUpdate : Int = 15
    
    private var purProds = [JSON]()
    
    var tovarSelected : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        loadUserData()
        key = "part_2_test"
        
        purchasesProdsByClientDataManager.delegate = self
        
        tableView.register(UINib(nibName: "TovarTableViewCell", bundle: nil), forCellReuseIdentifier: "tovar_cell")
        tableView.allowsSelection = false
        
        if let id = thisClientId{
            purchasesProdsByClientDataManager.getPurchasesProdsByClientData(key: key, clientId: id, purSYSID: zakupkaId ?? "")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Замена для"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(otmenaTapped(_:)))
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let purProd = purProds[indexPath.row]
        
        let tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, payedImage: purProd["payed_img"].stringValue)
        
        return K.makeHeightForTovarCell(thisTovar: tovar, isZamena: true)
        
    }
    
}

//MARK: - Actions

extension ZamenaDlyaTableViewController{
    
    @IBAction func otmenaTapped(_ sender : Any){
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - PurchasesProdsByClientDataManager

extension ZamenaDlyaTableViewController : PurchasesProdsByClientDataManagerDelegate{
    
    func didGetPurchasesProdsByClientData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            if data["result"].intValue == 1{
                
                purProds.append(contentsOf: data["pur_prods"].arrayValue)
                
                if page == 1 && purProds.isEmpty{
                    
                    let alertController = UIAlertController(title: "У пользователя не добавлены товары", message: nil, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    present(alertController, animated: true, completion: nil)
                    
                }
                
                tableView.reloadData()
                
            }else{
                
            }
            
        }
        
    }
    
    func didFailGettingPurchasesProdsByClientDataWithError(error: String) {
        print("Error with PurchasesProdsByClientDataManager : \(error)")
    }
    
}

// MARK: - TableView

extension ZamenaDlyaTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purProds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tovar_cell",for: indexPath) as! TovarTableViewCell
        
        cell.isZamena = true
        
        let purProd = purProds[indexPath.row]
        
        let tovar = TovarCellItem(pid: purProd["pi_id"].stringValue, capt: purProd["capt"].stringValue, size: purProd["size"].stringValue, payed: purProd["payed"].stringValue, purCost: purProd["cost_pur"].stringValue, sellCost: purProd["cost_sell"].stringValue, hash: purProd["hash"].stringValue, link: purProd["link"].stringValue, clientId: purProd["client_id"].stringValue, clientName: purProd["client_name"].stringValue, comExt: purProd["com_ext"].stringValue, qr: purProd["qr"].stringValue, status: purProd["status"].stringValue, isReplace: purProd["is_replace"].stringValue, forReplacePid: purProd["for_replace_pi_id"].stringValue, replaces: purProd["replaces"].stringValue, img: purProd["img"].stringValue, chLvl: purProd["ch_lvl"].stringValue, payedImage: purProd["payed_img"].stringValue)
        
        cell.thisTovar = tovar
        
        cell.tovarSelected = { [self] in
            
            dismiss(animated: true, completion: nil)
            
            tovarSelected?(tovar.pid)
            
        }
        
        cell.tovarImageTapped = {
            
            let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
            
            galleryVC.simplePreviewMode = true
            
            galleryVC.selectedImageIndex = 0
            
            galleryVC.images = [PostImage(image: tovar.img, imageId: "")]
            
            galleryVC.sizes = []
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self.presentHero(navVC, navigationAnimationType: .fade)
            
        }
        
        cell.oplachenoTapped = {
            
            let galleryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryVC") as! GalleryViewController
            
            galleryVC.simplePreviewMode = true
            
            galleryVC.selectedImageIndex = 0
            
            galleryVC.images = [PostImage(image: tovar.payedImage, imageId: "")]
            
            galleryVC.sizes = []
            
            let navVC = UINavigationController(rootViewController: galleryVC)
            
            self.presentHero(navVC, navigationAnimationType: .fade)
            
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == rowForPaggingUpdate{
            
            page += 1
            
            rowForPaggingUpdate += 16
            
            if let id = thisClientId{
                purchasesProdsByClientDataManager.getPurchasesProdsByClientData(key: key, clientId: id, purSYSID: zakupkaId ?? "", page: page)
            }
            
            print("Done a request for page: \(page)")
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension ZamenaDlyaTableViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
        //        isLogged = userDataObject.first!.isLogged
        
    }
    
}
