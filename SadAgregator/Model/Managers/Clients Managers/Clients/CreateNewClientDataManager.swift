//
//  CreateNewClientDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.03.2021.
//

import Foundation
import SwiftyJSON

protocol CreateNewClientDataManagerDelegate {
    func didGetCreateNewClientData(data : JSON)
    func didFailGettingCreateNewClientDataWithError(error : String)
}

struct CreateNewClientDataManager {
    
    var delegate : CreateNewClientDataManagerDelegate?
    
    func getCreateNewClientData(key : String , name : String , phone : String , vk : String , ok : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.CreateNew?AKey=\(key)&AName=\(name)&APhone=\(phone)&ALinkVK=\(vk)&ALinkOK=\(ok)"
        
        print("URLString for CreateNewClientDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingCreateNewClientDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingCreateNewClientDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetCreateNewClientData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
