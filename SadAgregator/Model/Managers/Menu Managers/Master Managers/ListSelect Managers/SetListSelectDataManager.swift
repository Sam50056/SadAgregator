//
//  SetListSelectDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.12.2020.
//

import Foundation
import SwiftyJSON

protocol SetListSelectDataManagerDelegate {
    func didGetSetListSelectData(data : JSON)
    func didFailGettingSetListSelectDataWithError(error : String)
}

struct SetListSelectDataManager {
    
    var delegate : SetListSelectDataManagerDelegate?
    
    func getSetListSelectData(key : String , stepId : Int , listId : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.Set_ListSelect?AKey=\(key)&AStepID=\(stepId)&AListID=\(listId)"
        
        print("URLString for SetListSelectDataManager : \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSetListSelectDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSetListSelectDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetListSelectDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetListSelectData(data: jsonAnswer)
        }
        
        task.resume()
        
        
    }
    
}
