//
//  VendorCardDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 02.12.2020.
//

import Foundation
import SwiftyJSON

protocol VendorCardDataManagerDelegate {
    func getVendorCardData(data : JSON)
    func didFailGettingVendorCardDataWithError(error : String)
}

struct VendorCardDataManager {
    
    var delegate : VendorCardDataManagerDelegate?
    
    func getVendorCardData(key : String , vendorId id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.VendorCard?AKey=\(key)&AVendorID=\(id)"
        
        print("URLString for VendorCardDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingVendorCardDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingVendorCardDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingVendorCardDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.getVendorCardData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
