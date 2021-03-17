//
//  ClientsPagingPaymentsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.03.2021.
//

import Foundation
import SwiftyJSON

protocol ClientsPagingPaymentsDataManagerDelegate{
    func didGetClientsPagingPaymentsData(data : JSON)
    func didFailGettingClientsPagingPaymentsDataWithError(error : String)
}

struct ClientsPagingPaymentsDataManager {
    
    var delegate : ClientsPagingPaymentsDataManagerDelegate?
    
    func getClientsPagingPaymentsData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.PagingPayments?AKey=\(key)&APage=\(page)"
        
        print("URLString for ClientsPagingPaymentsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingClientsPagingPaymentsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingClientsPagingPaymentsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetClientsPagingPaymentsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
