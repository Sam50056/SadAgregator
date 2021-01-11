//
//  DelDeviceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.01.2021.
//

import Foundation
import SwiftyJSON

protocol DelDeviceDataManagerDelegate {
    func didGetDelDeviceData(data : JSON)
    func didFailGettingDelDeviceDataWithError(error : String)
}

struct DelDeviceDataManager {
    
    var delegate : DelDeviceDataManagerDelegate?
    
    func getDelDeviceData(key : String , token : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.DelDeviceiOS?AKey=\(key)&AGUID=\(token)"
        
        print("URLString for DelDeviceDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingDelDeviceDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingDelDeviceDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetDelDeviceData(data: jsonAnswer)
            
        }
        
        task.resume()
        
        
    }
    
}
