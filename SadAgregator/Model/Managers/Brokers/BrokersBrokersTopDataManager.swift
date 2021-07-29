//
//  BrokersBrokersTopDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.07.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersBrokersTopDataManagerDelegate{
    func didGetBrokersBrokersTopData(data : JSON)
    func didFailGettingBrokersBrokersTopDataWithError(error : String)
}

struct BrokersBrokersTopDataManager{
    
    var delegate : BrokersBrokersTopDataManagerDelegate?
    
    func getBrokersBrokersTopData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.BrokersTop?AKey=\(key)&APage=\(page)"
        
        print("URLString for BrokersBrokersTopDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBrokersBrokersTopDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersBrokersTopDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersBrokersTopData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
