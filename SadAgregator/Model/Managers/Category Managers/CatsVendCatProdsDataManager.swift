//
//  CatsVendCatProdsDataManager.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 01.05.2022.
//

import Foundation
import SwiftyJSON

protocol CatsVendCatProdsDataManagerDelegate{
    func didGetCatsVendCatProdsData(data : JSON)
    func didFailGettingCatsVendCatProdsDataWithError(error :String)
}

struct CatsVendCatProdsDataManager{
    
    var delegate : CatsVendCatProdsDataManagerDelegate?
    
    func getCatsVendCatProdsData(domain : String, key : String , catId : String , vendId : String , page : Int , filter : String = "" , min : String = "" , max : String = ""){
        
        var thisDomain = ""
        
        if domain != ""{
            thisDomain = domain
        }else{
            thisDomain = "agrapi.tk-sad.ru"
        }
        
        let urlString = "https://\(thisDomain)/agr_cats.VendCatProds?AKey=\(key)&AVendID=\(vendId)&ACatID=\(catId)&APage=\(page)&AFilter=\(filter)&APriceMin=\(min)&APriceMax=\(max)"
        
        print("URLString for GetCatpageDataManager: \(urlString)")
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: encodedURL)  else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //            print(String(data: data!, encoding: String.Encoding.windowsCP1251)!)
            
            if error != nil {
                delegate?.didFailGettingCatsVendCatProdsDataWithError(error: error!.localizedDescription)
                return
            }
            
            guard let data = data else {delegate?.didFailGettingCatsVendCatProdsDataWithError(error: "Data is empty");  return}
            
            let json = String(data: data , encoding: String.Encoding.windowsCP1251)!
            
            let jsonAnswer = JSON(parseJSON: json)
            
            delegate?.didGetCatsVendCatProdsData(data: jsonAnswer)
            
        }
        
        task.resume()
        
    }
    
}
