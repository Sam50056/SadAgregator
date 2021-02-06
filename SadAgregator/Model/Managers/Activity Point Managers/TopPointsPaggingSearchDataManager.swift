//
//  TopPointsPaggingSearchDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.01.2021.
//

import Foundation
import SwiftyJSON

protocol TopPointsPaggingSearchDataManagerDelegate {
    func didGetTopPointsPaggingSearchData(data : JSON)
    func didFailGettingTopPointsPaggingSearchDataWithError(error : String)
}

struct TopPointsPaggingSearchDataManager {
    
    var delegate : TopPointsPaggingSearchDataManagerDelegate?
    
    func getTopPointsPaggingSearchData(key : String , query : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_srch.TopPointsPagingSrch?AKey=\(key)&AQuery=\(query)&APage=\(page)"
        
        print("URLString for TopPointsPaggingSearchDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingTopPointsPaggingSearchDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingTopPointsPaggingSearchDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetTopPointsPaggingSearchData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
