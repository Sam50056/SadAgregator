//
//  ClientsPayRequestsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 03.09.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsPayRequestsDataManagerDelegate {
    func didGetClientsPayRequestsData(data : JSON)
    func didFailGettingClientsPayRequestsDataWithError(error : String)
}

struct ClientsPayRequestsDataManager {
    
    var delegate : ClientsPayRequestsDataManagerDelegate?
    
    func getClientsPayRequestsData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.PayRequests?AKey=\(key)&APage=\(page)"
        
        print("URLString for ClientsPayRequestsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsPayRequestsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsPayRequestsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsPayRequestsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
