//
//  VendUpdSendRuleDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.06.2021.
//

import Foundation
import SwiftyJSON

struct VendUpdSendRuleDataManager {
    
    func getVendUpdSendRuleData(key : String , ruleId : String , sendType : String , price : String , completionHandler: @escaping (JSON?, String?) -> Void){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_vend.UpdSendRule?AKey=\(key)&ARuleID=\(ruleId)&AType=\(sendType)&APrice=\(price)"
        
        print("URLString for VendUpdSendRuleDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                completionHandler(nil, error!.localizedDescription)
                return
            }
            
            guard let data = data else {completionHandler(nil, "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            completionHandler(jsonAnswer,nil)
            
        }
        
        task.resume()
        
    }
    
}
