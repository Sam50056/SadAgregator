//
//  LinePointsPaggingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.01.2021.
//

import Foundation
import SwiftyJSON

protocol LinePointsPaggingDataManagerDelegate {
    func didGetLinePointsPaggingData(data : JSON)
    func didFailGettingLinePointsPaggingDataWithError(error : String)
}

struct LinePointsPaggingDataManager {
    
    var delegate : LinePointsPaggingDataManagerDelegate?
    
    func getLinePointsPaggingData(key : String , lineId : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.LinePointsPaging?AKey=\(key)&ALineID=\(lineId)&APage=\(page)"
        
        print("URLString for LinePointsPaggingDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingLinePointsPaggingDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingLinePointsPaggingDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetLinePointsPaggingData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
