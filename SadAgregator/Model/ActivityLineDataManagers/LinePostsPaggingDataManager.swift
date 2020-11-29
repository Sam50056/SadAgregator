//
//  LinePostsPaggingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.11.2020.
//

import Foundation
import SwiftyJSON

protocol LinePostsPaggingDataManagerDelegate {
    func didGetLinePostsPaggingData(data : JSON)
    func didFailGettingLinePostsPaggingDataWithError(error : String)
}

struct LinePostsPaggingDataManager {
    
    var delegate : LinePostsPaggingDataManagerDelegate?
    
    func getLinePostsPaggingData(key : String , lineId : String , page : Int) {
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.LinePostsPaging?AKey=\(key)&ALineID=\(lineId)&APage=\(page)"
        
        print("URLString for LinePostsPaggingDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                delegate?.didFailGettingLinePostsPaggingDataWithError(error: error!.localizedDescription)
                
                return
            }
            
            if let safeData = data {
                
                let json = String(data: safeData , encoding: String.Encoding.windowsCP1251)!
                
                let jsonAnswer = JSON(parseJSON: json)
                
                delegate?.didGetLinePostsPaggingData(data: jsonAnswer)
                
            }
            
        }
        
        task.resume()
        
    }
    
}
