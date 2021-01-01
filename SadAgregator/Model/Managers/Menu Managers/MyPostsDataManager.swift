//
//  MyPostsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 30.12.2020.
//

import Foundation
import SwiftyJSON

protocol MyPostsDataManagerDelegate {
    func didGetMyPostsData(data : JSON)
    func didFailGettingMyPostsDataWithError(error : String)
}

struct MyPostsDataManager {
    
    var delegate : MyPostsDataManagerDelegate?
    
    func getMyPostsData(key : String , page : Int){
        
        let urlString = "https://agrapi.tk-sad.ru/agr_client.MyPosts?AKey=\(key)&APage=\(page)"
        
        print("URLString for MyPostsDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingMyPostsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingMyPostsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetMyPostsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
