//
//  BrokerGetMyReviewDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.08.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersGetMyReviewDataManagerDelegate{
    func didGetBrokersGetMyReviewData(data : JSON)
    func didFailGettingBrokersGetMyReviewDataWithError(error : String)
}

struct BrokersGetMyReviewDataManager{
    
    var delegate : BrokersGetMyReviewDataManagerDelegate?
    
    func getBrokersGetMyReviewData(key : String , id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.GetMyReview?AKey=\(key)&ABroker=\(id)"
        
        print("URLString for BrokersGetMyReviewDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingBrokersGetMyReviewDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingBrokersGetMyReviewDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersGetMyReviewDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersGetMyReviewData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
