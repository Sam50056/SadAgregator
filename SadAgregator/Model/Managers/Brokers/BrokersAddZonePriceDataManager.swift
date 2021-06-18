//
//  BrokersAddZonePriceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.06.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersAddZonePriceDataManagerDelegate {
    func didGetBrokersAddZonePriceData(data : JSON)
    func didFailGettingBrokersAddZonePriceDataWithError(error : String)
}

struct BrokersAddZonePriceDataManager {
    
    var delegate : BrokersAddZonePriceDataManagerDelegate?
    
    func getBrokersAddZonePriceData(key : String , from : String , to : String , merge : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.AddZonePrice?Akey=\(key)&AFrom=\(from)&ATo=\(to)&Amarge=\(merge)"
        
        print("URLString for BrokersAddZonePriceDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBrokersAddZonePriceDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersAddZonePriceDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersAddZonePriceData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
