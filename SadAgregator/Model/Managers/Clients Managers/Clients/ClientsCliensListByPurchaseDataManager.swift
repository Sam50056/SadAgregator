//
//  ClientsCliensListByPurchaseDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.10.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsCliensListByPurchaseDataManagerDelegate{
    func didGetClientsCliensListByPurchaseData(data : JSON)
    func didFailGettingClientsCliensListByPurchaseDataWithError(error : String)
}

struct ClientsCliensListByPurchaseDataManager {
    
    var delegate : ClientsCliensListByPurchaseDataManagerDelegate?
    
    func getClientsCliensListByPurchaseData(key : String , pur : String , query : String , debotors : Int = 0 , page : Int = 1){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.CliensListByPur?AKey=\(key)&APruSYSID=\(pur)&ADebtors=\(debotors)&AQuery=\(query)&APage=\(page)"
        
        print("URLString for ClientsCliensListByPurchaseDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsCliensListByPurchaseDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsCliensListByPurchaseDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsCliensListByPurchaseData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
