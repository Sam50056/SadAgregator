//
//  PurchasesSellPriceRecalcDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.05.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesSellPriceRecalcDataManagerDelegate {
    func didGetPurchasesSellPriceRecalcData(data : JSON)
    func didFailGettingPurchasesSellPriceRecalcDataWithError(error : String)
}

struct PurchasesSellPriceRecalcDataManager {
    
    var delegate : PurchasesSellPriceRecalcDataManagerDelegate?
    
    func getPurchasesSellPriceRecalcData(key : String, buyPrice price : String , imgId id : String){

        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.SellPriceRecalc?Akey=\(key)&ABuyPrice=\(price)&AImgID=\(id)"
        
        print("URLString for PurchasesSellPriceRecalcDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesSellPriceRecalcDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesSellPriceRecalcDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesSellPriceRecalcData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
