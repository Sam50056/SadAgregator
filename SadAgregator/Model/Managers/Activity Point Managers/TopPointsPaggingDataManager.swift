//
//  TopPointsPaggingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.01.2021.
//

import Foundation
import SwiftyJSON

protocol TopPointsPaggingDataManagerDelegate {
    func didGetTopPointsPaggingData(data : JSON)
    func didFailGettingTopPointsPaggingDataWithError(error : String)
}

struct TopPointsPaggingDataManager {
    
    var delegate : TopPointsPaggingDataManagerDelegate?
    
    func getTopPointsPaggingData(key : String, page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.TopPointsPaging?AKey=\(key)&APage=\(page)"
        
        print("URLString for TopPointsPaggingDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingTopPointsPaggingDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingTopPointsPaggingDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingTopPointsPaggingDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetTopPointsPaggingData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
