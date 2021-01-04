//
//  AuthSocialDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.01.2021.
//

import Foundation
import SwiftyJSON

protocol AuthSocialDataManagerDelegate {
    func didGetAuthSocialData(data : JSON)
    func didFailGettingAuthSocialDataWithError(error : String)
}

struct AuthSocialDataManager {
    
    var delegate : AuthSocialDataManagerDelegate?
    
    func getGetAuthSocialData(social : String ,token : String, key : String){
        
        let urlString = "http://tk-sad.ru/i/baza/auth-social?social=\(social)&token=\(token)&key=\(key)"
        
        print("URLString for AuthSocialDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingAuthSocialDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAuthSocialDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAuthSocialData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
