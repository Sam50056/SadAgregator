//
//  GetPointActionsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.01.2021.
//

import Foundation
import SwiftyJSON

protocol GetPointActionsDataManagerDelegate {
    func didGetGetPointActionsData(data : JSON)
    func didFailGettingGetPointActionsDataWithError(error : String)
}

struct GetPointActionsDataManager {
    
    var delegate : GetPointActionsDataManagerDelegate?
    
    func getGetPointActionsData(key : String, pointId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.GetPointActions?AKey=\(key)&APointID=\(pointId)"
        
        print("URLString for GetPointActionsDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetPointActionsDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetPointActionsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetPointActionsDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetPointActionsData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
