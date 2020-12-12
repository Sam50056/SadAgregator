//
//  AuthDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.12.2020.
//

import Foundation
import SwiftyJSON

protocol AuthDataManagerDelegate {
    func didGetAuthData(data : JSON)
    func didFailGettingAuthDataWithError(error : String)
}

struct AuthDataManager {
    
    var delegate : AuthDataManagerDelegate?
    
    func getAuthData(key : String , login : String , pass : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.Auth?ALogin=\(login)&APass=\(pass)&AKey=\(key)"
        
        print("URLString for AuthDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingAuthDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAuthDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAuthData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
