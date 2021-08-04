//
//  BrokersBrokerCardDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.08.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersBrokerCardDataManagerDelegate{
    func didGetBrokersBrokerCardData(data : JSON)
    func didFailGettingBrokersBrokerCardDataWithError(error : String)
}

struct BrokersBrokerCardDataManager{
    
    var delegate : BrokersBrokerCardDataManagerDelegate?
    
    func getBrokersBrokerCardData(key : String , id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.BrokerCard?Akey=\(key)&ABrokerID=\(id)"
        
        print("URLString for BrokersBrokerCardDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBrokersBrokerCardDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersBrokerCardDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersBrokerCardData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
