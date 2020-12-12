//
//  RegisterDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.12.2020.
//

import Foundation
import SwiftyJSON

protocol RegisterDataManagerDelegate {
    func didGetRegisterData(data : JSON)
    func didFailGettingRegisterDataWithError(error : String)
}

struct RegisterDataManager {
    
    var delegate : RegisterDataManagerDelegate?
    
    func getRegisterData(key : String , email : String , name : String , password : String , phone : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.Register?AKey=\(key)&AEmail=\(email)&AName=\(name)&APass=\(password)&APhone=\(phone)"
        
        print("URLString for RegisterDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingRegisterDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingRegisterDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetRegisterData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
