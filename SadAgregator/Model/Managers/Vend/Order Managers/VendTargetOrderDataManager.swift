//
//  VendTargetOrderDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.12.2021.
//

import Foundation
import SwiftyJSON

protocol VendTargetOrderDataManagerDelegate {
    func didGetVendTargetOrderData(data : JSON)
    func didFailGettingVendTargetOrderDataWithError(error : String)
}

struct VendTargetOrderDataManager {
    
    var delegate : VendTargetOrderDataManagerDelegate?
    
    func getVendTargetOrderData(key : String , order : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_vend.TargetOrder?AKey=\(key)&AOrder=\(order)"
        
        print("URLString for VendTargetOrderDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingVendTargetOrderDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingVendTargetOrderDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetVendTargetOrderData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
