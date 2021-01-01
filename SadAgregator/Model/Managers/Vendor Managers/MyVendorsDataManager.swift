//
//  MyVendorsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 24.12.2020.
//

import Foundation
import SwiftyJSON

protocol MyVendorsDataManagerDelegate {
    func didGetMyVendorsData(data : JSON)
    func didFailGettingMyVendorsDataWithError(error : String)
}

struct MyVendorsDataManager {
    
    var delegate : MyVendorsDataManagerDelegate?
    
    func getMyVendorsData(key: String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.MyVendors?AKey=\(key)&APage=\(page)"
        
        print("URLString for MyVendorsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingMyVendorsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingMyVendorsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetMyVendorsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
