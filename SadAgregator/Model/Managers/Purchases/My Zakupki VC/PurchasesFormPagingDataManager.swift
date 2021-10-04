//
//  PurchasesFormPagingDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 26.09.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesFormPagingDataManagerDelegate{
    func didGetPurchasesFormPagingData(data : JSON)
    func didFailGettingPurchasesFormPagingDataWithError(error : String)
}

struct PurchasesFormPagingDataManager{
    
    var delegate : PurchasesFormPagingDataManagerDelegate?
    
    func getPurchasesFormPagingData(key : String , page : Int , status : String , query : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.FormPaging?AKey=\(key)&APage=\(page)&AStatus=\(status)&AQuery=\(query)"
        
        print("URLString for PurchasesFormPagingDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesFormPagingDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesFormPagingDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesFormPagingData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
