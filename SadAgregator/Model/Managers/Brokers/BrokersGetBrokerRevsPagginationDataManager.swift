//
//  BrokersGetBrokerRevsPagginationDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.08.2021.
//

import Foundation
import SwiftyJSON

protocol  BrokersGetBrokerRevsPagginationDataManagerDelegate{
    func didGetBrokersGetBrokerRevsPagginationData(data : JSON)
    func didFailGettingBrokersGetBrokerRevsPagginationDataWithError(error : String)
}

struct BrokersGetBrokerRevsPagginationDataManager {
    
    var delegate : BrokersGetBrokerRevsPagginationDataManagerDelegate?
    
    func getBrokersGetBrokerRevsPagginationData(key : String , id : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.GetBrokerRevsPaging?AKey=\(key)&ABrokerID=\(id)&APage=\(page)"
        
        print("URLString for BrokersGetBrokerRevsPagginationDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBrokersGetBrokerRevsPagginationDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersGetBrokerRevsPagginationDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersGetBrokerRevsPagginationData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
