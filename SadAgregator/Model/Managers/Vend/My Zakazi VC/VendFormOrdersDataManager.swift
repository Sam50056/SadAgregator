//
//  VendFormOrdersDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.12.2021.
//

import Foundation
import SwiftyJSON

protocol VendFormOrdersDataManagerDelegate {
    func didGetVendFormOrdersData(data : JSON)
    func didFailGettingVendFormOrdersDataWithError(error : String)
}

struct VendFormOrdersDataManager{
    
    var delegate : VendFormOrdersDataManagerDelegate?
    
    func getVendFormOrdersData(key : String, status : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_vend.FormOrders?AKey=\(key)&AStatus=\(status)&APage=\(page)"
        
        print("URLString for TopVendorsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingVendFormOrdersDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingVendFormOrdersDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetVendFormOrdersData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
