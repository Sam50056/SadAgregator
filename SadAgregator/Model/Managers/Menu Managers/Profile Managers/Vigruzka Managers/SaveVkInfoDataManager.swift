//
//  SaveVkInfoDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 16.01.2021.
//

import Foundation
import SwiftyJSON

protocol SaveVkInfoDataManagerDelegate {
    func didGetSaveVkInfoData(data : JSON)
    func didFailGettingSaveVkInfoDataWithError(error : String)
}

struct SaveVkInfoDataManager {
    
    var delegate : SaveVkInfoDataManagerDelegate?
    
    func getSaveVkInfoData(key : String , fieldId : String , value : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.SaveVKInfo?AKey=\(key)&AFieldID=\(fieldId)&AVal=\(value)"
        
        print("URLString for SaveVkInfoDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSaveVkInfoDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSaveVkInfoDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSaveVkInfoData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
