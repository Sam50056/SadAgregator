//
//  VendorLikeDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 13.12.2020.
//

import Foundation
import SwiftyJSON

protocol VendorLikeDataManagerDelegate {
    func didGetVendorLikeData(data : JSON)
    func didFailGettingVendorLikeDataWithError(error : String)
}

struct VendorLikeDataManager {
    
    var delegate : VendorLikeDataManagerDelegate?
    
    func getVendorLikeData(key : String , vendId : String , status : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.VendorLike?AKey=\(key)&AVendID=\(vendId)&AStatus=\(status)"
        
        print("URLString for VendorLikeDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingVendorLikeDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingVendorLikeDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingVendorLikeDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetVendorLikeData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
