//
//  PurchasesDeleteItemDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.03.2022.
//

import Foundation
import SwiftyJSON

struct PurchasesDeleteItemDataManager{
    
    func getPurchasesDeleteItemData(key : String , itemId : String , completionHandler : ( (JSON? , String?) -> Void)? = nil){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.DeleteItem?AKey=\(key)&AItemID=\(itemId)"
        
        print("URLString for PurchasesDeleteItemDataManager : \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                completionHandler?(nil , error!.localizedDescription)
                return
            }
            
            guard let data = data else {completionHandler?(nil , "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            completionHandler?(jsonAnswer , nil)
            
        }
        
        task.resume()
        
        
    }
    
}
