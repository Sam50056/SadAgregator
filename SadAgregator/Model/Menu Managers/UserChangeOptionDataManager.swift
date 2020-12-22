//
//  UserChangeOptionDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.12.2020.
//

import Foundation
import SwiftyJSON

protocol UserChangeOptionDataManagerDelegate{
    func didGetUserChangeOptionData(data : JSON)
    func didFailGettingUserChangeOptionDataWithError(error: String)
}

struct UserChangeOptionDataManager {
    
    var delegate : UserChangeOptionDataManagerDelegate?
    
    func getUserChangeOptionData(key: String , infoType : Int ,newValue : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.UsetChangeOption?AKey=\(key)&AInfoType=\(infoType)&ANewVal=\(newValue)"
        
        print("URLString for UserChangeOptionDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingUserChangeOptionDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingUserChangeOptionDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingUserChangeOptionDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetUserChangeOptionData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
