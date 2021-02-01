//
//  RateUpdateDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 01.02.2021.
//

import Foundation
import SwiftyJSON

struct RateUpdateDataManager {
    
    func getRateUpdateData(key : String , vendId : String , rate : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.RateUpdate?AKey=\(key)&AVendID=\(vendId)&ARate=\(rate)"
        
        print("URLString for RateUpdateDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                return
            }
            
            guard let data = data else {return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let _ = JSON(parseJSON: json)
            
        }
        
        task.resume()
        
    }
    
}
