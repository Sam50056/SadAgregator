//
//  BrokersUpdZonePriceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 19.06.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersUpdZonePriceDataManagerDelegate {
    func didGetBrokersUpdZonePriceData(data : JSON)
    func didFailGettingBrokersUpdZonePriceDataWithError(error : String)
}

struct BrokersUpdZonePriceDataManager {
    
    var delegate : BrokersUpdZonePriceDataManagerDelegate?
    
    func getBrokersUpdZonePriceData(key : String , zoneId id : String , from : String , to : String , merge : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.UpdZonePrice?Akey=\(key)&AZoneID=\(id)&AFrom=\(from)&ATo=\(to)&Amarge=\(merge)"
        
        print("URLString for BrokersUpdZonePriceDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBrokersUpdZonePriceDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersUpdZonePriceDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersUpdZonePriceData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
