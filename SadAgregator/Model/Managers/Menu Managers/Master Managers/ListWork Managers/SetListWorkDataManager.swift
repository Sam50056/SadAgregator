//
//  SetListWorkDataManagers.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 29.12.2020.
//

import Foundation
import SwiftyJSON

protocol SetListWorkDataManagerDelegate {
    func didGetSetListWorkData(data : JSON)
    func didFailGettingSetListWorkDataWithError(error : String)
}

struct SetListWorkDataManager {
    
    var delegate : SetListWorkDataManagerDelegate?
    
    func getSetListWorkData(key : String , stepId : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.Set_ListWORK?AKey=\(key)&AStep=\(stepId)"
        
        print("URLString for SetListWorkDataManager : \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSetListWorkDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSetListWorkDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetListWorkDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetListWorkData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
