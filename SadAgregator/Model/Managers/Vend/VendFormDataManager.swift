//
//  VendFormDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.06.2021.
//

import Foundation
import SwiftyJSON

protocol VendFormDataManagerDelegate {
    func didGetVendFormData(data : JSON)
    func didFailGettingVendFormDataWithError(error : String)
}

struct VendFormDataManager {
    
    var delegate : VendFormDataManagerDelegate?
    
    func getVendFormData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_vend.form?AKey=\(key)"
        
        print("URLString for VendFormDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingVendFormDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingVendFormDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetVendFormData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
