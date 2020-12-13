//
//  MainDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.11.2020.
//

import Foundation
import SwiftyJSON

protocol MainDataManagerDelegate {
    func didGetMainData(data : JSON)
    func didFailGettingMainData(error : String)
}

struct MainDataManager {
    
    var delegate : MainDataManagerDelegate?
    
    func getMainData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_intf.Main?AKey=\(key)"
        
        print("URLString for MainPageDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                delegate?.didFailGettingMainData(error: error!.localizedDescription)
                
                return
            }
            
            if let safeData = data {
                
                let json = String(data: safeData , encoding: String.Encoding.windowsCP1251)!
                
                let jsonAnswer = JSON(parseJSON: json)
                
                delegate?.didGetMainData(data: jsonAnswer)
                
            }
            
        }
        
        task.resume()
        
    }
    
}
