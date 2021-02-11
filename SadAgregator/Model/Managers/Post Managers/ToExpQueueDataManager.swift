//
//  ToExpQueueDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 31.01.2021.
//

import Foundation
import SwiftyJSON

protocol ToExpQueueDataManagerDelegate {
    func didGetToExpQueueData(data : JSON)
    func didFailGettingToExpQueueDataWithError(error : String)
}

struct ToExpQueueDataManager {
    
    var delegate : ToExpQueueDataManagerDelegate?
    
    func getToExpQueueData(key : String , postId : String , text : String = "", completionHandler: @escaping (JSON?, String?) -> Void){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.ToExpQueue?AKey=\(key)&APostID=\(postId)&AText=\(text)"
        
        print("URLString for ToExpQueueDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL) else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                completionHandler(nil, error?.localizedDescription)
                return
            }
            
            guard let data = data else { completionHandler(nil, "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            completionHandler(jsonAnswer, nil)
            
        }
        
        task.resume()
        
        
    }
    
}
