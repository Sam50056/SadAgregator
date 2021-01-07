//
//  Extensions.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 17.12.2020.
//

import UIKit
import RealmSwift

//MARK: - UIImageView

extension  UIImageView{
    func load(url: URL){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

//MARK: - UIViewController

extension UIViewController {
    
    func getUserDataObject () -> UserData?{
        
        let realm = try! Realm()
        
        let userData = realm.objects(UserData.self)
        
        if let userDataObject = userData.first{
            return userDataObject
        }
        
        return nil
    }
    
    func getKey() -> String?{
        
        return getUserDataObject()?.key
        
    }
    
}
