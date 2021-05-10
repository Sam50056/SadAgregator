//
//  PurchasesAddZonePriceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.05.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesAddZonePriceDataManagerDelegate {
    func didGetPurchasesAddZonePriceData(data : JSON)
    func didFailGettingPurchasesAddZonePriceDataWithError(error : String)
}

struct PurchasesAddZonePriceDataManager {
    
    var delegate : PurchasesAddZonePriceDataManagerDelegate?
    
    func getPurchasesAddZonePriceDataManager(key : String , from : String , to : String , merge : String , fix : String , trunc : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.AddZonePrice?AKey=\(key)&AFrom=\(from)&ATo=\(to)&AMarge=\(merge)&AFixDop=\(fix)&ATruncVal=\(trunc)"
        
        print("URLString for PurchasesAddZonePriceDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesAddZonePriceDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesAddZonePriceDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesAddZonePriceData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
