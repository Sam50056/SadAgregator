//
//  NoAnswerDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.10.2021.
//

import Foundation
import SwiftyJSON

struct NoAnswerDataManager {
    
    func sendNoAnswerDataRequest(url : URL? , completionHandler: ((JSON?, String?) -> Void)? = nil){
        
        guard let url = url else {return}
        
        print("NoAnswerDataManager Request with URL : \(url)")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                completionHandler?(nil , error!.localizedDescription)
                return
            }
            
            guard let data = data else {completionHandler?(nil , "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            completionHandler?(jsonAnswer , nil)
            
        }.resume()
        
    }
    
    func sendNoAnswerDataRequest(urlString : String , completionHandler: ((JSON?, String?) -> Void)? = nil){
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        print("NoAnswerDataManager Request with URL : \(url)")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                completionHandler?(nil , error!.localizedDescription)
                return
            }
            
            guard let data = data else {completionHandler?(nil , "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            completionHandler?(jsonAnswer , nil)
            
        }.resume()
        
    }
    
}


