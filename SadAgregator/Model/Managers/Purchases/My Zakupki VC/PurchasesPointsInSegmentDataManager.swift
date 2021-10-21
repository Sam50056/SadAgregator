//
//  PurchasesPointsInSegmentDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 20.10.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesPointsInSegmentDataManagerDelegate{
    func didGetPurchasesPointsInSegmentData(data : JSON)
    func didFailGettingPurchasesPointsInSegmentDataWithError(error : String)
}

struct PurchasesPointsInSegmentDataManager{
    
    var delegate : PurchasesPointsInSegmentDataManagerDelegate?
    
    func getPurchasesPointsInSegmentData(key : String , purSysId : String , segmentId : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.PointsInSegment?AKey=\(key)&APurSYSID=\(purSysId)&ASegmentID=\(segmentId)&APage=\(page)"
        
        print("URLString for PurchasesPointsInSegmentDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesPointsInSegmentDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesPointsInSegmentDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesPointsInSegmentData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
