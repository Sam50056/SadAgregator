//
//  ActivityPointDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 23.11.2020.
//

import Foundation
import SwiftyJSON

protocol ActivityPointDataManagerDelegate {
    func didGetActivityPointData(data : JSON)
    func didFailGettingActivityPointDataWithError(error: String)
}

struct ActivityPointDataManager {
    
    var delegate : ActivityPointDataManagerDelegate?
    
    func getActivityPointData(key: String , pointId id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.ActivityPoint?AKey=\(key)&APointID=\(id)"
        
        print("URLString for ActivityPointDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingActivityPointDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingActivityPointDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingActivityPointDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetActivityPointData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
