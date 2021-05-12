//
//  PurchasesAddItemDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.05.2021.
//

import Foundation
import SwiftyJSON

protocol PurchasesAddItemDataManagerDelegate {
    func didGetPurchasesAddItemData(data : JSON)
    func didFailGettingPurchasesAddItemDataWithError(error : String)
}

struct PurchasesAddItemDataManager {
    
    var delegate : PurchasesAddItemDataManagerDelegate?
    
    func getPurchasesAddItemData(key : String, imgId : String , zakupkaId : String , size : String , purPrice : String , sellPrice : String , withoutReplace : String , paid : String , checkDefect : String , checkImgId : String , parselImgId : String , clients : String, replaceTovarId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_purchases.AddItem?AKey=\(key)&AAgrImgID=\(imgId)&APurSysID=\(zakupkaId)&ASize=\(size)&APricePur=\(purPrice)&APriceSELL=\(sellPrice)&AWithoutRep=\(withoutReplace)&APaid=\(paid)&ACheckDefect=\(checkDefect)&AImgIDCheck=\(checkImgId)&AImgIDParsel=\(parselImgId)&AClients=\(clients)&AForReplaceID=\(replaceTovarId)"
        
        print("URLString for PurchasesAddItemDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingPurchasesAddItemDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingPurchasesAddItemDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetPurchasesAddItemData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
