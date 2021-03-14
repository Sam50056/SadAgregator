//
//  ClientsPayments.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.03.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsPaymentsDataManagerDelegate {
    func didGetClientsPaymentsData(data : JSON)
    func didFailGettingClientsPaymentsDataWithError(error : String)
}

struct ClientsPaymentsDataManager {
    
    var delegate : ClientsPaymentsDataManagerDelegate?
    
    func getClientsPaymentsData(key : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.Payments?AKey=\(key)"
        
        print("URLString for ClientsPaymentsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsPaymentsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsPaymentsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsPaymentsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
