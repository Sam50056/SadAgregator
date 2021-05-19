//
//  PurchasesAddItemCommentsListDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 20.05.2021.
//

import Foundation
import SwiftyJSON

struct PurchasesAddItemCommentsListDataManager {
    
    func getPurchasesAddItemCommentsListData(key : String, comment : String , myComment : String , items : [String] , completionHandler: @escaping (JSON?, String?) -> Void){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.AddItemCommentsList?AKey=\(key)&AItemsList=\(items)&AComment=\(comment)&APrivateComment=\(myComment)"
        
        print("URLString for PurchasesAddItemCommentsListDataManager : \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                completionHandler(nil , error!.localizedDescription)
                return
            }
            
            guard let data = data else {completionHandler(nil , "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            completionHandler(jsonAnswer , nil)
            
        }
        
        task.resume()
        
    }
    
}
