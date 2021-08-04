//
//  BrokersBrokerLikeDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.08.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersBrokerLikeDataManagerDelegate{
    func didGetBrokersBrokerLikeData(data : JSON)
    func didFailGettingBrokersBrokerLikeDataWithError(error : String)
}

struct BrokersBrokerLikeDataManager{
    
    var delegate : BrokersBrokerLikeDataManagerDelegate?
    
    func getBrokersBrokerLikeData(key : String , brokerId : String , status : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.BrokerLike?Akey=\(key)&Abroker=\(brokerId)&AStatus=\(status)"
        
        print("URLString for VendorLikeDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingBrokersBrokerLikeDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingBrokersBrokerLikeDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersBrokerLikeDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersBrokerLikeData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
