//
//  AddOrDeleteListWorkExtDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.12.2020.
//

import Foundation
import SwiftyJSON

protocol AddOrDeleteListWorkExtDataManagerDelegate {
    func didGetAddOrDeleteListWorkExtData(data : JSON)
    func didFailGettingAddOrDeleteListWorkExtDataWithError(error : String)
}

struct AddOrDeleteListWorkExtDataManager {
    
    var delegate : AddOrDeleteListWorkExtDataManagerDelegate?
    
    func getAddOrDeleteListWorkExtData(method : String ,key : String , stepId : Int , listId : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.\(method == "add" ? "ADD" : "DEL")_ListWork_Ext?AKey=\(key)&AStep=\(stepId)&AListID=\(listId)"
        
        print("URLString for AddOrDeleteListWorkExtDataManager : \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingAddOrDeleteListWorkExtDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingAddOrDeleteListWorkExtDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingAddOrDeleteListWorkExtDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetAddOrDeleteListWorkExtData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
