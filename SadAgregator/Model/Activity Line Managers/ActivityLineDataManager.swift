//
//  ActivityLineDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 22.11.2020.
//

import Foundation
import SwiftyJSON

protocol ActivityLineDataManagerDelegate {
    func didGetActivityData(data : JSON)
    func didFailGettingActivityLineData(error: String)
}

struct ActivityLineDataManager {
    
    var delegate : ActivityLineDataManagerDelegate?
    
    func getActivityData(key: String , lineId id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.ActivityLine?AKey=\(key)&ALineID=\(id)"
        
        print("URLString for ActivityLineDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingActivityLineData(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingActivityLineData(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingActivityLineData(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetActivityData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
