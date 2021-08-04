//
//  BrokersReviewUpdateDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.08.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersReviewUpdateDataManagerDelegate{
    func didGetBrokersReviewUpdateData(data : JSON)
    func didFailGettingBrokersReviewUpdateDataWithError(error : String)
}

struct BrokersReviewUpdateDataManager{
    
    var delegate : BrokersReviewUpdateDataManagerDelegate?
    
    func getBrokersReviewUpdateData(key : String , brokerId : String,  rating : Int, title : String = "" , text : String = "" , images : String = "" ){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.ReviewUpdate?AKey=\(key)&ABrokerID=\(brokerId)&ARating=\(rating)&ATitle=\(title)&AText=\(text)&AImages=\(images)"
        
        print("URLString for BrokersReviewUpdateDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingBrokersReviewUpdateDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersReviewUpdateDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersReviewUpdateData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
