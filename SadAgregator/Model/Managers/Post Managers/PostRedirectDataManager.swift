//
//  PostRedirectDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.01.2021.
//

import Foundation
import SwiftyJSON

struct PostRedirectDataManager {
    
    func sendPostRedirectRequest(key : String , postId : String){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_utils.PostRedirect?AKey=\(key)&APostID=\(postId)"
        
        print("URLString for PostRedirectDataManager: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Wrong URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                return
            }
            
            guard let data = data else {print("Data is empty"); return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let _ = JSON(parseJSON: json) //jsonAnswer
            
        }
        
        task.resume()
        
    }
    
}
