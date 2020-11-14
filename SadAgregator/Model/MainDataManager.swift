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
        
        guard let url = URL(string: urlString) else {return}
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                
                delegate?.didFailGettingMainData(error: error!.localizedDescription)
                
                return
            }
            
            
            do{
                
                if let data = data {
                    
                    let jsonAnswer = try JSON(data: data)
                    
                    delegate?.didGetMainData(data: jsonAnswer)
                    
                }
                
            }catch{
                delegate?.didFailGettingMainData(error: error.localizedDescription)
            }
            
        }
        
            task.resume()
        
    }
    
}
