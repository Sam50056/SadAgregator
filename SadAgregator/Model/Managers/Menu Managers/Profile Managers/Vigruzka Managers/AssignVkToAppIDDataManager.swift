//
//  AssignVkToAppID.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 16.01.2021.
//

import Foundation
import SwiftyJSON

protocol AssignVkToAppIDDataManagerDelegate {
    func didGetAssignVkToAppIDData(data : JSON)
    func didFailGettingAssignVkToAppIDDataWithError(error : String)
}

struct AssignVkToAppIDDataManager {
    
    var delegate : AssignVkToAppIDDataManagerDelegate?
    
    func getAssignVkToAppIDData(key : String , vkId : String , appId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.AssignVKToAppID?AKey=\(key)&AVKID=\(vkId)&AAppID=\(appId)"
        
        print("URLString for AssignVkToAppIDDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingAssignVkToAppIDDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAssignVkToAppIDDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAssignVkToAppIDData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
