//
//  BrokersUpdateInfoDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 08.06.2021.
//

import Foundation
import SwiftyJSON

struct BrokersUpdateInfoDataManager{
    
    func getBrokersUpdateInfoData(key : String , type : String , value : String , completionHandler: @escaping (JSON?, String?) -> Void){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.UpdateInfo?AKey=\(key)&AFieldID=\(type)&AVal=\(value)"
        
        print("URLString for BrokersUpdateInfoDataManager: \(urlString)")
        
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
