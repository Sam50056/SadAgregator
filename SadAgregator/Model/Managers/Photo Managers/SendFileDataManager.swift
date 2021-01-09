//
//  SendFileDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 08.01.2021.
//

import Foundation
import SwiftyJSON
import Alamofire

protocol SendFileDataManagerDelegate {
    func didGetSendPhotoData(data : JSON)
    func didFailGettingSendPhotoDataWithErorr(error : String)
}

struct SendFileDataManager {
    
    var delegate : SendFileDataManagerDelegate?
    
    func sendPhotoMultipart(urlString : String, fileUrl : URL){
        
        guard let url = URL(string: urlString), let data = try? Data(contentsOf: fileUrl) , let jpegData = UIImage(data: data)?.jpegData(compressionQuality: 0.5) else {
            delegate?.didFailGettingSendPhotoDataWithErorr(error: "Error URL : \(urlString)")
            return
        }
        
        print("URL String for SendFileDataManager : \(urlString) , fileUrl : \(fileUrl)")
        
        let fileName = fileUrl.lastPathComponent
        let mimeType = fileUrl.mimeType()
        
        do{
            
            let headers: HTTPHeaders = [.contentType("multipart/form-data")]
            
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(jpegData, withName: "file" , fileName: fileName , mimeType: mimeType)
            },
            to: url, headers : headers)
            .response { response in
                print("Response data : \(String(describing: response.data))")
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
