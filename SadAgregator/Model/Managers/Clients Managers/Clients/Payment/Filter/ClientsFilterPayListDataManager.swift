//
//  ClientsFilterPayListDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.04.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsFilterPayListDataManagerDelegate {
    func didGetClientsFilterPayListData(data : JSON)
    func didFailGettingClientsFilterPayListDataWithError(error : String)
}

struct ClientsFilterPayListDataManager {
    
    var delegate : ClientsFilterPayListDataManagerDelegate?
    
    func getClientsFilterPayListData(key : String , page : Int , source : String , opType : String , sumMin : Int , sumMax : Int , startDate : String , endDate : String , query : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.filterpayhist?AKey=\(key)&apage=\(page)&asource=\(source)&aoptype=\(opType)&asummmin=\(sumMin)&asummmax=\(sumMax)&adtstart=\(startDate)&adtend=\(endDate)&aquery=\(query)"
        
        print("URLString for ClientsFilterPayListDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsFilterPayListDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsFilterPayListDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsFilterPayListData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
