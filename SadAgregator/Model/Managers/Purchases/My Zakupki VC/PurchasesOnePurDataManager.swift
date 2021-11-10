//
//  PurchasesOnePurDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 10.11.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesOnePurDataManagerDelegate {
    func didGetPurchasesOnePurData(data : JSON)
    func didFailGettingPurchasesOnePurDataWithError(error : String)
}

struct PurchasesOnePurDataManager {
    
    var delegate : PurchasesOnePurDataManagerDelegate?
    
    func getPurchasesOnePurData(key : String , purId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.OnePur?AKey=\(key)&APurSYSID=\(purId)"
        
        print("URLString for PurchasesOnePurDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesOnePurDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesOnePurDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesOnePurData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
