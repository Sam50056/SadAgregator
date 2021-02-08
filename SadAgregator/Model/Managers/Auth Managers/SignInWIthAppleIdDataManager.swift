//
//  SignInWIthAppleIdDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.02.2021.
//

import Foundation
import SwiftyJSON

protocol SignInWIthAppleIdDataManagerDelegate {
    func didGetSignInWIthAppleIdData(data : JSON)
    func didFailGettingSignInWIthAppleIdDataWithError(error : String)
}

struct SignInWIthAppleIdDataManager {
    
    var delegate : SignInWIthAppleIdDataManagerDelegate?
    
    func getSignInWIthAppleIdData(userId id : String, name : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.SignWithAppleID?AUserID=\(id)&AName=\(name)"
        
        print("URLString for SignInWIthAppleIdDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSignInWIthAppleIdDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSignInWIthAppleIdDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSignInWIthAppleIdData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
