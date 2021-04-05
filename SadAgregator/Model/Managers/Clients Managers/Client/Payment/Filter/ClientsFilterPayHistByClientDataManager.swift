//
//  ClientsFilterPayHistByClientDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 05.04.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsFilterPayHistByClientDataManagerDelegate {
    func didGetClientsFilterPayHistByClientData(data : JSON)
    func didFailGettingClientsFilterPayHistByClientDataWithError(error : String)
}

struct ClientsFilterPayHistByClientDataManager {
    
    var delegate : ClientsFilterPayHistByClientDataManagerDelegate?
    
    func getClientsFilterPayHistByClientData(key : String , clientId id : String , page : Int , source : String , opType : String , sumMin : String , sumMax : String , startDate : String , endDate : String , query : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.FilterPayHistByClient?AKey=\(key)&AClientID=\(id)&apage=\(page)&asource=\(source)&aoptype=\(opType)&asummmin=\(sumMin)&asummmax=\(sumMax)&adtstart=\(startDate)&adtend=\(endDate)&aquery=\(query)"
        
        print("URLString for ClientsFilterPayHistByClientDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsFilterPayHistByClientDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsFilterPayHistByClientDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsFilterPayHistByClientData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
