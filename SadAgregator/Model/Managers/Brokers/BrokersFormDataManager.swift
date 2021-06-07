//
//  BrokersFormDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.06.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersFormDataManagerDelegate{
    func didGetBrokersFormData(data : JSON)
    func didFailGettingBrokersFormDataWithError(error : String)
}

struct BrokersFormDataManager {
    
    var delegate : BrokersFormDataManagerDelegate?
    
    func getBrokersFormData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.form?AKey=\(key)"
        
        print("URLString for BrokersFormDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBrokersFormDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersFormDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersFormData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
