//
//  PurchasesAddItemForYourselfDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.05.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesAddItemForYourselfDataManagerDelegate {
    func didGetPurchasesAddItemForYourselfData(data : JSON)
    func didFailGettingPurchasesAddItemForYourselfDataWithError(error : String)
}

struct PurchasesAddItemForYourselfDataManager{
    
    var delegate : PurchasesAddItemForYourselfDataManagerDelegate?
    
    func getPurchasesAddItemForYourselfData(key : String , imgId id : String , buyPrice : String , size : String , withoutReplace : String , payed : String , paymentExt : String , shipmentExt : String , defectCheck : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.AddItemForYourSelf?AKey=\(key)&AAgrImgID=\(id)&ABuyPrice=\(buyPrice)&ASize=\(size)&AWithoutReplace=\(withoutReplace)&APayed=\(payed)&APaymentExt=\(paymentExt)&AShipmentExt=\(shipmentExt)&ADefectCheck=\(defectCheck)"
        
        print("URLString for PurchasesAddItemForYourself DataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesAddItemForYourselfDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesAddItemForYourselfDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesAddItemForYourselfData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
