//
//  ClientsFilterPayHistByClientCountDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.04.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsFilterPayHistByClientCountDataManagerDelegate {
    func didGetClientsFilterPayHistByClientCountData(data : JSON)
    func didFailGettingClientsFilterPayHistByClientCountDataWithError(error : String)
}

struct ClientsFilterPayHistByClientCountDataManager {
    
    var delegate : ClientsFilterPayHistByClientCountDataManagerDelegate?
    
    func getClientsFilterPayHistByClientCountData(key : String , clientId id : String , source : String , opType : String , sumMin : String , sumMax : String , startDate : String , endDate : String , query : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.FilterPayHistByClientCount?AKey=\(key)&AClientID=\(id)&asource=\(source)&aoptype=\(opType)&asummmin=\(sumMin)&asummmax=\(sumMax)&adtstart=\(startDate)&adtend=\(endDate)&aquery=\(query)"
        
        print("URLString for ClientsFilterPayHistByClientCountDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsFilterPayHistByClientCountDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsFilterPayHistByClientCountDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsFilterPayHistByClientCountData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
