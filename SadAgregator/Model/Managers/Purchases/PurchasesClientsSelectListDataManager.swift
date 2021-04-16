//
//  PurchasesClientsSelectListDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 14.04.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesClientsSelectListDataManagerDelegate {
    func didGetPurchasesClientsSelectListData(data : JSON)
    func didFailGettingPurchasesClientsSelectListDataWithError(error : String)
}

struct PurchasesClientsSelectListDataManager {
    
    var delegate : PurchasesClientsSelectListDataManagerDelegate?
    
    func getPurchasesClientsSelectListData(key : String , page : Int , query : String = ""){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.ClientsSelectList?AKey=\(key)&APurSYSID=&APage=\(page)&AQuery=\(query)&AForReplace="
        
        print("URLString for PurchasesClientsSelectListDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesClientsSelectListDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesClientsSelectListDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesClientsSelectListData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
