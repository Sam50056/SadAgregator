//
//  SetVendActionsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.01.2021.
//

import Foundation
import SwiftyJSON

protocol SetVendActionsDataManagerDelegate {
    func didGetSetVendActionsData(data : JSON)
    func didFailGettingSetVendActionsDataWithError(error : String)
}

struct SetVendActionsDataManager {
    
    var delegate : SetVendActionsDataManagerDelegate?
    
    func getSetVendActionsData(key : String , vendId : String , actionId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.SetVendActions?Akey=\(key)&AVendID=\(vendId)&AActionID=\(actionId)"
        
        print("URLString for SetVendActionsDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSetVendActionsDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingSetVendActionsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingSetVendActionsDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetSetVendActionsData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
