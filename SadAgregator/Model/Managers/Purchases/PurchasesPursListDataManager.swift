//
//  PurchasesPursListDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.04.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesPursListDataManagerDelegate {
    func didGetPurchasesPursListData(data : JSON)
    func didFailGettingPurchasesPursListDataWithError(error : String)
}

struct PurchasesPursListDataManager {
    
    var delegate : PurchasesPursListDataManagerDelegate?
    
    func getPurchasesPursListData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.PursList?AKey=\(key)&APage=\(page)"
        
        print("URLString for PurchasesPursListDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesPursListDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesPursListDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesPursListData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
