//
//  PurchasesProdsByClientByStatusDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.10.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesProdsByClientByStatusDataManagerDelegate {
    func didGetPurchasesProdsByClientByStatusData(data : JSON)
    func didFailGettingPurchasesProdsByClientByStatusDataWithError(error : String)
}

struct PurchasesProdsByClientByStatusDataManager {
    
    var delegate : PurchasesProdsByClientByStatusDataManagerDelegate?
    
    func getPurchasesProdsByClientByStatusData(key : String, id : String , status : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.ProdsByPurByStatus?AKey=\(key)&APruSYSID=\(id)&AStatus=\(status)&APage=\(page)"
        
        print("URLString for PurchasesProdsByClientByStatusDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesProdsByClientByStatusDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesProdsByClientByStatusDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesProdsByClientByStatusData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
