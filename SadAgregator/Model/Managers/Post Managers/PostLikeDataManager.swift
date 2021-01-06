//
//  PostLikeDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.01.2021.
//

import Foundation
import SwiftyJSON

protocol PostLikeDataManagerDelegate {
    func didGetPostLikeData(data : JSON)
    func didFailGettingPostLikeDataWithError(error : String)
}

struct PostLikeDataManager {
    
    var delegate : PostLikeDataManagerDelegate?
    
    func getPostLikeData(key : String , id : String, status : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.PostLike?AKey=\(key)&APostID=\(id)&AStatus=\(status)"
        
        print("URLString for PostLikeDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingPostLikeDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingPostLikeDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPostLikeDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPostLikeData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
