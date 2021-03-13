//
//  ClientsFIlterDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsFilterDataManagerDelegate {
    func didGetClientsFIlterData(data : JSON)
    func didFailGettingClientsFIlterDataWithError(error : String)
}

struct ClientsFilterDataManager{
    
    var delegate : ClientsFilterDataManagerDelegate?
    
    func getClientsFIlterData(key : String , query : String = "" , debotors : Int = 0 , page : Int = 1){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.Filter?AKey=\(key)&AQuery=\(query)&ADebtors=\(debotors)&APage=\(page)"
        
        print("URLString for ClientsFilterDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsFIlterDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsFIlterDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsFIlterData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
