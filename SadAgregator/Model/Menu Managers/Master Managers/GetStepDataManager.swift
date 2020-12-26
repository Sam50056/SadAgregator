//
//  Get.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.12.2020.
//

import Foundation
import SwiftyJSON

protocol GetStepDataManagerDelegate {
    func didGetGetStepData(data : JSON)
    func didFailGettingGetStepDataWithError(error : String)
}

struct GetStepDataManager {
    
    var delegate : GetStepDataManagerDelegate?
    
    func getGetStepData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.GetStep?AKey=\(key)&AStep="
        
        print("URLString for GetStepDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetStepDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetStepDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetStepDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetStepData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
