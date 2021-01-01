//
//  ReviewUpdateDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.12.2020.
//

import Foundation
import SwiftyJSON

protocol ReviewUpdateDataManagerDelegate {
    func didGetReviewUpdateData(data : JSON)
    func didFailGettingReviewUpdateDataWithError(error : String)
}

struct ReviewUpdateDataManager {
    
    var delegate : ReviewUpdateDataManagerDelegate?
    
    func getReviewUpdateData(key : String , vendId : String,  rating : Int, title : String = "" , text : String = "" , images : String = "" ){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.ReviewUpdate?AKey=\(key)&AvendID=\(vendId)&ARating=\(rating)&ATitle=\(title)&AText=\(text)&AImages=\(images)"
        
        print("URLString for ReviewUpdateDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingReviewUpdateDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingReviewUpdateDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetReviewUpdateData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
