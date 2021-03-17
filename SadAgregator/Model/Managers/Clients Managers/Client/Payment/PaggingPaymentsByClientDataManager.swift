//
//  PaggingPaymentsByClientDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.03.2021.
//

import Foundation
import SwiftyJSON

protocol PaggingPaymentsByClientDataManagerDelegate{
    func didGetPaggingPaymentsByClientData(data : JSON)
    func didFailGettingPaggingPaymentsByClientDataWithError(error : String)
}

struct PaggingPaymentsByClientDataManager {
    
    var delegate : PaggingPaymentsByClientDataManagerDelegate?
    
    func getPaggingPaymentsByClientData(key : String , clientId id : String , page : Int = 1){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.PagingPaymentsByClient?AKey=\(key)&AClient=\(id)&APage=\(page)"
        
        print("URLString for PaggingPaymentsByClientDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPaggingPaymentsByClientDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPaggingPaymentsByClientDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPaggingPaymentsByClientData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
