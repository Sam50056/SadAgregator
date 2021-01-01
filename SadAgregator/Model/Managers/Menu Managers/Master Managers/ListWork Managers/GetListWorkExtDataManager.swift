//
//  GetListWorkExtDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.12.2020.
//

import Foundation
import SwiftyJSON

protocol GetListWorkExtDataManagerDelegate {
    func didGetGetListWorkExtData(data : JSON)
    func didFailGettingGetListWorkExtDataWithError(error : String)
}

struct GetListWorkExtDataManager {
    
    var delegate : GetListWorkExtDataManagerDelegate?
    
    func getGetListWorkExtData(key : String , stepId : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.Get_ListWORK_Ext?AKey=\(key)&AStep=\(stepId)"
        
        print("URLString for GetListWorkExtDataManager : \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetListWorkExtDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetListWorkExtDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetListWorkExtDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetListWorkExtData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
