//
//  SetPointActionsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.01.2021.
//

import Foundation
import SwiftyJSON

protocol SetPointActionsDataManagerDelegate {
    func didGetSetPointActionsData(data : JSON)
    func didFailGettingSetPointActionsDataWithError(error : String)
}

struct SetPointActionsDataManager {
    
    var delegate : SetPointActionsDataManagerDelegate?
    
    func getSetPointActionsData(key : String , pointId : String , actionId : String ){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.SetPointActions?Akey=\(key)&APointID=\(pointId)&AActionID=\(actionId)"
        
        print("URLString for SetPointActionsDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSetPointActionsDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSetPointActionsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetPointActionsDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetPointActionsData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
