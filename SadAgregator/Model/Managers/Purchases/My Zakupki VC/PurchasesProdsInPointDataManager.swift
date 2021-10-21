//
//  PurchasesProdsInPointDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 21.10.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesProdsInPointDataManagerDelegate {
    func didGetPurchasesProdsInPointData(data : JSON)
    func didFailGettingPurchasesProdsInPointDataWithError(error : String)
}

struct PurchasesProdsInPointDataManager{
    
    var delegate : PurchasesProdsInPointDataManagerDelegate?
    
    func getPurchasesProdsInPointData(key : String , purSysId : String , pointId : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.ProdsInPoint?AKey=\(key)&APurSYSID=\(purSysId)&APointID=\(pointId)&APage=\(page)"
        
        print("URLString for PurchasesProdsInPointDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesProdsInPointDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesProdsInPointDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesProdsInPointData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
