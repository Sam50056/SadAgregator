//
//  SaveOkInfoDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.01.2021.
//

import Foundation
import SwiftyJSON

protocol SaveOkInfoDataManagerDelegate{
    func didGetSaveOkInfoData(data : JSON)
    func didFailGettingSaveOkInfoDataWithError(error : String)
}

struct SaveOkInfoDataManager {
    
    var delegate : SaveOkInfoDataManagerDelegate?
    
    func getSaveOkInfoData(key : String , fieldId : String , value : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.SaveOKInfo?AKey=\(key)&AFieldID=\(fieldId)&AVal=\(value)"
        
        print("URLString for SaveOkInfoDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSaveOkInfoDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSaveOkInfoDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSaveOkInfoData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
