//
//  BorkersBrokersTopDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.08.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersBrokersTopBySearchDataManagerDelegate{
    func didGetBorkersBrokersTopDataManager(data : JSON)
    func didFailGettingBorkersBrokersTopDataWithError(error : String)
}

struct BrokersBrokersTopBySearchDataManager{
    
    var delegate : BrokersBrokersTopBySearchDataManagerDelegate?
    
    func geBrokersBrokersTopBySearchData(key : String , query : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.BrokersTopBySrch?AKey=\(key)&AQuery=\(query)&APage=\(page)"
        
        print("URLString for BorkersBrokersTopDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBorkersBrokersTopDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBorkersBrokersTopDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBorkersBrokersTopDataManager(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
