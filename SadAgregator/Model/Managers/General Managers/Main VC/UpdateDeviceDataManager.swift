//
//  UpdateDeviceDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.01.2021.
//

import Foundation
import SwiftyJSON

struct UpdateDeviceDataManager{
    
    func updateDevice(key : String , token : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.UpdateDeviceiOS?AKey=\(key)&AGUID=\(token)"
        
        print("URLString for UpdateDeviceDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("Data is empty")
                return
            }
            
            if let safeData = data{
                
                let json = String(data: safeData , encoding: String.Encoding.windowsCP1251)!
                
                let _ = JSON(parseJSON: json)
                
            }
            
        }
        
        task.resume()
        
    }
    
}
