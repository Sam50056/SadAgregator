//
//  PurchasesAddItemCommentDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.07.2021.
//

import Foundation
import SwiftyJSON

struct PurchasesAddItemCommentDataManager{
    
    func getPurchasesAddItemCommentData(key : String , purItemId : String , comType : String , comment : String , completionHandler : ( (JSON? , String?) -> Void)? = nil){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.AddItemComment?AKey=\(key)&APurItemID=\(purItemId)&AComTYPE=\(comType)&AComment=\(comment)"
        
        print("URLString for PurchasesAddItemCommentDataManager : \(urlString)")
        
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
