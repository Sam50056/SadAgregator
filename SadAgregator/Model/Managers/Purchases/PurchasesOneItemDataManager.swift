//
//  PurchasesOneItemDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.09.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesOneItemDataManagerDelegate{
    func didGetPurchasesOneItemData(data : JSON)
    func didFailGettingPurchasesOneItemDataWithError(error : String)
}

struct PurchasesOneItemDataManager{
    
    var delegate : PurchasesOneItemDataManagerDelegate?
    
    func getPurchasesOneItemData(key : String , item : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.OneItem?Akey=\(key)&AItem=\(item)"
        
        print("URLString for PurchasesOneItemDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesOneItemDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesOneItemDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesOneItemData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
