//
//  MessageReadedDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 12.11.2020.
//

import Foundation

struct MessageReadedDataManager {
    
    func getMessageReadedData(key : String , messageId id : String) {
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.MessageReaded?AKey=\(key)&AMsgID=\(id)"
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url)
            
            task.resume()
            
        }
        
    }
    
}
