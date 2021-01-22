//
//  AssignOKToAppIDDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.01.2021.
//

import Foundation
import SwiftyJSON

protocol AssignOKToAppIDDataManagerDelegate {
    func didGetAssignOKToAppIDData(data : JSON)
    func didFailGettingAssignOKToAppIDDataWithError(error : String)
}

struct AssignOKToAppIDDataManager {
    
    var delegate : AssignOKToAppIDDataManagerDelegate?
    
    func getAssignOKToAppIDData(key : String , okId : String , appId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.AssignOKToAppID?AKey=\(key)&AVKID=\(okId)&AAppID=\(appId)"
        
        print("URLString for AssignOKToAppIDDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingAssignOKToAppIDDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAssignOKToAppIDDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAssignOKToAppIDData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
