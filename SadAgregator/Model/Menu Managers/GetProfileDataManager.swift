//
//  GetProfileDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.12.2020.
//

import Foundation
import SwiftyJSON

protocol GetProfileDataManagerDelegate {
    func didGetGetProfileData(data : JSON)
    func didFailGettingGetProfileDataWithError(error : String)
}

struct GetProfileDataManager {
    
    var delegate : GetProfileDataManagerDelegate?
    
    func getGetProfileData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.GetProfile?AKey=\(key)"
        
        print("URLString for GetProfileDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetProfileDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetProfileDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetProfileDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetProfileData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
