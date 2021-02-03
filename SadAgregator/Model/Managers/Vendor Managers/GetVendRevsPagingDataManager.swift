//
//  GetVendRevsPagingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.02.2021.
//

import Foundation
import SwiftyJSON

protocol GetVendRevsPagingDataManagerDelegate {
    func didGetGetVendRevsPagingData(data : JSON)
    func didFailGettingGetVendRevsPagingDataWithError(error : String)
}

struct GetVendRevsPagingDataManager {
    
    var delegate : GetVendRevsPagingDataManagerDelegate?
    
    func getGetVendRevsPagingData(key : String, vendId : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.GetVendRevsPaging?AKey=\(key)&AVendorID=\(vendId)&APage=\(page)"
        
        print("URLString for GetVendRevsPagingDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetVendRevsPagingDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetVendRevsPagingDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetVendRevsPagingDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetVendRevsPagingData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
