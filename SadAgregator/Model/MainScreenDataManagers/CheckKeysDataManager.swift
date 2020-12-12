//
//  CheckKeysData.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.11.2020.
//

import Foundation
import SwiftyJSON

protocol CheckKeysDataManagerDelegate {
    func didGetCheckKeysData(data : JSON)
    func didFailGettingCheckKeysData(error : String)
}

struct CheckKeysDataManager {
    
    var delegate : CheckKeysDataManagerDelegate?
    
    func getKeysData(key: String?) {
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.CheckKeys?AKey=\(key ?? "")" //If the key is nil we just send nothing ("") 
        
        print("URLString for checkKeysDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingCheckKeysData(error: error?.localizedDescription ?? "Data is empty")
                return
            }
            
            do {
                
                if let safeData = data{
                    
                    let json = String(data: safeData , encoding: String.Encoding.windowsCP1251)!
                    
                    let jsonAnswer = JSON(parseJSON: json)
                    
                    delegate?.didGetCheckKeysData(data: jsonAnswer)
                    
                }
                
            }catch{
                self.delegate?.didFailGettingCheckKeysData(error: error.localizedDescription)
            }
            
        }
        
        task.resume()
        
    }
    
}
