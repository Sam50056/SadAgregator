//
//  PagingClientsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 07.03.2021.
//

import Foundation
import SwiftyJSON

protocol PagingClientsDataManagerDelegate {
    func didGetPagingClientsData(data : JSON)
    func didFailGettingPagingClientsDataWithErorr(error : String)
}

struct PagingClientsDataManager {
    
    var delegate : PagingClientsDataManagerDelegate?
    
    func getPagingClientsData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_clients.PagingClients?AKey=\(key)&APage=\(page)"
        
        print("URLString for PagingClientsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPagingClientsDataWithErorr(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPagingClientsDataWithErorr(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPagingClientsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
