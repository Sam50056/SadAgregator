//
//  SendPhotoDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 08.01.2021.
//

import Foundation
import SwiftyJSON
import Alamofire

protocol SendPhotoDataManagerDelegate {
    func didGetSendPhotoData(data : JSON)
    func didFailGettingSendPhotoDataWithErorr(error : String)
}

struct SendPhotoDataManager {
    
    var delegate : SendPhotoDataManagerDelegate?
    
    func sendFileMultipart(urlString : String, fileUrl : URL){
        
        guard let url = URL(string: urlString) else {
            delegate?.didFailGettingSendPhotoDataWithErorr(error: "Error URL : \(urlString)")
            return
        }
        
        print("URL String for SendPhotoDataManager : \(urlString) , fileUrl : \(fileUrl)")
        
        let fileName = fileUrl.lastPathComponent
        let mimeType = fileUrl.mimeType()
        
        do{
            
            let data = try Data(contentsOf: fileUrl)
            
            let headers: HTTPHeaders = [.contentType("multipart/form-data")]
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file" , fileName: fileName , mimeType: mimeType)
            },
            to: url, headers : headers)
            .response { response in
                print("Response data : \(response.data)")
                guard let jsonData = response.data else {return}
                
                let json = String(data: jsonData , encoding: String.Encoding.windowsCP1251)!
                
                let jsonAnswer = JSON(parseJSON: json)
                
                delegate?.didGetSendPhotoData(data: jsonAnswer)
                print("Answer : \(jsonAnswer)")
            }
            
        }catch{
            print(error)
        }
        
    }
    
}
