//
//  BrokersBalanceAddRequestDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 06.08.2021.
//

import Foundation
import SwiftyJSON

protocol BrokersBalanceAddRequestDataManagerDelegate {
    func didGetBrokersBalanceAddRequestData(data : JSON)
    func didFailGettingBrokersBalanceAddRequestDataWithError(error : String)
}

struct BrokersBalanceAddRequestDataManager {
    
    var delegate : BrokersBalanceAddRequestDataManagerDelegate?
    
    func getBrokersBalanceAddRequestData(key : String , brokerId : String , summ : String , imgId : String = ""){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_brokers.BalanceAddRequest?Akey=\(key)&ABrokerID=\(brokerId)&ASumm=\(summ)&AImgID=\(imgId)"
        
        print("URLString for BrokersBalanceAddRequestDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingBrokersBalanceAddRequestDataWithError(error: "Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                delegate?.didFailGettingBrokersBalanceAddRequestDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingBrokersBalanceAddRequestDataWithError(error: "Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetBrokersBalanceAddRequestData(data: jsonAnswer)
        }
        
        task.resume()
        
    }
    
}
