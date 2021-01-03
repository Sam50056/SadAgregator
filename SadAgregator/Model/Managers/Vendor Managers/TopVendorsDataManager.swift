//
//  TopVendorsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.01.2021.
//

import Foundation
import SwiftyJSON

protocol TopVendorsDataManagerDelegate {
    func didGetTopVendorsData(data : JSON)
    func didFailGettingTopVendorsDataWithError(error : String)
}


struct TopVendorsDataManager {
    
    var delegate : TopVendorsDataManagerDelegate?
    
    func getTopVendorsData(key : String , query : String , page : Int = 1){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_srch.VendorsTOP?AKey=\(key)&AQuery=\(query)&APage=\(page)"
        
        print("URLString for TopVendorsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingTopVendorsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingTopVendorsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetTopVendorsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
