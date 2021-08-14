//
//  BrokersFavoritesDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 15.08.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersFavoritesDataManagerDelegate{
    func didGegBrokersFavoritesData(data : JSON)
    func didFailGettingBrokersFavoritesDataWithError(error : String)
}

struct BrokersFavoritesDataManager{
    
    var delegate : BrokersFavoritesDataManagerDelegate?
    
    func getBrokersFavoritesData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.Favorites?AKey=\(key)&APage=\(page)"
        
        print("URLString for BrokersFavoritesDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingBrokersFavoritesDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersFavoritesDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGegBrokersFavoritesData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
