//
//  PurchasesProdsByClientDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 20.04.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesProdsByClientDataManagerDelegate {
    func didGetPurchasesProdsByClientData(data : JSON)
    func didFailGettingPurchasesProdsByClientDataWithError(error : String)
}

struct PurchasesProdsByClientDataManager {
    
    var delegate : PurchasesProdsByClientDataManagerDelegate?
    
    func getPurchasesProdsByClientData(key : String, clientId id : String , purSYSID : String , page : Int = 1){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.ProdsByClient?AKey=\(key)&APurSYSID=\(purSYSID)&AClientID=\(id)&APage=\(page)"
        
        print("URLString for PurchasesProdsByClientDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesProdsByClientDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesProdsByClientDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesProdsByClientData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
