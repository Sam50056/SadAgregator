//
//  GetVendActionsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.01.2021.
//

import Foundation
import SwiftyJSON

protocol GetVendActionsDataManagerDelegate {
    func didGetGetVendActionsData(data : JSON)
    func didFailGettingGetVendActionsData(error : String)
}

struct GetVendActionsDataManager {
    
    var delegate : GetVendActionsDataManagerDelegate?
    
    func getGetVendActionsData(key : String , vendId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.GetVendActions?Akey=\(key)&AVendID=\(vendId)"
        
        print("URLString for GetVendActionsDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetVendActionsData(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetVendActionsData(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetVendActionsData(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetVendActionsData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
