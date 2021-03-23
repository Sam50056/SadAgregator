//
//  ClientsSetActive.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.03.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsSetActiveDataManagerDelegate {
    func didGetClientsSetActiveData(data : JSON)
    func didFailGettingClientsSetActiveDataWithError(error : String)
}

struct ClientsSetActiveDataManager {
    
    var delegate : ClientsSetActiveDataManagerDelegate?
    
    func getClientsSetActiveData(key : String , clientId id : String , state : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.SetActive?AKey=\(key)&AClientID=\(id)&AState=\(state)"
        
        print("URLString for ClientsSetActiveDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsSetActiveDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsSetActiveDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsSetActiveData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
