//
//  PurchasesZonesPriceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 08.05.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesZonesPriceDataManagerDelegate {
    func didGetPurchasesZonesPrice(data : JSON)
    func didFailGettingPurchasesZonesPriceWithError(error : String)
}

struct PurchasesZonesPriceDataManager{
    
    var delegate : PurchasesZonesPriceDataManagerDelegate?
    
    func getPurchasesZonesPrice(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.ZonesPrice?AKey=\(key)"
        
        print("URLString for PurchasesProdsByClientDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesZonesPriceWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesZonesPriceWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesZonesPrice(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
