//
//  PurchasesGetProdReplacesDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.03.2022.
//

import Foundation
import SwiftyJSON

struct PurchasesGetProdReplacesDataManager{
    
    func getPurchasesGetProdReplacesData(key : String , purId : String , itemId : String , page : Int , completionHandler : ( (JSON? , String?) -> Void)? = nil){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.GetProdReplaces?AKey=\(key)&APurSYSID=\(purId)&AItemID=\(itemId)&APage=\(page)"
        
        print("URLString for PurchasesGetProdReplacesDataManager : \(urlString)")
        
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
