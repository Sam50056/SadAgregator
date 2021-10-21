//
//  PurchasesSegmentsInPurchaseDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 20.10.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesSegmentsInPurchaseDataManagerDelegate{
    func didGetPurchasesSegmentsInPurchaseData(data : JSON)
    func didFailGettingPurchasesSegmentsInPurchaseDataWithError(error : String)
}

struct PurchasesSegmentsInPurchaseDataManager {
    
    var delegate : PurchasesSegmentsInPurchaseDataManagerDelegate?
    
    func getPurchasesSegmentsInPurchaseData(key : String , purSysId : String , segmentParentId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.SegmentsInPurchase?AKey=\(key)&APurSysID=\(purSysId)&ASegmentParentID=\(segmentParentId)"
        
        print("URLString for PurchasesSegmentsInPurchaseDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesSegmentsInPurchaseDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesSegmentsInPurchaseDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesSegmentsInPurchaseData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
