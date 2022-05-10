//
//  GetVendPostsPaggingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.01.2021.
//

import Foundation
import SwiftyJSON

protocol GetVendPostsPaggingDataManagerDelegate {
    func didGetGetVendPostsPaggingData(data : JSON)
    func didFailGettingGetVendPostsPaggingDataWithError(error : String)
}

struct GetVendPostsPaggingDataManager {
    
    var delegate : GetVendPostsPaggingDataManagerDelegate?
    
    func getGetVendPostsPaggingData(domain : String , key : String , vendId : String , page : Int){
        
        let urlString = "https://\(domain != "" ? domain : "agrapi.tk-sad.ru")/agr_intf.GetVendPostsPaging?AKEy=\(key)&AVendorID=\(vendId)&APage=\(page)"
        
        print("URLString for GetVendPostsPaggingDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingGetVendPostsPaggingDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingGetVendPostsPaggingDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetVendPostsPaggingDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetVendPostsPaggingData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
