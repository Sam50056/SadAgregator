//
//  ClientsFilterPayHistoryCountDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.04.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsFilterPayHistoryCountDataManagerDelegate {
    func didGetClientsFilterPayHistoryCountData(data : JSON)
    func didFailGettingClientsFilterPayHistoryCountDataWithError(error : String)
}

struct ClientsFilterPayHistoryCountDataManager{
    
    var delegate : ClientsFilterPayHistoryCountDataManagerDelegate?
    
    func getClientsFilterPayHistoryCountData(key : String , source : String , opType : String , sumMin : Int , sumMax : Int , startDate : String , endDate : String , query : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.FilterPayHistCount?AKey=\(key)&asource=\(source)&aoptype=\(opType)&asummmin=\(sumMin)&asummmax=\(sumMax)&adtstart=\(startDate)&adtend=\(endDate)&aquery=\(query)"
        
        print("URLString for ClientsFilterPayHistoryCountDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsFilterPayHistoryCountDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsFilterPayHistoryCountDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsFilterPayHistoryCountData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
