//
//  ClientDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.03.2021.
//

import Foundation
import SwiftyJSON

protocol ClientDataManagerDelegate {
    func didGetClientData(data : JSON)
    func didFailGettingClientDataWithError(error : String)
}

struct ClientDataManager{
    
    var delegate : ClientDataManagerDelegate?
    
    func getClientData(key : String , clientId id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.Client?AKey=\(key)&AClientID=\(id)"
        
        print("URLString for ClientDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
