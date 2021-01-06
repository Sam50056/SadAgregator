//
//  GetPostActionsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.01.2021.
//

import Foundation
import SwiftyJSON

protocol GetPostActionsDataManagerDelegate {
    func didGetGetPostActionsData(data : JSON)
    func didFailGettingGetPostActionsDataWithError(error : String)
}

struct GetPostActionsDataManager {
    
    var delegate : GetPostActionsDataManagerDelegate?
    
    func getGetPostActionsData(key : String , postId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.GetPostActions?Akey=\(key)&APostID=\(postId)"
        
        print("URLString for GetPostActionsDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetPostActionsDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetPostActionsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetPostActionsDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetPostActionsData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
