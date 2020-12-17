//
//  GetMyReviewDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.12.2020.
//

import Foundation
import SwiftyJSON

protocol GetMyReviewDataManagerDelegate {
    func didGetGetMyReviewData(data : JSON)
    func didFailGettingGetMyReviewDataWithError(error : String)
}

struct GetMyReviewDataManager {
    
    var delegate : GetMyReviewDataManagerDelegate?
    
    func getVendorLikeData(key : String , vendId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.GetMyReview?AKey=\(key)&AvendID=\(vendId)"
        
        print("URLString for GetMyReviewDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetMyReviewDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetMyReviewDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetMyReviewDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetMyReviewData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
    
}
