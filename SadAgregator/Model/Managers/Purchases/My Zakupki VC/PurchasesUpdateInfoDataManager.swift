//
//  PurchasesUpdateInfoDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.10.2021.
//

import Foundation
import SwiftyJSON

struct PurchasesUpdateInfoDataManager {
    
    func getPurchasesUpdateInfoData(key : String , purSysId : String , fieldId : String , val : String , completionHandler: @escaping (JSON?, String?) -> Void){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.UpdateInfo?AKey=\(key)&APurSYSID=\(purSysId)&AFieldID=\(fieldId)&AVal=\(val)"
        
        print("URLString for PurchasesUpdateInfoDataManager : \(urlString)")
        
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
