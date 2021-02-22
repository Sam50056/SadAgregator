//
//  GetCatpageDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 16.02.2021.
//

import Foundation
import SwiftyJSON

protocol GetCatpageDataManagerDelegate {
    func didGetGetCatpageData(data : JSON)
    func didFailGettingGetCatpageDataWithError(error : String)
}

struct GetCatpageDataManager {
    
    var delegate : GetCatpageDataManagerDelegate?
    
    func getGetCatpageData(key : String , catId : String , page : Int , filter : String = "" , min : Int = 0 , max : Int = 0){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_cats.GetCatPage?AKey=\(key)&ACatID=\(catId)&APage=\(page)&AFilter=\(filter)&AMin=\(min)&AMax=\(max)"
        
        print("URLString for GetCatpageDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingGetCatpageDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingGetCatpageDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetGetCatpageData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
