//
//  LinePointsPaggingSearchDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.01.2021.
//

import Foundation
import SwiftyJSON

protocol LinePointsPaggingSearchDataManagerDelegate {
    func didgetLinePostsPaggingSearchData(data : JSON)
    func didFailGettingLinePostsPaggingSearchDataWithError(error : String)
}

struct LinePointsPaggingSearchDataManager {
    
    var delegate : LinePointsPaggingSearchDataManagerDelegate?
    
    func getLinePostsPaggingSearchData(key : String , lineId : String , query : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_srch.LinePointsPagingSrch?AKey=\(key)&ALineID=\(lineId)&AQuery=\(query)&APage=\(page)"
        
        print("URLString for LinePostsPaggingSearchDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingLinePostsPaggingSearchDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingLinePostsPaggingSearchDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingLinePostsPaggingSearchDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didgetLinePostsPaggingSearchData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
