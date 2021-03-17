//
//  UpdateClientInfoDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.03.2021.
//

import Foundation
import SwiftyJSON

protocol UpdateClientInfoDataManagerDelegate {
    func didGetUpdateClientInfoData(data : JSON)
    func didFailGettingUpdateClientInfoDataWithError(error : String)
}

struct UpdateClientInfoDataManager {
    
    var delegate : UpdateClientInfoDataManagerDelegate?
    
    func getUpdateClientInfoData(key : String , clientId id : String , fieldId field : String , value : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.UpdateInfo?AKey=\(key)&AClientID=\(id)&AFieldID=\(field)&AVal=\(value)"
        
        print("URLString for UpdateClientInfoDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingUpdateClientInfoDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingUpdateClientInfoDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetUpdateClientInfoData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
