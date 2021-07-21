//
//  PurchasesGetItemCommentsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.07.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesGetItemCommentsDataManagerDelegate{
    func didGetPurchasesGetItemCommentsData(data : JSON)
    func didFailGettingPurchasesGetItemCommentsDataWithError(error : String)
}

struct PurchasesGetItemCommentsDataManager{
    
    var delegate : PurchasesGetItemCommentsDataManagerDelegate?
    
    func getPurchasesGetItemCommentsData(key : String , id : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.GetItemComments?AKey=\(key)&AItemID=\(id)"
        
        print("URLString for PurchasesGetItemCommentsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesGetItemCommentsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesGetItemCommentsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesGetItemCommentsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
