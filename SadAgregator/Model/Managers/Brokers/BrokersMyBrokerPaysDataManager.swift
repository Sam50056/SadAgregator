//
//  BrokersMyBrokerPaysDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.09.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersMyBrokerPaysDataManagerDelegate {
    func didGetBrokersMyBrokerPaysData(data : JSON)
    func didFailGettingBrokersMyBrokerPaysDataWithError(error : String)
}

struct BrokersMyBrokerPaysDataManager {
    
    var delegate : BrokersMyBrokerPaysDataManagerDelegate?
    
    func getBrokersMyBrokerPaysData(key : String , id  : String , query : String = "" , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.MyBrokerPays?Akey=\(key)&ABrokerID=\(id)&AQuery=\(query)&APage=\(page)"
        
        print("URLString for BrokersMyBrokerPaysDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingBrokersMyBrokerPaysDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersMyBrokerPaysDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersMyBrokerPaysData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
