//
//  PurchasesItemInfoDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.04.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesItemInfoDataManagerDelegate {
    func didGetPurchasesItemInfoData(data : JSON)
    func didFailGettingPurchasesItemInfoDataWithError(error : String)
}

struct PurchasesItemInfoDataManager {
    
    var delegate : PurchasesItemInfoDataManagerDelegate?
    
    func getPurchasesItemInfoData(key : String , imageId id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.ItemInfo?AKey=\(key)&AImgID=\(id)"
        
        print("URLString for PurchasesItemInfoDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesItemInfoDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesItemInfoDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesItemInfoData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
