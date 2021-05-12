//
//  ClientsUpdatePaymentComDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.05.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsUpdatePaymentComDataManagerDelegate {
    func didGetClientsUpdatePaymentComData(data : JSON)
    func didFailGettingClientsUpdatePaymentComDataWithError(error : String)
}

struct ClientsUpdatePaymentComDataManager{
    
    var delegate : ClientsUpdatePaymentComDataManagerDelegate?
    
    func getClientsUpdatePaymentComData(key : String , paymentId id : String , com : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.UpdatePaymentCom?AKey=\(key)&APaymentID=\(id)&ANewCom=\(com)"
        
        print("URLString for ClientsUpdatePaymentComDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsUpdatePaymentComDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsUpdatePaymentComDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsUpdatePaymentComData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
//completionHandler: @escaping (JSON?, String?) -> Void)
