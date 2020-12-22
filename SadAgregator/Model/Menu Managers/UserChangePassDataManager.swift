//
//  UserChangePassDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.12.2020.
//

import Foundation
import SwiftyJSON

protocol UserChangePassDataManagerDelegate {
    func didGetUserChangePassData(data : JSON)
    func didFailGettingUserChangePassDataWithError(error : String)
}

struct UserChangePassDataManager {
    
    var delegate : UserChangePassDataManagerDelegate?
    
    func getUserChangePassData(key : String, oldPass : String , newPass : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.UserChangePass?AKey=\(key)&AOldPass=\(oldPass)&ANewPass=\(newPass)"
        
        print("URLString for UserChangePassDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingUserChangePassDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingUserChangePassDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingUserChangePassDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetUserChangePassData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
