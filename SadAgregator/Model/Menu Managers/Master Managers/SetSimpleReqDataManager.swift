//
//  SetSimpleReqDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.12.2020.
//

import Foundation
import SwiftyJSON

protocol SetSimpleReqDataManagerDelegate {
    func didGetSetSimpleReqData(data : JSON)
    func didFailGettingSetSimpleReqDataWithError(error : String)
}

struct SetSimpleReqDataManager {
    
    var delegate : SetSimpleReqDataManagerDelegate?
    
    func getSetSimpleReqData(key: String, stepId : Int , sellId : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_assist.Set_SimpleReq?AKey=\(key)&AStepID=\(stepId)&ASelID=\(sellId)"
        
        print("URLString for SetSimpleReqDataManager : \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSetSimpleReqDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSetSimpleReqDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetSimpleReqDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetSimpleReqData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
