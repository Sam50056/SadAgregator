//
//  PurchasesUpdateZonePriceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.05.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesUpdateZonePriceDataManagerDelegate {
    func didGetPurchasesUpdateZonePriceData(data : JSON)
    func didFailGettingPurchasesUpdateZonePriceDataWithError(error : String)
}

struct PurchasesUpdateZonePriceDataManager {
    
    var delegate : PurchasesUpdateZonePriceDataManagerDelegate?
    
    func getPurchasesUpdateZonePriceDataManager(key : String , zoneId id : String ,  from : String , to : String , merge : String , fix : String , trunc : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.UpdZonePrice?AKey=\(key)&AZoneID=\(id)&AFrom=\(from)&ATo=\(to)&AMarge=\(merge)&AFixDop=\(fix)&ATruncVal=\(trunc)"
        
        print("URLString for PurchasesUpdateZonePriceDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesUpdateZonePriceDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesUpdateZonePriceDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesUpdateZonePriceData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
