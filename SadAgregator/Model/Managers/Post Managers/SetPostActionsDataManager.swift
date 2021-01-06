//
//  SetPostActionsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.01.2021.
//

import Foundation
import SwiftyJSON

protocol SetPostActionsDataManagerDelegate {
    func didGetSetPostActionsData(data : JSON)
    func didFailGettingSetPostActionsDataWithError(error : String)
}

struct SetPostActionsDataManager{
    
    var delegate : SetPostActionsDataManagerDelegate?
    
    func getSetPostActionsData(key : String , actionId : String , postId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.SetPostActions?Akey=\(key)&APostID=\(postId)&AActionID=\(actionId)"
        
        print("URLString for SetPostActionsDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSetPostActionsDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSetPostActionsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetPostActionsDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetPostActionsData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
