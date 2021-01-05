//
//  PointPostsPaggingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.11.2020.
//

import Foundation
import SwiftyJSON

protocol PointPostsPaggingDataManagerDelegate {
    func didGetPointPostsPaggingData(data : JSON)
    func didFailGettingPointPostsPaggingDataWithError(error : String)
}

struct PointPostsPaggingDataManager {
    
    var delegate : PointPostsPaggingDataManagerDelegate?
    
    func getPointPostsPaggingData(key : String, pointId : String, page : Int) {
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.PointPostsPaging?AKey=\(key)&APointID=\(pointId)&APage=\(page)"
        
        print("URLString for PointPostsPaggingDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {return}
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let safeData = try? Data(contentsOf: url) {
                
                let json = String(data: safeData , encoding: String.Encoding.windowsCP1251)!
                
                let jsonAnswer = JSON(parseJSON: json)
                
                delegate?.didGetPointPostsPaggingData(data: jsonAnswer)
                
            }
            
        }
        
    }
    
}
